defmodule FriendsTest do
  use ExUnit.Case
  doctest Friends
  require Ecto.Query
  alias Ecto.Multi


  def count_people do
    Ecto.Query.from(p in Friends.Person,
      select: count(p.id))
    |> Friends.Repo.one
  end

  test "greets the world" do
    Friends.Repo.delete_all(Friends.Person)
    %Friends.Person{}
    |> Friends.Person.changeset(%{first_name: "Pippo", last_name: "Lippo", age: 13})
    |> Friends.Repo.insert

    people = [
      %Friends.Person{first_name: "Ryan", last_name: "Bigg", age: 28},
      %Friends.Person{first_name: "John", last_name: "Smith", age: 27},
      %Friends.Person{first_name: "Jane", last_name: "Smith", age: 26},
    ]
    Enum.each(people, fn (person) -> Friends.Repo.insert(person) end)

    Friends.Person
    |> Friends.Repo.all
    |> IO.inspect()

    assert (
      Ecto.Query.from(p in Friends.Person,
        select: count(p.id),
        where: p.last_name == "Lippo")
      |> Friends.Repo.one) == 1


    Friends.Person
    |> Ecto.Query.select([p], avg(p.age))
    |> Ecto.Query.where([p], p.age > 26)
    |> Friends.Repo.one
    |> IO.inspect

    # Select all person whose age is greater than the average
    query_avg = Friends.Person
    |> Ecto.Query.select([p], avg(p.age))

    IO.inspect(query_avg |> Friends.Repo.one)

    Friends.Person
    |> Ecto.Query.where([p], p.age > subquery(query_avg))
    |> Friends.Repo.all
    |> IO.inspect()

    # Transaction fails so no person is deleted
    count_people() |> IO.inspect()
    Multi.new()
    |> Multi.delete_all(:people, Friends.Person)
    |> Multi.insert(:reinsert,
      %Friends.Person{}
      |> Friends.Person.changeset(%{first_name: "Pippo", age: 13})
    )
    |> Friends.Repo.transaction
    |> IO.inspect
    count_people() |> IO.inspect()

    # This transaction is valid

    Multi.new()
    |> Multi.delete_all(:people, Friends.Person)
    |> Multi.insert(:reinsert,
      %Friends.Person{}
      |> Friends.Person.changeset(%{first_name: "Pippo", last_name: "Lippo", age: 13})
    )
    |> Friends.Repo.transaction
    |> IO.inspect
    count_people() |> IO.inspect()


    p = Friends.Person |> Ecto.Query.first |> Friends.Repo.one
    %Friends.HourOfWork{}
    |> Friends.HourOfWork.changeset(%{person: p, hours: 10})
    |> Friends.Repo.insert
    |> IO.inspect
  end
end
