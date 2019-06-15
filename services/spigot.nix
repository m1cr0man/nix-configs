with import <nixpkgs> {};

runCommand "spigot-jar-1.14.2" {
    inherit jdk git;
    buildtools = fetchurl {
        url = "https://hub.spigotmc.org/jenkins/job/BuildTools/101/artifact/target/BuildTools.jar";
        sha256 = "b27b683c9f30f22f56726af23350b9d6d870921443798b38adb341aead91d08c";
    };
} ''
export PATH="$git/bin:$jdk/bin:$PATH"
java -jar BuildTools.jar --rev 1.14.2
mv spigot-*.jar $out
''
