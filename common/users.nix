# Family users
# Generate passwords with mkpasswd -m sha-512
{ pkgs, ... }:
let
  userCommon = {
    shell = pkgs.bashInteractive;
    extraGroups = [ "wheel" "users" ];
  };
in {
  users.mutableUsers = false;

  users.groups.lucas = {
    gid = 1000;
  };
  users.users.lucas = userCommon // {
    uid = 1000;
    home = "/home/lucas";
    group = "lucas";
    hashedPassword = "$6$grITU0sOwK5q6$I61l9jInNJ/9I7Rw7wwNGjnxh2jCSVXxI0xa9wBvmgtqu6eWP9QmoxEoYIgq8t0abEbQHXeeo.6dREqpZ3PS6/";
  };
  users.groups.zeus = {
    gid = 1001;
  };
  users.users.zeus = userCommon // {
    uid = 1001;
    home = "/home/zeus";
    group = "zeus";
    hashedPassword = "$6$SRn6TGzY8X7cD$nbGcFjY0QZtPkto/YnuXqEDCSgoAOneRUeWrX25jlV1/RiC2MsM0Sp.ROjXQBSboRtycg5X6i2.K0l0gkBKM30";
  };
  users.groups.adam = {
    gid = 1002;
  };
  users.users.adam = userCommon // {
    uid = 1002;
    home = "/home/adam";
    group = "adam";
    hashedPassword = "$6$k1quToqw.pyj$KCdiq/vTVReKy3tJgZofl3GYED6h3FvcMmJLX9P0pq7mpmhBe6xn9Fnjx98e3BBEn9pM99hRRaqnJ3fNi9N8S1";
  };
  users.groups.sophie = {
    gid = 1003;
  };
  users.users.sophie = userCommon // {
    uid = 1003;
    home = "/home/sophie";
    group = "sophie";
    hashedPassword = "$6$YPYsDjlzPIYk$TQtSXj1wCq42N2R48GJrNg8eClkkh7O2vVCuwu/n/y/.lJHqvefjfjV1WkovvGJJ4Stnu0VTu2hqwqi8xymtF1";
  };

  # Games user owns games folders
  users.users.games = {
    uid = 123;
    isSystemUser = true;
    home = "/home/games";
    group = "users";
    extraGroups = [ "lucas" "sophie" "adam" "zeus" ];
  };

  # Allow all users to sudo to games
  security.sudo.extraRules = [{
    users = [ "lucas" "sophie" "adam" "zeus" ];
    runAs = "games:users";
    commands = [{ options = [ "NOPASSWD" "SETENV" ]; command = "ALL"; }];
  }];
}
