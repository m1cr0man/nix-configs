{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    extraPlugins = with pkgs.postgresql_11.pkgs; [ postgis ];
  };
}
