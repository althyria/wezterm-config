{
  inputs.wezterm.url = "github:wezterm/wezterm?dir=nix";
  inputs.nixgl.url = "github:nix-community/nixGL";
  inputs.nixpkgs.follows = "nixgl/nixpkgs";

  outputs = { self, wezterm, nixgl, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default =
        let
          deps = [ pkgs.tmux ];
          wrapper = pkgs.runCommand "wezterm" {} ''
            mkdir -p $out/bin
            cat > $out/bin/wezterm <<EOF
            #!${pkgs.bash}/bin/bash
            export WEZTERM_SHELL_INTEGRATION="${./shell-integration.sh}"
            exec ${nixgl.packages.${system}.nixGLDefault}/bin/nixGLDefault \
              ${wezterm.packages.${system}.default}/bin/wezterm \
              --config-file ${./wezterm.lua} "\$@"
            EOF
            chmod +x $out/bin/wezterm
          '';
        in
          pkgs.symlinkJoin {
            name = "wezterm";
            paths = [ wrapper ] ++ deps;
          };
    };
}
