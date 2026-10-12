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
  |> put_resp_header("cache-control", "no-store")
  |> put_status(:created)
  |> json(%{
    data: %{
      id: quote_request.id,
      status: quote_request.status,
      tracking_path: "/requests/#{quote_request.tracking_token}"
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
  def track(conn, %{"token" => token}) do
  conn = put_resp_header(conn, "cache-control", "no-store")

  case Quotes.get_request_by_tracking_token(token) do
    nil ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "Request not found"})

    request ->
      json(conn, %{
        data: %{
          id: request.id,
          product_name: request.product.name,
          status: request.status,
          submitted_at: request.inserted_at,
          response: response_data(request)
        }
      })
  end
end

defp response_data(%{status: "responded"} = request) do
  %{
    amount: Decimal.to_string(request.quote_amount, :normal),
    currency: request.quote_currency,
    coverage_period: request.coverage_period,
    message: request.broker_response,
    expires_on: request.quote_expires_on,
    responded_at: request.responded_at,
    expired:
      Date.compare(request.quote_expires_on, Date.utc_today()) == :lt
  }
end

defp response_data(_request), do: nil
end
