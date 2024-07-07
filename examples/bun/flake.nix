{
  description = "Bun development environment using make-shell";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    make-shell.url = "github:nicknovitski/make-shell";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    make-shell,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      imports = [make-shell.flakeModules.default];
      perSystem = {...}: {make-shells.default = {pkgs, ...}: {packages = [pkgs.bun];};};
    };
}
