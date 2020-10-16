# Family users
let
  userCommon = {
    shell = pkgs.bashInteractive;
    extraGroups = [ "wheel" "users" ];
  };
in {
  users.users.lucas = userCommon // {
    home = "/home/lucas";
    group = "lucas";
    hashedPassword = "$6$T.30dsULLs$bHXslyJmCjpnNgOvXFmhox8X7YDihXBiaK8pJOyLecpEl9eYu8MMVsFGAnNOvN4sX9HEtNOo5ti71h2lQB5EB.";
  };
  users.users.sophie = userCommon // {
    home = "/home/sophie";
    group = "sophie";
    hashedPassword = "$6$YPYsDjlzPIYk$TQtSXj1wCq42N2R48GJrNg8eClkkh7O2vVCuwu/n/y/.lJHqvefjfjV1WkovvGJJ4Stnu0VTu2hqwqi8xymtF1";
  };
  users.users.adam = userCommon // {
    home = "/home/adam";
    group = "adam";
    hashedPassword = "$6$k1quToqw.pyj$KCdiq/vTVReKy3tJgZofl3GYED6h3FvcMmJLX9P0pq7mpmhBe6xn9Fnjx98e3BBEn9pM99hRRaqnJ3fNi9N8S1";
  };
  users.users.zeus = userCommon // {
    home = "/home/zeus";
    group = "zeus";
    hashedPassword = "$6$SRn6TGzY8X7cD$nbGcFjY0QZtPkto/YnuXqEDCSgoAOneRUeWrX25jlV1/RiC2MsM0Sp.ROjXQBSboRtycg5X6i2.K0l0gkBKM30";
  };
}
