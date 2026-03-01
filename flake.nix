{
  inputs.wezterm.url = "github:wezterm/wezterm?dir=nix";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, wezterm, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default =
        let
          wtmuxWrapper = pkgs.runCommand "wtmux" {} ''
            mkdir -p $out/bin
            cat > $out/bin/wtmux <<EOF
            #!${pkgs.bash}/bin/bash
            exec ${pkgs.tmux}/bin/tmux -f ${./tmux.conf} -L wezterm "\$@"
            EOF
            chmod +x $out/bin/wtmux
          '';
          weztermWrapper = pkgs.runCommand "wezterm" {} ''
            mkdir -p $out/bin
            cat > $out/bin/wezterm <<EOF
            #!${pkgs.bash}/bin/bash
            export WEZTERM_SHELL_INTEGRATION="${./shell-integration.sh}"
            export PATH="${wtmuxWrapper}/bin:\$PATH"
            exec ${wezterm.packages.${system}.default}/bin/wezterm \
              --config-file ${./wezterm.lua} "\$@"
            EOF
            chmod +x $out/bin/wezterm
          '';
        in
          pkgs.symlinkJoin {
            name = "wezterm";
            paths = [ weztermWrapper wtmuxWrapper ];
          };
    };
}
