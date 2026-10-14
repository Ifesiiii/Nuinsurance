defmodule NuinsuranceWeb.BrokerProductController do
  use NuinsuranceWeb, :controller

  alias Nuinsurance.Catalog

  def create(conn, %{"product" => attrs}) when is_map(attrs) do
    case Catalog.create_product(attrs) do
      {:ok, product} ->
        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            id: product.id,
            name: product.name,
            description: product.description
          },
          message: "Product added successfully."
        })

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
            Enum.reduce(opts, message, fn {key, value}, text ->
              String.replace(text, "%{#{key}}", to_string(value))
            end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected a product object."})
  end
end
