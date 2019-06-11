{
  httpUpgrade =  ''
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
    ProxyPass /\.well-known/ http://localhost/.well-known/
  '';
}
