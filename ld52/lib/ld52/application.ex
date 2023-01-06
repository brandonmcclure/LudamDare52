defmodule Ld52.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ld52.Repo,
      # Start the Telemetry supervisor
      Ld52Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ld52.PubSub},
      # Start the Endpoint (http/https)
      Ld52Web.Endpoint
      # Start a worker by calling: Ld52.Worker.start_link(arg)
      # {Ld52.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ld52.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Ld52Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
