{
  # Enable access to the web UI outside of the container
  services.rspamd.workers.controller.bindSockets = [{
    socket = "/var/lib/rspamd/rspamd-ui.sock";
    mode = "0666";
  }];

  # Extra rspamd filters
  services.rspamd.locals = {
    "mx_check.conf".text = ''
      enabled = true;
    '';
    "phishing.conf".text = ''
      openphis_enabled = true;
      phishtank_enabled = true;
    '';
    "replies.conf".text = ''
      action = "no action";
    '';
    "spf.conf".text = ''
      spf_cache_size = 2k;
      spf_cache_expire = 1d;
      max_dns_nesting = 8;
      max_dns_requests = 20;
      min_cache_ttl = 5m;
      disable_ipv6 = false;
    '';
    "url_reputation.conf".text = ''
      # Scan URLs
      enabled = true;
    '';
    "url_tags.conf".text = ''
      # Redis caching of URL tags
      enabled = true;
    '';
  };
}
