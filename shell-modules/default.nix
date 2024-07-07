{
  lib,
  pkgs,
  config,
  ...
}: {
  options.javascript.node = {
    enable = lib.mkEnableOption "javascript project";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodejs;
    };
  };
  config = let
    cfg = config.javascript.node;
  in
    lib.mkIf cfg.enable {
      packages = [cfg.package];
    };
}
