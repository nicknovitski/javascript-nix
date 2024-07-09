# Options

These are the options currently declared by `javascript-nix`.

## What about bun? Or elm? Or vite? Or...?

They're all great, but javascript-nix does not provide options related to them.
This is because those tools are [already packaged in the nixpkgs package
repository](https://search.nixos.org/packages), and adding them to a shell is
trivial.  To reduce maintenance burden, `javascript-nix` only has options for
tools which benefit from a modular configuration, if only slightly.

For example:
```nix
# Here's a complete bun development shell
{pkgs, ...}: {packages = [pkgs.bun];}
# Would this be an improvement?
{pkgs, ...}: {
  imports = [javascript-nix.shellModules.default];
  javascript.bun.enable = true;
};
```

The examples directory includes several examples like this.

If you notice that a useful option is missing, pull requests to add them are welcome.

## Deno

[The next-generation javascript runtime](https://deno.com/)

### javascript.deno.enable

If true, the deno runtime is added to the environment.

Default value: false

### javascript.deno.install-root

A non-empty string.  If `javascript.deno.enable` is true, the `DENO_INSTALL_ROOT` variable is set to this value in the environment, and `$DENO_INSTALL_ROOT/bin` is added to the `PATH` variable.

Default value: `"$HOME/.deno"`

## Node.js

[https://nodejs.org/en](https://nodejs.org/en)

### javascript.node.corepack-shims

An array of strings which, if `javascript.node.enable` is true, are passed to `corepack enable`, creating [corepack](https://nodejs.org/api/corepack.html) package manager shims.

Currently, supported values are `"yarn"`, `"pnpm"`, and `"npm"`.

Default value: `[]`

### javascript.node.enable

Whether to add the Node.js runtime to the environment.

Default value: false

### javascript.node.env

One of either `"production"`, `"development"`, or `"test"`.  If `javascript.node.enable` is true, then the `NODE_ENV` variable is set to this value in the environment.

Default value: `"development"`

You can make different shells depending on what you intend to run in them.  For example:

```nix
# in a flake-parts flake.nix...
perSystem = {...}: {
  make-shell.imports = [
    javascript-nix.shellModules.default
    {javascript.node.enable = true;}
  ];
  make-shells = {
    default = {pkgs, ...}: {
      packages = [
        # Interactive tools that only human developers need to use
      ];
    };
    test = {javascript.node.env = "test";}; 
    build = {javascript.node.env = "production";};
  };
};
```

### javascript.node.package

If `javascript.volta.enable` is true, this package is added to the environment.  There are [several alternative packages in nixpkgs](https://search.nixos.org/packages?from=0&size=50&sort=relevance&type=packages&query=nodejs-), such as `nodejs-slim` (which lacks npm), or `nodejs_22` (the latest version in the 22.x line).

Default value: `pkgs.nodejs`

## Volta

[The Hassle-Free JavaScript Tool Manager](https://volta.sh/)

### javascript.volta.enable

Whether to add volta to the environment.

Default value: false
### javascript.volta.home

A non-empty string.  If `javascript.volta.enable` is true, the `VOLTA_HOME` variable is set to this value in the environment.

Default value: `"$HOME/.volta"`
