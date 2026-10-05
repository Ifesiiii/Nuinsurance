defmodule Nuinsurance.Quotes.QuoteRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quote_requests" do
    field :name, :string
    field :email, :string
    field :message, :string
    field :status, :string, default: "pending"

    belongs_to :product, Nuinsurance.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  def changeset(quote_request, attrs) do
    quote_request
    |> cast(attrs, [:name, :email, :message])
    |> validate_required([:name, :email, :message, :product_id])
    |> validate_length(:name, max: 100)
    |> validate_length(:email, max: 254)
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      message: "must be a valid email address"
    )
    |> validate_length(:message, max: 2000)
    |> foreign_key_constraint(:product_id)
  end
end
