defmodule ScalesCms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:scales_cms, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ScalesCms.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ScalesCms.Finch}
      # Start a worker by calling: ScalesCms.Worker.start_link(arg)
      # {ScalesCms.Worker, arg},
      # Start to serve requests, typically the last entry
    ]

    children =
      if Application.get_env(:scales_cms, :dev_mode),
        do:
          children ++
            [
              ScalesCms.Repo,
              ScalesCmsWeb.Endpoint
            ],
        else: children

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ScalesCms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ScalesCmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
