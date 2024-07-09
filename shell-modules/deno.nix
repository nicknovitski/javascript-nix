{
  lib,
  pkgs,
  config,
  ...
}: {
  options.javascript.deno = {
    enable = lib.mkEnableOption "Deno javascript and typescript runtime";
    install-root = lib.mkOption {
      default = "$HOME/.deno";
      example = "$(git rev-parse --show-toplevel)/.deno";
      type = lib.types.nonEmptyStr;
    };
  };
  config = let
    cfg = config.javascript.deno;
  in
    lib.mkIf cfg.enable {
      packages = [pkgs.deno];
      shellHook = ''
        DENO_INSTALL_ROOT="${cfg.install-root}"
        PATH="$DENO_INSTALL_ROOT/bin:$PATH"
        export DENO_INSTALL_ROOT PATH
      '';
    };
}
