defmodule Nuinsurance.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :coverage, :string
    field :exclusions, :string
    field :eligibility, :string
    field :conditions, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :coverage,
      :exclusions,
      :eligibility,
      :conditions
      ])
    |> validate_required([:name, :description])
  end
end
