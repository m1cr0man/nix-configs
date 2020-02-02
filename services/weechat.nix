{ config, pkgs, ... }:
{
    services.weechat = {
        enable = true;
        root = "/opt/generic/weechat";
        sessionName = "irc";
    };
    systemd.services.weechat.requires = [ "opt-generic.mount" ];
}
