defmodule BlueJet.Repo.Migrations.CreateOrderLineItem do
  use Ecto.Migration

  def change do
    create table(:order_line_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all), null: false

      add :name, :string
      add :print_name, :string
      add :label, :string
      add :description, :text

      add :is_leaf, :boolean, null: false, default: true

      add :price_name, :string
      add :price_label, :string
      add :price_caption, :string
      add :price_order_unit, :string
      add :price_charge_unit, :string
      add :price_currency_code, :string
      add :price_charge_amount_cents, :integer
      add :price_estimate_amount_cents, :integer
      add :price_maximum_amount_cents, :integer
      add :price_tax_one_rate, :integer
      add :price_tax_two_rate, :integer
      add :price_tax_three_rate, :integer
      add :price_end_time, :utc_datetime

      add :charge_quantity, :decimal
      add :order_quantity, :integer, null: false, default: 1

      add :sub_total_cents, :integer, null: false, default: 0
      add :tax_one_cents, :integer, null: false, default: 0
      add :tax_two_cents, :integer, null: false, default: 0
      add :tax_three_cents, :integer, null: false, default: 0
      add :grand_total_cents, :integer, null: false, default: 0

      add :is_estimate, :boolean, null: false, default: false

      add :custom_data, :map, null: false, default: "{}"
      add :translations, :map, null: false, default: "{}"

      add :parent_id, references(:order_line_items, type: :binary_id, on_delete: :delete_all)
      add :price_id, references(:prices, type: :binary_id)
      add :order_id, references(:orders, type: :binary_id, on_delete: :delete_all), null: false
      add :product_item_id, references(:product_items, type: :binary_id, on_delete: :nilify_all)
      add :product_id, references(:products, type: :binary_id, on_delete: :nilify_all)
      add :sku_id, references(:skus, type: :binary_id, on_delete: :nilify_all)
      add :unlockable_id, references(:unlockables, type: :binary_id, on_delete: :nilify_all)

      timestamps()
    end

    create index(:order_line_items, [:parent_id])
    create index(:order_line_items, [:account_id])
    create index(:order_line_items, [:order_id])
    create index(:order_line_items, [:price_id])
    create index(:order_line_items, [:product_item_id])
    create index(:order_line_items, [:product_id])
    create index(:order_line_items, [:unlockable_id])
    create index(:order_line_items, [:sku_id])
  end
end
