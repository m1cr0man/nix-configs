{
  httpUpgrade =  ''
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteCond %{REQUEST_URI} !^/\.well-known/.*$ [NC]
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301]
    ProxyPass /.well-known !
  '';
}
