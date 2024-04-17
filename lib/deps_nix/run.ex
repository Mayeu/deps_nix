defmodule DepsNix.Run do
  alias DepsNix.Packages
  alias DepsNix.Util

  defmodule Options do
    @type t :: %Options{envs: map(), output: String.t()}
    defstruct envs: %{}, output: "deps.nix"
  end

  @type converger :: (Keyword.t() -> list(Mix.Dep.t()))

  @spec call(Options.t(), converger()) ::
          {path :: String.t(), output :: String.t()}
  def call(opts, converger) do
    opts
    |> convert_opts()
    |> Enum.flat_map(fn {converger_opts, permitted_names} ->
      all_packages_for_env = converger.(converger_opts)
      Packages.filter(all_packages_for_env, permitted_names)
    end)
    |> Enum.sort_by(& &1.app)
    |> Enum.uniq()
    |> Enum.map(&DepsNix.transform/1)
    |> Enum.join("\n")
    |> Util.indent()
    |> Util.indent()
    |> wrap(opts.output)
  end

  @spec parse_args(list()) :: Options.t()
  def parse_args(args) do
    args
    |> OptionParser.parse(strict: [env: [:string, :keep], output: :string])
    |> to_opts()
  end

  @spec to_opts({list(), any(), any()}) :: Options.t()
  defp to_opts({[], _, _}) do
    %Options{envs: %{"prod" => :all}}
  end

  defp to_opts({opts, _, _}) do
    %Options{
      envs:
        for {:env, env} <- opts, into: %{} do
          case String.split(env, "=", parts: 2) do
            [env] ->
              {env, :all}

            [env, ""] ->
              {env, []}

            [env, packages] ->
              {env, String.split(packages, ",")}
          end
        end
    }
    |> add_output(opts)
  end

  defp convert_opts(%Options{envs: envs}) do
    for {strenv, packages} <- envs do
      env = String.to_existing_atom(strenv)
      {[env: env], packages}
    end
  end

  defp add_output(options, parsed_args) do
    case Keyword.get(parsed_args, :output) do
      nil ->
        options

      output ->
        %Options{options | output: output}
    end
  end

  defp wrap(pkgs, output) do
    {
      output,
      """
      { lib, beamPackages, overrides ? (x: y: { }) }:

      let
        buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
        buildMix = lib.makeOverridable beamPackages.buildMix;
        buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

        self = packages // (overrides self packages);

        packages = with beamPackages; with self; {
      #{pkgs}  };
      in
      self
      """
      |> String.trim()
    }
  end
end
