defmodule NuinsuranceWeb.ProductController do
  use NuinsuranceWeb, :controller

  alias Nuinsurance.Catalog

  def index(conn, _params) do
    products =
      Catalog.list_products()
      |> Enum.map(fn product ->
        %{
          id: product.id,
          name: product.name,
          description: product.description
        }
      end)

    json(conn, %{data: products})
  end
end
