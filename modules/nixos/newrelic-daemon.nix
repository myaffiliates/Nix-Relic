{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.services.newrelic-php-daemon;
  settingsFormat = pkgs.formats.yaml {};
in {
  options.services.newrelic-php-daemon = {
    enable = lib.mkEnableOption "newrelic-php-daemon service";

    settings = mkOption {
      type = settingsFormat.type;
      default = {};
    };
    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.newrelic-php-daemon = {
      description = "New Relic PHP Agent Daemon";

      after = [
        "dbus.service"
        "syslog.target"
        "network.target"
      ];

      serviceConfig = let
        conf =
          if cfg.configFile == null
          then settingsFormat.generate "config.yaml" cfg.settings
          else cfg.configFile;
      in {

      after = [ "network.target" ];
      serviceConfig = {
        RuntimeDirectory = "newrelic";
        Type = "simple";
        ExecStart = "${pkgs.newrelic-php-daemon}/bin/daemon -f -c ${conf}";
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
