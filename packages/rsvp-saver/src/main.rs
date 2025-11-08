use axum::{
    extract::{Form, State},
    http::StatusCode,
    response::IntoResponse,
    routing::post,
    Router,
};
use http::Method;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use std::net::SocketAddr;
use tower_http::cors::{AllowOrigin, CorsLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

// --- Application State and Data Structures ---

#[derive(Clone)]
struct AppState {
    db_pool: PgPool,
    http_client: reqwest::Client,
    captcha_validation_url: String,
}

// Struct to deserialize the URL-encoded form data
#[derive(Debug, Deserialize, Serialize)]
struct FormData {
    #[serde(rename = "first-name")]
    first_name: String,
    #[serde(rename = "last-name")]
    last_name: String,
    attending: String,
    dietary: String,
    song: String,
    imhumane_token: String,
}

// Struct for the JSON body expected by the captcha service
#[derive(Serialize)]
struct CaptchaValidationRequest<'a> {
    imhumane_token: &'a str,
}

// --- Handler Functions ---

// The main POST request handler
async fn submit_form(
    State(state): State<AppState>,
    Form(form_data): Form<FormData>,
) -> impl IntoResponse {
    let client = &state.http_client;
    let db_pool = &state.db_pool;

    // Log the request body with a tracing ID
    // in case something goes wrong and it needs to be replayed.
    let body: String = serde_json::to_string(&form_data).unwrap();
    let tracing_id = uuid::Uuid::new_v4().to_string();
    tracing::info!(tid = tracing_id, body = body, "Processing request");

    // 1. Validate the Captcha Token using HTTP Status Code (204/401 pattern)
    let token_body = CaptchaValidationRequest {
        imhumane_token: &form_data.imhumane_token,
    };

    // NOTE: This URL should be configurable via environment variables in a real-world scenario
    let validation_url = &state.captcha_validation_url;

    let validation_result = client.post(validation_url).json(&token_body).send().await;

    let captcha_response = match validation_result {
        Ok(res) => res,
        Err(e) => {
            tracing::error!(
                tid = tracing_id,
                error = format!("{:?}", e),
                "Captcha validation request failed",
            );
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Captcha service unavailable",
            )
                .into_response();
        }
    };

    // Check the HTTP status code for authentication result
    match captcha_response.status() {
        StatusCode::NO_CONTENT => {}
        StatusCode::UNAUTHORIZED => {
            tracing::warn!(tid = tracing_id, token=token_body.imhumane_token, "Captcha validation failed (401)");
            return (StatusCode::UNAUTHORIZED, "Captcha validation failed").into_response();
        }
        // Handle unexpected status codes
        status => {
            tracing::error!(
                tid = tracing_id, token=token_body.imhumane_token,
                status=format!("{}", status),
                "Captcha service returned unexpected status code",
            );
            return (
                status,
                "Unexpected captcha service response",
            )
                .into_response();
        }
    }

    // 2. Save the result to the Postgres database
    let insert_query = r#"
        INSERT INTO rsvp (first_name, last_name, attending, dietary, song)
        VALUES ($1, $2, $3, $4, $5)
    "#;

    match sqlx::query(insert_query)
        .bind(&form_data.first_name)
        .bind(&form_data.last_name)
        .bind(&form_data.attending)
        .bind(&form_data.dietary)
        .bind(&form_data.song)
        .execute(db_pool)
        .await
    {
        Ok(_) => {
            tracing::info!(
                tid = tracing_id,
                "Form submission saved successfully"
            );
            let mut headers = axum::http::HeaderMap::new();
            headers.insert(
                "Location",
                format!("/?success=true&name={}", form_data.first_name)
                    .try_into()
                    .unwrap(),
            );
            (StatusCode::SEE_OTHER, headers).into_response()
        }
        Err(e) => {
            tracing::error!(tid = tracing_id, error=format!("{:?}", e), "Database insert failed");
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to save form data to database",
            )
                .into_response()
        }
    }
}

// --- Main Application Setup ---

#[tokio::main(flavor = "current_thread")]
async fn main() {
    // Setup tracing
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "server=info,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    // ----------------------------------------------------
    // Database connection pool setup using ENV vars
    // ----------------------------------------------------
    let db_user = std::env::var("DB_USERNAME").expect("DB_USERNAME must be set in the environment");
    let db_pass = std::env::var("DB_PASSWORD").expect("DB_PASSWORD must be set in the environment");
    let db_socket_path = std::env::var("DB_SOCKET_PATH")
        .expect("DB_SOCKET_PATH (directory) must be set for Unix socket connection");
    let db_name = std::env::var("DB_NAME").expect("DB_NAME must be set in the environment");

    // Construct the Unix Socket connection string:
    // Format: postgresql://<user>:<password>@/<database>?host=<socket_directory>
    let database_url = format!(
        "postgresql://{}:{}@{}/{}",
        db_user,
        db_pass,
        db_socket_path.replace("/", "%2F"),
        db_name
    );

    let db_pool = PgPool::connect(&database_url)
        .await
        .expect("Failed to create Postgres pool. Check environment variables and connectivity.");
    // ----------------------------------------------------

    let captcha_validation_url = std::env::var("CAPTCHA_VALIDATION_URL") // 👈 NEW ENV VAR
        .expect("CAPTCHA_VALIDATION_URL must be set in the environment (e.g., http://localhost/v1/tokens/validate/json)");

    // CORS Configuration: Load the allowed origin from the environment
    let allowed_origin_str = std::env::var("ALLOWED_ORIGIN")
        .expect("ALLOWED_ORIGIN must be set (e.g., http://localhost:8080 or *)");

    let cors_origin = if allowed_origin_str == "*" {
        tracing::warn!("CORS set to allow ALL origins (*).");
        AllowOrigin::any()
    } else {
        let origin_uri = allowed_origin_str
            .parse()
            .expect("Invalid URL format for ALLOWED_ORIGIN");
        tracing::info!("CORS set to allow origin: {}", allowed_origin_str);
        AllowOrigin::exact(origin_uri)
    };

    let cors = CorsLayer::new()
        .allow_origin(cors_origin)
        .allow_methods([Method::POST]) // Only allow POST requests
        .allow_headers(tower_http::cors::Any); // Allow all headers

    // Initialize the HTTP client for external requests (captcha)
    let http_client = reqwest::Client::new();

    let app_state = AppState {
        db_pool,
        http_client,
        captcha_validation_url,
    };

    // Define the router and apply the CORS middleware
    let app = Router::new()
        .route("/submit", post(submit_form))
        .with_state(app_state)
        .layer(cors); // Apply CORS middleware as the outermost layer

    // Bind and serve
    let addr = SocketAddr::from(([127, 0, 0, 1], 2026));
    tracing::info!("Listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app.into_make_service())
        .await
        .unwrap();
}
