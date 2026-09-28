defmodule Nuinsurance.Repo do
  use Ecto.Repo,
    otp_app: :nuinsurance,
    adapter: Ecto.Adapters.Postgres
end
