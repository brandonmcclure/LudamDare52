defmodule Ld52.Repo.Migrations.AddPlotStateTable do
  use Ecto.Migration

  def change do
    create table(:plot_state, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :column, :integer
      add :row, :integer
      add :lastharvested, :utc_datetime
      add :game_state_id, references(:game_state, type: :binary_id), null: true
      timestamps()
    end
  end
end
