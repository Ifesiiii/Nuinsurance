# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Nuinsurance.Repo.insert!(%Nuinsurance.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


alias Nuinsurance.Repo
alias Nuinsurance.Catalog.Product

products = [
  %{
    name: "Health Plan",
    description:
      "Explore health insurance options for your medical needs and everyday wellbeing."
  },
  %{
    name: "Car Insurance",
    description:
      "Explore insurance options for your car, wherever the road takes you."
  },
  %{
    name: "Pet Health",
    description:
      "Explore health cover for your pet and the veterinary care they may need."
  },
  %{
    name: "Home Protection Plan",
    description:
      "Explore insurance options for your home and the belongings that make it yours."
  }
]

Enum.each(products, fn attrs ->
  case Repo.get_by(Product, name: attrs.name) do
    nil ->
      %Product{}
      |> Product.changeset(attrs)
      |> Repo.insert!()

    _existing_product ->
      :ok
  end
end)
