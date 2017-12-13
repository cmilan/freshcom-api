defmodule BlueJet.Repo.Migrations.CreateStockable do
  use Ecto.Migration

  def change do
    create table(:stockables, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all), null: false
      add :avatar_id, references(:external_files, type: :binary_id, on_delete: :nilify_all)
      add :code, :string
      add :status, :string, null: false
      add :name, :string, null: false
      add :print_name, :string, null: false
      add :unit_of_measure, :string, null: false
      add :variable_weight, :boolean, null: false, default: false

      add :storage_type, :string
      add :storage_size, :integer, null: false, default: 0
      add :stackable, :boolean, null: false, default: false

      add :caption, :string
      add :description, :text
      add :specification, :text
      add :storage_description, :text

      add :custom_data, :map, null: false, default: "{}"
      add :translations, :map, null: false, default: "{}"

      timestamps()
    end

    create unique_index(:stockables, [:account_id, :code], where: "code IS NOT NULL")
    create unique_index(:stockables, [:account_id, :print_name])
    create index(:stockables, [:account_id, :name])
    create index(:stockables, [:account_id, :status])
  end
end