defmodule Nuinsurance.Quotes.QuoteRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quote_requests" do
    field :name, :string
    field :email, :string
    field :message, :string
    field :status, :string, default: "pending"
    field :tracking_token, :string, redact: true
    field :quote_amount, :decimal
    field :quote_currency, :string
    field :coverage_period, :string
    field :broker_response, :string
    field :quote_expires_on, :date
    field :responded_at, :utc_datetime



    belongs_to :product, Nuinsurance.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  def changeset(quote_request, attrs) do
    quote_request
    |> cast(attrs, [:name, :email, :message])
    |> validate_required([:name, :email, :message, :product_id, :tracking_token])
    |> validate_length(:name, max: 100)
    |> validate_length(:email, max: 254)
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      message: "must be a valid email address"
    )
    |> validate_length(:message, max: 2000)
    |> foreign_key_constraint(:product_id)
    |> unique_constraint(:tracking_token)
  end

  def response_changeset(quote_request, attrs) do
  quote_request
  |> cast(attrs, [
    :quote_amount,
    :quote_currency,
    :coverage_period,
    :broker_response,
    :quote_expires_on
  ])
  |> validate_required([
    :quote_amount,
    :quote_currency,
    :coverage_period,
    :broker_response,
    :quote_expires_on
  ])
  |> validate_number(:quote_amount,
    greater_than: 0,
    less_than: 10_000_000_000
  )
  |> validate_inclusion(:quote_currency, ["NGN"])
  |> validate_length(:coverage_period, max: 100)
  |> validate_length(:broker_response, max: 5000)
  |> put_change(:status, "responded")
  |> put_change(
    :responded_at,
    DateTime.utc_now() |> DateTime.truncate(:second)
  )
  end
end
