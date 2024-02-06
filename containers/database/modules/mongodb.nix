{ pkgs, ... }: {
  services.mongodb.enable = true;
  services.mongodb.bind_ip = "/var/lib/sockets/mongodb.sock";

  users.users.mongodb.extraGroups = [ "sockets" ];

  environment.systemPackages = [ pkgs.mongodb-tools ];
}
