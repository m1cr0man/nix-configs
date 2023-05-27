# This file defines options that are used in many of the modules
# in this repository.
{ lib, ... }:
{
  options.vcc = with lib; {
    wordpressSites = mkOption {
      default = {};
      type = with types; attrsOf str;
      description = "Map of usernames to wordpress domains.";
    };
  };
}
