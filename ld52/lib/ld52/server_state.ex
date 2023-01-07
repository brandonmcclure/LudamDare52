defmodule Ld52.ServerState do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :integer
  schema "server_state" do
    field :hourssincecreation, :integer
    field :realsecondspergamehour, :integer
    timestamps()
  end

  @doc false
  def changeset(server_state, attrs) do
    server_state
    |> cast(attrs, [:hourspast, :realsecondspergamehour])
    |> validate_required([:hourspast, :realsecondspergamehour])
  end
end
