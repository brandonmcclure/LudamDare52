defmodule Ld52.Repo do
  use Ecto.Repo,
    otp_app: :ld52,
    adapter: Ecto.Adapters.Postgres
end
