let
  certsDir = "/var/lib/acme";
in {
  security.acme.certs."m1cr0man.com" = {
    "m1cr0man.com".email = "lucas@m1cr0man.com";
  };
  security.acme.directory = certsDir;


  # Anywhere else this is set will be concated together
  # <3 Nix
  services.httpd.servedDirs = [
    {
      dir = "/var/lib/acme/challenges";
      urlPath = "/.well-known/acme-challenge/";
    }
  ];

  #services.httpd.sslServerCert = "${certsDir}/m1cr0man.com/";
}
