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
          export PATH=$(${pkgs.gnused}/bin/sed --regexp-extended --expression="s;$VOLTA_HOME/bin:\?;;" --expression="s;:\?$VOLTA_HOME/bin;;" <<< "$PATH")
          unset VOLTA_HOME
        fi
        VOLTA_HOME="${cfg.home}"
        export VOLTA_HOME
      '';

      # When a volta shim runs an npm script, if the environment variable
      # _VOLTA_TOOL_RECURSION is not set, it sets it in the script's
      # environment, and prepends the directory containing the non-shim tools
      # of the pinned version to PATH.
      #
      # So with a package.json file like this, the command `npm run script`
      # will run the shim `npm`, and the actual node version 23.0.0, with the
      # output "v23.0.0":
      # ```json
      # {
      #   "scripts": { "script": "node --version" },
      #   "volta": { "node": "23.0.0" }
      # }
      # ```
      #
      # However, if the script evaluates this shell again, then the directory
      # containing all the shims will be prepended to PATH, prioritizing them
      # over the non-shim tools.  If the script then runs any of those shims,
      # they will not modify PATH, because _VOLTA_TOOL_RECURSION will be set.
      # This can happen with scripts that use `direnv exec`, and can cause
      # scripts to hang, or to error with `Volta error: <tool> is not
      # available`.
      #
      # To prevent all this, we unset the variable when entering a shell.
      env._VOLTA_TOOL_RECURSION = null;
    };
}
