defmodule Friends.Repo.Migrations.CreateHourOfWork do
  use Ecto.Migration

  def change do
    create table(:hour_of_work) do
      add :hours, :integer
      add :person, references(:people)
    end

  end
end
