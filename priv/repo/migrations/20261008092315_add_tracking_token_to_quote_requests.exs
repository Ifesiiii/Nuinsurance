defmodule Nuinsurance.Repo.Migrations.AddTrackingTokenToQuoteRequests do
  use Ecto.Migration

  def up do
    alter table(:quote_requests) do
      add :tracking_token, :string
    end

    flush()

    # Give existing requests their own tokens.
    %{rows: rows} =
      repo().query!("SELECT id FROM quote_requests")

    Enum.each(rows, fn [id] ->
      token =
        :crypto.strong_rand_bytes(32)
        |> Base.url_encode64(padding: false)

      repo().query!(
        "UPDATE quote_requests SET tracking_token = $1 WHERE id = $2",
        [token, id]
      )
    end)

    alter table(:quote_requests) do
      modify :tracking_token, :string, null: false
    end

    create unique_index(:quote_requests, [:tracking_token])
  end

  def down do
    drop unique_index(:quote_requests, [:tracking_token])

    alter table(:quote_requests) do
      remove :tracking_token
    end
  end
end