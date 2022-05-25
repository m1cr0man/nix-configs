{ exec, ... }: {
  # Decrypts a SOPS encrypted file at eval time so it can be
  # read or imported.
  readSops = name: exec [ "sops" "--decrypt" name ];
}
