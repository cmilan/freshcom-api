defmodule BlueJet.Repo.Migrations.CreateEmailTemplate do
  use Ecto.Migration

  def change do
    create table(:email_templates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all), null: false
      add :system_label, :string

      add :name, :string, null: false
      add :content, :text
      add :description, :text

      timestamps()
    end

    create index(:email_templates, [:account_id, :name])
  end
end
