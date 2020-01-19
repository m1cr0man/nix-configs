{ config, ... }:
{
    services.weechat = {
        enable = true;
        root = "/zstorage/generic/weechat";
        sessionName = "irc";
    };
}
