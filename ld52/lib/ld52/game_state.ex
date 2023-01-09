defmodule Ld52.GameState do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "game_state" do
    field :counter, :integer
    timestamps()
    has_many(:plot_states, Ld52.PlotState)
  end

  @doc false
  def changeset(game_state, attrs) do
    game_state
    |> cast(attrs, [:counter])
    |> validate_required([:counter])
  end
end
