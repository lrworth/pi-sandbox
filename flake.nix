{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    pi-flake.url = "github:earendil-works/pi/v1.6.0";
  };

  outputs =
    { nixpkgs, pi-flake, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
          linuxPkgs = nixpkgs.legacyPackages.${linuxSystem};

          pi = pi-flake.packages.${linuxSystem}.default;
        in
        {
          inherit pi;

          default = pkgs.dockerTools.streamLayeredImage {
            name = "pi-sandbox";
            tag = "latest";

            contents = with linuxPkgs; [
              pi
              bashInteractive
              coreutils
              diffutils
              findutils
              gawk
              git
              gnugrep
              gnused
              httpie
              jujutsu
              ripgrep
              dockerTools.binSh
              dockerTools.usrBinEnv
              dockerTools.caCertificates
              (writeTextDir "etc/passwd" "root:x:0:0:root:/root:/bin/sh\n")
              (writeTextDir "etc/group" "root:x:0:\n")
              (writeTextDir "etc/nsswitch.conf" "hosts: files dns\n")
            ];

            extraCommands = ''
              mkdir -p tmp root workspace
              chmod 1777 tmp
            '';

            config = {
              Entrypoint = [
                "/bin/sh"
                "-c"
                # jj 0.41 fails the first time you run it when .jj is mounted readonly, but succeeds after that.
                "${linuxPkgs.jujutsu}/bin/jj --ignore-working-copy status 2>/dev/null 1>/dev/null; exec ${pi}/bin/pi \"$@\""
                "pi"
              ];
              Env = [
                "PI_SKIP_VERSION_CHECK=1"
              ];
              WorkingDir = "/workspace";
            };
          };
        }
      );
    };
}
