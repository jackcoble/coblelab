{
  options,
  config,
  lib,
}: let
  cfg = config.coblelab.timezone;
in {
  options.coblelab.timezone = {
    enable = lib.mkEnableOption "Timezone/Localisation";

    timezone = lib.mkOption {
      type = types.str;
      default = "Europe/London";
      description = "The timezone to use for the system";
    };

    keyMap = lib.mkOption {
      type = types.str;
      default = "uk";
      description = "The keymap to use for the console";
    };

    locale = lib.mkOption {
      type = types.str;
      default = "en_GB.UTF-8";
      description = "The locale to use for the system";
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = cfg.timezone;
    console.keyMap = cfg.keyMap;
    i18n.defaultLocale = cfg.locale;
  };
}
