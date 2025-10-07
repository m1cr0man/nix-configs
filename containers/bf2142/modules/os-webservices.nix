{ config, pkgs, ... }:
let
  mongodbURI = "mongodb:///var/lib/sockets/mongodb.sock";

  stateDir = config.m1cr0man.openspy-containers.stateDir;
  apiKeyEnv = "${stateDir}/openspy-api-key.env";
  src = pkgs.fetchFromGitHub {
    owner = "openspy";
    repo = "webservices";
    rev = "edcc2a5ee6ab4f24c53452fa8bf64dee65bf77f2";
    hash = "sha256-EGMiqiVuTN0Pmi5eHfZ2oIsXQx2ocusmK3RcJBHMRBo=";
  };
in {
  systemd.services.uwsgi = {
    requiredBy = [ "nginx.service" ];
    before = [ "nginx.service" ];
    requires = [ "openspy-setup.service" ];
    after = [ "openspy-setup.service" ];
    serviceConfig.EnvironmentFile = apiKeyEnv;
  };

  services.uwsgi = {
    enable = true;
    plugins = [ "python3" ];
    user = "openspy";
    group = "openspy";
    instance = {
      type = "emperor";
      vassals = {
        auth = {
          type = "normal";
          pythonPackages = self: [ self.rsa self.requests ];
          env = [
            "API_URL=http://core-web:8080"
            "AUTH_TOKEN_EXPIRE_TIME=3600"
            "AUTHSERVICES_PRIVKEY_PATH=${stateDir}/auth-services.private.pem"
            "AUTHSERVICES_PEERKEY_KEY_PATH=${stateDir}/auth-services.private.pem"
          ];
          socket = [ "/run/uwsgi/authservice.sock" ];
          chdir = "${builtins.toString src}/AuthService";
          wsgi-file = "AuthService.py";
        };
        commerce = {
          type = "normal";
          socket = [ "/run/uwsgi/commerceservice.sock" ];
          chdir = "${builtins.toString src}/CommerceService";
          wsgi-file = "CommerceService.py";
        };
        competition = {
          type = "normal";
          pythonPackages = self: [ self.rsa self.pymongo ];
          env = [
            "AUTHSERVICES_PUBKEY_PATH=${stateDir}/auth-services.public.pem"
            "MONGODB_URI=${mongodbURI}/CompetitionService"
          ];
          socket = [ "/run/uwsgi/competitionservice.sock" ];
          chdir = "${builtins.toString src}/CompetitionService";
          wsgi-file = "CompetitionService.py";
        };
        storage = {
          type = "normal";
          pythonPackages = self: [ self.redis self.python-dateutil self.pymongo ];
          env = [
            "MONGODB_URI=${mongodbURI}/StorageService"
            "REDIS_URL=redis://localhost:6379/3"
          ];
          socket = [ "/run/uwsgi/storageservice.sock" ];
          chdir = "${builtins.toString src}/StorageService";
          wsgi-file = "StorageService.py";
        };
      };
    };
  };
}
