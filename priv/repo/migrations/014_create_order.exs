defmodule BlueJet.Repo.Migrations.CreateOrder do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all), null: false

      add :customer_id, references(:customers, type: :binary_id, on_delete: :nilify_all)
      add :user_id, references(:users, type: :binary_id)

      add :status, :string, null: false
      add :code, :string
      add :name, :string
      add :label, :string

      add :payment_status, :string, null: false, default: "pending"
      add :fulfillment_status, :string, null: false, default: "pending"
      add :fulfillment_method, :string
      add :system_tag, :string

      add :email, :string
      add :first_name, :string
      add :last_name, :string
      add :phone_number, :string

      add :sub_total_cents, :integer, null: false, default: 0
      add :tax_one_cents, :integer, null: false, default: 0
      add :tax_two_cents, :integer, null: false, default: 0
      add :tax_three_cents, :integer, null: false, default: 0
      add :grand_total_cents, :integer, null: false, default: 0
      add :authorization_total_cents, :integer, null: false, default: 0
      add :is_estimate, :boolean, null: false, default: false

      add :delivery_address_line_one, :string
      add :delivery_address_line_two, :string
      add :delivery_address_province, :string
      add :delivery_address_city, :string
      add :delivery_address_country_code, :string
      add :delivery_address_postal_code, :string

      add :opened_at, :utc_datetime
      add :confirmation_email_sent_at, :utc_datetime
      add :receipt_email_sent_at, :utc_datetime

      add :caption, :string
      add :description, :text
      add :custom_data, :map, null: false, default: "{}"
      add :translations, :map, null: false, default: "{}"

      timestamps()
    end

    create unique_index(:orders, [:account_id, :code], where: "code IS NOT NULL")
    create index(:orders, [:account_id, :label], where: "label IS NOT NULL")
    create index(:orders, [:account_id, :payment_status])
    create index(:orders, [:account_id, :fulfillment_status])
    create index(:orders, [:account_id, :email], where: "email IS NOT NULL")
    create index(:orders, [:account_id, :customer_id], where: "customer_id IS NOT NULL")
    create index(:orders, [:account_id, :user_id], where: "user_id IS NOT NULL")
  end
end
