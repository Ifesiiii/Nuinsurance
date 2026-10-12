defmodule Nuinsurance.Quotes do
  alias Nuinsurance.Repo
  alias Nuinsurance.Catalog.Product
  alias Nuinsurance.Quotes.QuoteRequest

 def create_quote_request(%Product{} = product, attrs) do
  token =
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)

  %QuoteRequest{
    product_id: product.id,
    status: "pending",
    tracking_token: token
  }
  |> QuoteRequest.changeset(attrs)
  |> Repo.insert()
end


def get_request_by_tracking_token(token) when is_binary(token) do
  if Regex.match?(~r/\A[A-Za-z0-9_-]{43}\z/, token) do
    QuoteRequest
    |> Repo.get_by(tracking_token: token)
    |> Repo.preload(:product)
  else
    nil
  end
end

def respond_to_quote_request(%QuoteRequest{} = request, attrs) do
  request
  |> QuoteRequest.response_changeset(attrs)
  |> Repo.update()
end
end



# result =
#   Quotes.respond_to_quote_request(request, %{
#     quote_amount: "75000.00",
#     quote_currency: "NGN",
#     coverage_period: "12 months",
#     broker_response: "Demo quote for testing only. This quote covers 12 months.",
#     quote_expires_on: Date.add(Date.utc_today(), 14)
#   })
