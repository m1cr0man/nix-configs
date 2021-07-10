{ pkgs, ... }:
let
  scanNetwork = pkgs.writeShellScriptBin "scan-network" ''
    subnet=$1
    port=$2
    for ip in {1..254}; do
      ( nc -w 1 -z $subnet.$ip $port > /dev/null 2>&1 && echo Found $port open on $subnet.$ip & ) 2>/dev/null
    done
    wait
  '';
in {
  environment.systemPackages = [
    scanNetwork
  ];
}
