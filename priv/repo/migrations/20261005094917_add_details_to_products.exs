defmodule Nuinsurance.Repo.Migrations.AddDetailsToProducts do
  use Ecto.Migration

  defmodule Nuinsurance.Repo.Migrations.AddDetailsToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :coverage, :text
      add :exclusions, :text
      add :eligibility, :text
      add :conditions, :text
    end
  end
end
end
