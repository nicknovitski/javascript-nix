{
  lib,
  pkgs,
  config,
  ...
}: {
  options.javascript.volta = {
    enable = lib.mkEnableOption "Volta tool version manager";
    home = lib.mkOption {
      default = "$HOME/.volta";
      example = "$(git rev-parse --show-toplevel)/.volta";
      type = lib.types.nonEmptyStr;
    };
  };
  config = let
    cfg = config.javascript.volta;
  in
    lib.mkIf cfg.enable {
      packages =
        if config.javascript.node.enable
        then
          builtins.throw ''
            Node.js and Volta-managed shims can't be used in the same shell environment, but both `javascript.node` and `javascript.volta` options are enabled.
          ''
        else [
          pkgs.volta
          # Unless VOLTA_HOME is set and "$VOLTA_HOME/bin" is present in PATH,
          # `volta setup` will attempt to modify files in the user's HOME
          # directory.  Ref:
          # https://github.com/volta-cli/volta/blob/fd9cc3fcf4db08097709e3f2be207be12f2453f2/src/command/setup.rs#L45
          (pkgs.runCommand "volta-setup" {} ''
            mkdir -p $out/bin
            VOLTA_HOME="$out" PATH="$out/bin:$PATH" ${pkgs.volta}/bin/volta setup --verbose
          '')
        ];

      # If a volta shim is run in the context of a package.json which doesn't
      # have a "volta" field, it will fall back to externally installed versions
      # of the tool, if present.  If that version is an externally installed
      # volta shim, then the shims will get stuck in an infinite loop.
      # To solve this, we detect and remove externally installed volta versions
      # from PATH.
      shellHook = ''
        if [ -n "''${VOLTA_HOME:-}" ]; then
          eval "$(${pkgs.direnv}/bin/direnv stdlib)"
          PATH_rm "$VOLTA_HOME"
          unset VOLTA_HOME
        fi
        VOLTA_HOME="${cfg.home}"
        export VOLTA_HOME
      '';
    };
}
