{
  description = "pNPM development environment using make-shell and javascript-nix";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    javascript-nix.url = "github:nicknovitski/javascript-nix";
    make-shell.url = "github:nicknovitski/make-shell";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    make-shell,
    javascript-nix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      imports = [make-shell.flakeModules.default];
      perSystem = {...}: {
        make-shell.imports = [javascript-nix.shellModules.default];
        make-shells.default = {
          javascript.node = {
            enable = true;
            corepack-shims = ["pnpm"];
          };
        };
      };
    };
}
