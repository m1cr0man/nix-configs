{ config, ... }:
{
    services.weechat = {
        enable = true;
        root = "/zroot/generic/weechat";
        sessionName = "irc";
    };
}
