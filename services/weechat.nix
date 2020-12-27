{ config, pkgs, ... }:
{
    services.weechat = {
        enable = true;
        root = "/home/weechat";
        sessionName = "irc";
    };
    systemd.services.weechat.requires = [ "home.mount" ];
}
