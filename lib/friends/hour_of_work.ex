defmodule Friends.HourOfWork do
  use Ecto.Schema

  schema "hour_or_work" do
    field :hours, :integer
    belongs_to :person, Friends.Person
  end

  def changeset(person, params \\ %{}) do
    person
    |> Ecto.Changeset.cast(params, [:hours])
    |> Ecto.Changeset.cast_assoc(:person, with: &Friends.Person.changeset/2)
    |> Ecto.Changeset.validate_required([:person, :hours])
  end
end
