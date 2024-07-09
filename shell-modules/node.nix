{
  lib,
  pkgs,
  config,
  ...
}: {
  options.javascript.node = let
    inherit (lib) types;
  in {
    enable = lib.mkEnableOption "javascript project";
    env = lib.mkOption {
      type = types.enum ["production" "development" "test"];
      default = "development";
      example = "test";
    };
    package = lib.mkOption {
      type = types.package;
      default = pkgs.nodejs;
      example = lib.literalExpression "pkgs.nodejs-slim";
    };
    corepack-shims = lib.mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };
  config = let
    cfg = config.javascript.node;
  in
    lib.mkIf cfg.enable {
      packages =
        [cfg.package]
        ++ lib.lists.optional (builtins.length cfg.corepack-shims != 0) (pkgs.runCommand "corepack-enable" {} ''
          mkdir -p $out/bin
          ${cfg.package}/bin/corepack enable --install-directory $out/bin ${lib.concatStringsSep " " cfg.corepack-shims}
        '');
      env.NODE_ENV = cfg.env;
    };
}
