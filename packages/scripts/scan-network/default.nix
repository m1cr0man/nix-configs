{ runCommand }:
runCommand "scan-network" { } ''
  mkdir -p $out/bin
  cp ${./scan-network.sh} $out/bin/scan-network
  chmod 555 $out/bin/scan-network
''
