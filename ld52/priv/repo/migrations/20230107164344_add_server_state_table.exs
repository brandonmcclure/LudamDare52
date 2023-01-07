defmodule Ld52.Repo.Migrations.AddServerStateTable do
  use Ecto.Migration

  def change do
    create table(:server_state, primary_key: false) do
      add :id, :integer, primary_key: true
      add :hourssincecreation, :integer
      add :realsecondspergamehour, :integer

      timestamps()
    end
  end
end
