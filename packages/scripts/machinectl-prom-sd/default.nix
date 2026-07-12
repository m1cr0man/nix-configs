{ writeShellScriptBin, python3 }:
writeShellScriptBin "machinectl-prom-sd" ''
  ${python3}/bin/python3 ${./machinectl-prom-sd.py} $@
''
