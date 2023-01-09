defmodule Ld52.PlotState do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plot_state" do
    field :column, :integer
    field :row, :integer
    field :lastharvested, :utc_datetime
    belongs_to :game_state, Ld52.GameState, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(plot_state, attrs) do
    plot_state
    |> cast(attrs, [:column, :row, :lastharvested])
    |> validate_required([:column, :row, :lastharvested])
  end
end
