with import <nixpkgs> {};

stdenv.mkDerivation {
    name = "m1cr0blog-1.2.1";

    src = fetchFromGithub {
        owner = "m1cr0man";
        repo = "m1cr0blog";
        rev = "6393e83b8f356b47babb531ec1187ff46dced215";
        sha256 = "0s344lpqnmp16y4x9k8ds0yichxc1mgl1bfd7kbhh5rjg6hx5ksc";
    }

    buildInputs = [ nodejs-11_x rsync ];

    # Env vars
    NODE_ENV = "production";

    buildPhase = ''
        export PATH=$PATH:${nodejs-11_x}/bin:${rsync}/bin
        npm install
        npm run build
    '';

    installPhase = ''
        mkdir -p $out
        mv node_modules package.json dist $out/
    '';
}
