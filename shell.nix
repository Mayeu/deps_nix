{ pkgs }:

with pkgs;

mkShell {
  packages =
    let
      release = writeShellApplication {
        name = "release";
        runtimeInputs = [ elixir_1_16 gh ];
        text = ''
          tag=$1

          gh auth login
          gh release create "$tag" --draft --generate-notes
          mix hex.publish
        '';
      };
    in
    [
      elixir_1_16
      (elixir_ls.override { elixir = elixir_1_16; })
      mix2nix # for comparison
      release
    ];
}
