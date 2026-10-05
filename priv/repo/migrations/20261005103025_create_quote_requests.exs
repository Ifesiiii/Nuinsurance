defmodule Nuinsurance.Repo.Migrations.CreateQuoteRequests do
  use Ecto.Migration

  def change do
    create table(:quote_requests) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :message, :text, null: false
      add :status, :string, default: "pending", null: false

      add :product_id,
          references(:products, on_delete: :nothing),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:quote_requests, [:product_id])
  end
end
