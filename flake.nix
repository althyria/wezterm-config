{
  inputs.wezterm.url = "github:wezterm/wezterm?dir=nix";
  inputs.nixgl.url = "github:nix-community/nixGL";
  inputs.nixpkgs.follows = "nixgl/nixpkgs";

  outputs = { self, wezterm, nixgl, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.runCommand "wezterm" {} ''
        mkdir -p $out/bin
        cat > $out/bin/wezterm <<EOF
        #!${pkgs.bash}/bin/bash
        exec ${nixgl.packages.${system}.nixGLIntel}/bin/nixGLIntel \
          ${wezterm.packages.${system}.default}/bin/wezterm \
          --config-file ${./wezterm.lua} "\$@"
        EOF
        chmod +x $out/bin/wezterm
      '';
    };
}
