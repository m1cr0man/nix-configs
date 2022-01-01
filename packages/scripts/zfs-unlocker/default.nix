{ writeShellScriptBin, python3 }:
writeShellScriptBin "unlocker" ''
  ${python3}/bin/python3 ${./unlocker.py} $@
''
