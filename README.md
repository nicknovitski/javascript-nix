# javascript-nix

A [make-shell](https://github.com/nicknovitski/make-shell) module for javascript development.

## Why?

`make-shell` is a modular interface for making nix derivations intended for use by the `nix develop` command.  It has it's own [WHY document](https://github.com/nicknovitski/make-shell/blob/main/WHY.md) which attempts to explain how it might be useful, but I thought that creating this repository might also give an indirect explanation.  

## Installation

First make sure that you've [installed `make-shell` in your flake](https://github.com/nicknovitski/make-shell/tree/main?tab=readme-ov-file#installation).

Then, add `javascript-nix` to your flake inputs.  Maybe they'd look like this:
```nix
  inputs = {
    javascript-nix.url = "github:nicknovitski/javascript-nix";
    make-shell.url = "github:nicknovitski/make-shell";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
```

Then, add the shell module to your shell's imports.  It'll look something like this:
```nix
devShells.default = pkgs.make-shell = { 
  imports = [inputs.javascript-nix.shellModules.default]; # add option declarations...
  javascript.node.enable = true; # ...and definitions!
}
# or, if you're using flake-parts...
make-shell.imports = [javascript-nix.shellModules.default]; # shared imports for all `make-shells` attributes
make-shells.default = {javascript.node.enable = true;};
```

## Usage

The options this module declares are documented [the OPTIONS.md file](OPTIONS.md).  Although if you know even a little nix, I bet you can read the declarations directly in the `shell-modules` directory.

## Examples

Look in this repository's `examples` directory for a subdirectory that gives you the tooling you want.  Copy the `flake.nix` file, fully or in part.

For the sake of terseness, most of the examples all use [flake-parts](https://flake.parts/) and `make-shell`'s flake module, but this is not necessary to use `javascript-nix`.  See [the flake-utils example](examples/node-flake-utils) if you're interested.Or, just remember:

```nix
#this...
make-shell.imports = [javascript-nix.shellModules.default];
make-shells.default = { javascript.node.enable = true; }; 
# is the same as this...
devShells.default = pkgs.make-shell { 
  imports = [javascript-nix.shellModules.default];
  javascript.node.enable = true;
};
```

