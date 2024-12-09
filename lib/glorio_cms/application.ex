defmodule GlorioCms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:glorio_cms, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GlorioCms.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GlorioCms.Finch}
      # Start a worker by calling: GlorioCms.Worker.start_link(arg)
      # {GlorioCms.Worker, arg},
      # Start to serve requests, typically the last entry
    ]

    children =
      if Mix.env() == :dev or Mix.env() == :test,
        do:
          children ++
            [
              GlorioCms.Repo,
              GlorioCmsWeb.Endpoint
            ],
        else: children

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GlorioCms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GlorioCmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
