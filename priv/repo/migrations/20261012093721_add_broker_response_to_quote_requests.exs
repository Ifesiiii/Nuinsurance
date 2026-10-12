defmodule Nuinsurance.Repo.Migrations.AddBrokerResponseToQuoteRequests do
  use Ecto.Migration

  def change do
    alter table(:quote_requests) do
      add :quote_amount, :decimal, precision: 12, scale: 2
      add :quote_currency, :string
      add :coverage_period, :string
      add :broker_response, :text
      add :quote_expires_on, :date
      add :responded_at, :utc_datetime
    end
  end
end
