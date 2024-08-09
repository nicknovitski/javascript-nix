{
  lib,
  pkgs,
  config,
  ...
}: {
  options.javascript.node = let
    inherit (lib) mkOption types;
  in {
    enable = lib.mkEnableOption "Node.js javascript runtime";
    env = mkOption {
      type = types.nullOr (types.enum ["production" "development" "test"]);
      default = null;
      example = "development";
    };
    package = lib.mkOption {
      type = types.package;
      default = pkgs.nodejs;
      defaultText = "pkgs.nodejs";
      example = lib.literalExpression "pkgs.nodejs-slim";
    };
    corepack-shims = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };
  config = let
    cfg = config.javascript.node;
  in {
    env =
      if cfg.env == null
      then {}
      else {NODE_ENV = cfg.env;};
    packages = lib.optionals cfg.enable ([cfg.package]
      ++ lib.lists.optional (builtins.length cfg.corepack-shims != 0) (pkgs.runCommand "corepack-enable" {} ''
        mkdir -p $out/bin
        ${cfg.package}/bin/corepack enable --install-directory $out/bin ${lib.concatStringsSep " " cfg.corepack-shims}
      ''));
  };
}
