defmodule Ld52.Repo.Migrations.AddGamestateTable do
  use Ecto.Migration

  def change do
    create table(:game_state, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :counter, :float

      timestamps()
    end
  end
end
