{ pkgs, config, lib, ... }:
let
  helpers = import ./helpers.nix { inherit pkgs config lib; };
  inherit (helpers) mkDomain mkHeldDomain;
in lib.mkMerge [
  (mkDomain {
    username = "vcc";
    domain = "vccomputers.ie";
    php = true;
    mysql = true;
  })
  (mkDomain {
    username = "achiever";
    domain = "achiever.ie";
  })
  (mkDomain {
    username = "azzkcr";
    domain = "azzkcr.com";
  })
  # balortheatre.com was just an iframe redirecting to another domain
  ({
    services.httpd.virtualHosts."balortheatre.com" = {
      serverAliases = [ "www.balortheatre.com" ];
      globalRedirect = "https://www.balorartscentre.com";
      onlySSL = true;
      enableACME = true;
    };
  })
  (mkDomain {
    username = "bradleyh";
    domain = "bradleyhydraulics.ie";
  })
  (mkDomain {
    username = "citypnts";
    domain = "citypaints.net";
    php = true;
    mysql = true;
  })
  (mkDomain {
    username = "crclk";
    domain = "crclk.ie";
    # Not migrated yet
    aliases = [
      "resourcecentreletterkenny.com" "www.resourcecentreletterkenny.com"
    ];
    php = true;
    mysql = true;
  })
  (mkDomain {
    username = "voop";
    domain = "voopdonegal.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "dfas";
    domain = "donegalfirstaidservices.com";
    wordpress = true;
  })
  (mkDomain {
    username = "donegalr";
    domain = "donegalrapecrisis.ie";
  })
  {
    users.users.donegalr.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvPei/LRfDa0p1/2Xi8p52WCOYlB0yod9ZktGZuzhWH donegalr@donegalrapecrisis.ie"
    ];
  }
  (mkDomain {
    username = "bbhouse";
    domain = "bridgeburnhouse.com";
    primaryDomain = "www.bridgeburnhouse.com";
    wordpress = true;
  })
  (mkDomain {
    username = "ciarancc";
    domain = "ciaranscustoms.ie";
    aliases = [
      "ciaranscustomcomputers.ie" "www.ciaranscustomcomputers.ie"
      "ciaranscustomcomputers.com" "www.ciaranscustomcomputers.com"
      "ciaranscustoms.com" "www.ciaranscustoms.com"
    ];
    php = true;
    mysql = true;
  })
  (mkDomain {
    username = "csc";
    domain = "churchillselfcatering.ie";
    aliases = [ "churchillselfcatering.com" "www.churchillselfcatering.com" ];
    php = true;
    postgresql = true;
  })
  (mkDomain {
    username = "lsc";
    domain = "letterkennyselfcatering.ie";
    aliases = [ "letterkennyselfcatering.com" "www.letterkennyselfcatering.com" ];
    php = true;
    postgresql = true;
  })
  (mkDomain {
    username = "lsa";
    domain = "letterkennystudentaccommodation.ie";
    php = true;
    postgresql = true;
  })
  # LSA needs access to LSC
  # CSC needs access to LSC and vice versa
  {
    services.postgresql.ensureUsers = [
      {
        name = "lsa";
        ensurePermissions."DATABASE lsc" = "ALL PRIVILEGES";
      }
      {
        name = "csc";
        ensurePermissions."DATABASE lsc" = "ALL PRIVILEGES";
      }
      {
        name = "lsc";
        ensurePermissions."DATABASE csc" = "ALL PRIVILEGES";
      }
    ];
  }
  (mkDomain {
    username = "connapty";
    domain = "connaughtproperty.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "craoibhin2017";
    domain = "craoibhintermon.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "emailire";
    domain = "emailireland.net";
  })
  (mkDomain {
    username = "eliza";
    domain = "elizacare.ie";
    primaryDomain = "www.elizacare.ie";
    aliases = [
      "ealgalodge.ie" "www.ealgalodge.ie"
      "larissalodge.ie" "www.larissalodge.ie"
    ];
    wordpress = true;
  })
  (mkDomain {
    username = "fuellog";
    domain = "fuellogistics.ie";
  })
  (mkDomain {
    username = "glensns";
    domain = "glenswilly.com";
    php = true;
    mysql = true;
  })
  (mkDomain {
    username = "grassrt";
    domain = "grassroutes.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "gszeus";
    domain = "gszeusgaming.com";
    aliases = [ "sikgodsgaming.com" "www.sikgodsgaming.com" ];
    php = true;
    mysql = true;
  })
  (mkDomain {
    username = "hannongr";
    domain = "hannongreene.ie";
    aliases = [ "hannongreene.com" "www.hannongreene.com" ];
    wordpress = true;
  })
  ({
    services.httpd.virtualHosts."highlandlandscapes.ie" = {
      serverAliases = [
        "www.highlandlandscapes.ie"
        "letterkennygardencentre.com" "www.letterkennygardencentre.com"
      ];
      globalRedirect = "https://ballaghderggardencentre.ie/";
      onlySSL = true;
      enableACME = true;
    };
  })
  (mkDomain {
    username = "hillside";
    domain = "hillsidekitchens.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "irishpre";
    domain = "irishpressings.com";
    wordpress = true;
  })
  (mkDomain {
    username = "loughrey";
    domain = "loughrey.ie";
  })
  (mkDomain {
    username = "mdtcon";
    domain = "mdtconstruction.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "moore";
    domain = "mooreproperties.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "forgotn";
    domain = "not-forgotten.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "pswann";
    domain = "patriciaswann.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "planning";
    domain = "planningservices.ie";
  })
  (mkDomain {
    username = "pitchboo";
    domain = "pitchbook.net";
  })
  (mkDomain {
    username = "rathchar";
    domain = "rathmullancharters.com";
    wordpress = true;
  })
  (mkDomain {
    username = "reynolds";
    domain = "reynolds.ie";
    live = false;
  })
  (mkDomain {
    username = "royalpr";
    domain = "royalandprior.ie";
    wordpress = true;
  })
  (mkDomain {
    username = "stewarta";
    domain = "stewartandmaclochlainn.ie";
  })
  (mkDomain {
    username = "stjohnfc";
    domain = "stjohnstoncarrigansfrc.ie";
    aliases = [ "stjohnfrc.ie" "www.stjohnfrc.ie" ];
    php = true;
    mysql = true;
    # TODO joomla. Currently 500's
  })
  (mkDomain {
    username = "wcdf";
    domain = "wcdf.net";
  })
  # Hosting provider has not set up redirects correctly. We can do it for them.
  ({
    services.httpd.virtualHosts."stationhouseletterkenny.ie" = {
      serverAliases = [
        "www.stationhouseletterkenny.ie"
        "stationhouseletterkenny.net" "www.stationhouseletterkenny.net"
        "shlky.ie" "www.shlky.ie"
        "shlky.net" "www.shlky.net"
        "shlky.com" "www.shlky.com"
      ];
      globalRedirect = "https://www.stationhouseletterkenny.com";
      onlySSL = true;
      enableACME = true;
    };
  })
]
