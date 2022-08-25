{
  nixConfig = {
    bash-prompt-prefix = "(nix) ";
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs?rev=c83b87fecd1a86d6a1861667664e6f45eb76d763";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { flake-utils, nixpkgs, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ rust-overlay.overlays.default ]; };
      in
      {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = with pkgs; [
            pkgconfig
          ];

          buildInputs = with pkgs; [
            # add npm
            nodejs-18_x

            # rust toolchain with wasm target
            (rust-bin.stable.latest.default.override {
              extensions = [ ];
              targets = [ "wasm32-unknown-unknown" ];
            })
            cargo
            wasm-pack

            # LSP for development
            rust-analyzer

            # specify your other dependencies here
            # for instance for bevy add:
            #
            # udev alsaLib vulkan-loader
            #
          ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };
      }
    );
}
