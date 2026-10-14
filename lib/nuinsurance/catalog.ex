defmodule Nuinsurance.Catalog do
  import Ecto.Query

  alias Nuinsurance.Repo
  alias Nuinsurance.Catalog.Product

  def list_products do
    Product
    |> order_by([product], asc: product.id)
    |> Repo.all()
  end

  def get_product(id) do
    Repo.get(Product, id)
  end

  def create_product(attrs) do
  %Product{}
  |> Product.changeset(attrs)
  |> Repo.insert()
end
end
