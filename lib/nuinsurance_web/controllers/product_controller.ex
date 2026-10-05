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

  def show(conn, %{"id" => id}) do
  with {product_id, ""} <- Integer.parse(id),
       true <- product_id > 0 and product_id <= 9_223_372_036_854_775_807,
       product when not is_nil(product) <-
         Nuinsurance.Catalog.get_product(product_id) do
    json(conn, %{
      data: %{
        id: product.id,
        name: product.name,
        description: product.description,
        coverage: product.coverage,
        exclusions: product.coverage,
        eligibility: product.eligibility,
        conditions: product.conditions
      }
    })
  else
    _ ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "Product not found"})
  end
end
end
