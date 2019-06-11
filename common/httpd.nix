{
  httpUpgrade =  ''
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteCond %{REQUEST_URI} !^/.well-known/.*$ [NC]
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
    ProxyPass /\.well-known/ http://localhost/.well-known/
  '';
}
