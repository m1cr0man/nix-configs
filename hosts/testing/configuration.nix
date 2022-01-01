{ lib, ... }:
{
  system.stateVersion = "21.03";
  networking.domain = lib.m1cr0man.domain;
}
