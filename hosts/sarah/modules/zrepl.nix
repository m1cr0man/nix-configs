{
  services.zrepl = {
    enable = true;
    settings.jobs = [{
      name = "zhuge_sink";
      type = "sink";
      root_fs = "zhuge1";
      serve = {
        type = "tcp";
        listen = ":11223";
        clients = {
          "100.64.48.0/24" = "headscale4-*";
          "fd7a:115c:a1e0::/48" = "headscale6-*";
        };
      };
    }];
  };
}
