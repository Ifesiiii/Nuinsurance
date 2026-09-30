defmodule Nuinsurance.Catalog do
  import Ecto.Query

  alias Nuinsurance.Repo
  alias Nuinsurance.Catalog.Product

  def list_products do
    Product
    |> order_by([product], asc: product.id)
    |> Repo.all()
  end
end
