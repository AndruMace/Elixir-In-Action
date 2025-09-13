defmodule ElixirInAction.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_in_action,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :observer,
        :wx,
        :runtime_tools
      ],
      mod: {Todo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:plug_cowboy, "~> 2.7"}
    ]
  end
end
