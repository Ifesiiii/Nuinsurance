defmodule NuinsuranceWeb.QuoteRequestController do
  use NuinsuranceWeb, :controller

  alias Nuinsurance.Catalog
  alias Nuinsurance.Quotes

  def create(conn, %{
        "product_id" => id,
        "quote_request" => attrs
      })
      when is_map(attrs) do
    with {product_id, ""} <- Integer.parse(id),
         true <- product_id > 0 and product_id <= 9_223_372_036_854_775_807,
         product when not is_nil(product) <-
           Catalog.get_product(product_id) do
      case Quotes.create_quote_request(product, attrs) do
        {:ok, quote_request} ->
          conn
          |> put_status(:created)
          |> json(%{
            data: %{
              id: quote_request.id,
              status: quote_request.status
            },
            message: "Your quote request has been submitted."
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
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Product not found"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected a quote_request object."})
  end
end
