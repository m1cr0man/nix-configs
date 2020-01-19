{ config, ... }:
{
    services.weechat = {
        enable = true;
        root = "/opt/generic/weechat";
        sessionName = "irc";
    };
}
