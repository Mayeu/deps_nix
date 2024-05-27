defmodule Mix.Tasks.Deps.NixTest do
  use ExUnit.Case, async: true

  test "produces a formatted Nix function for the fixture app's dependencies" do
    {run_output, run_status} =
      System.shell("mix deps.nix --env prod 2>&1",
        cd: "fixtures/example",
        env: %{"EMPTY_GIT_HASHES" => "please"}
      )

    assert run_status == 0, run_output

    assert {"«lambda @ " <> _, 0} =
             System.shell("nix eval --file deps.nix 2> /dev/null",
               cd: "fixtures/example"
             )

    {diff, diff_status} =
      System.shell("diff --unified deps.nix <(nixpkgs-fmt < deps.nix)",
        cd: "fixtures/example"
      )

    assert diff_status == 0, diff
  end
end
