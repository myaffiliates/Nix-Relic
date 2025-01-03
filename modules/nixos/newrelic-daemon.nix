{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types mdDoc;

  cfg = config.services.newrelic-daemon;
  settingsFormat = pkgs.formats.yaml {};
in {
  options.services.newrelic-daemon = {
    enable = lib.mkEnableOption "newrelic-daemon service";

    settings = mkOption {
      type = settingsFormat.type;
      default = {};
      description = mdDoc ''
        Specify the configuration for the Newrelic PHP Agent in Nix.
     '';
    };
    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = mdDoc ''
        Specify a path to a configuration file that the Daemon should use.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.newrelic-daemon = {
      description = "New Relic PHP Agent Daemon";

      after = [
        "dbus.service"
        "network.target"
      ];

      serviceConfig = let
        conf =
          if cfg.configFile == null
          then settingsFormat.generate "config.yaml" cfg.settings
          else cfg.configFile;
      in {
        RuntimeDirectory = "newrelic";
        Type = "simple";
        ExecStart = "${pkgs.infrastructure-agent}/bin/daemon -f -c ${conf}";
        ExecReload = "${pkgs.coreutils}/bin/kill -USR2 $MAINPID";
        ExecStop = "${pkgs.coreutils}/bin/kill -TERM $MAINPID";
        ReadWritePaths = [ "/var/log" "/etc/newrelic" "/etc/php" ];        
        LogsDirectory = "newrelic";
        Restart = "on-failure";
        RestartPreventExitStatus = "1";
      };

      unitConfig = {
        StartLimitInterval = 0;
        StartLimitBurst = 5;
      };

      wantedBy = ["multi-user.target"];
    };
  };

  
}
