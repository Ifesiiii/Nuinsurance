defmodule Nuinsurance.Quotes do
  alias Nuinsurance.Repo
  alias Nuinsurance.Catalog.Product
  alias Nuinsurance.Quotes.QuoteRequest

  def create_quote_request(%Product{} = product, attrs) do
    %QuoteRequest{
      product_id: product.id,
      status: "pending"
    }
    |> QuoteRequest.changeset(attrs)
    |> Repo.insert()
  end
end
