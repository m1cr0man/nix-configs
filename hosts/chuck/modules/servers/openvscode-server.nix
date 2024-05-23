{
  services.openvscode-server = {
    enable = true;
    socketPath = "/run/root/openvscode-server.sock";
    withoutConnectionToken = true;
    user = "root";
    group = "root";
  };
}
