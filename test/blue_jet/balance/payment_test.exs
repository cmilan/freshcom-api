defmodule BlueJet.Balance.PaymentTest do
  use BlueJet.DataCase

  import Mox

  alias BlueJet.Identity.Account
  alias BlueJet.Balance.{Payment, Settings}
  alias BlueJet.Balance.{StripeClientMock, IdentityServiceMock, CrmServiceMock}

  test "writable_fields/0" do
    assert Payment.writable_fields() == [
      :status,
      :code,
      :label,
      :gateway,
      :processor,
      :method,
      :amount_cents,
      :billing_address_line_one,
      :billing_address_line_two,
      :billing_address_province,
      :billing_address_city,
      :billing_address_country_code,
      :billing_address_postal_code,
      :caption,
      :description,
      :custom_data,
      :translations,
      :stripe_customer_id,
      :owner_id,
      :owner_type,
      :target_id,
      :target_type,
      :source,
      :save_source,
      :capture,
      :capture_amount_cents
    ]
  end

  describe "validate/1" do
    test "when missing required fields" do
      changeset =
        change(%Payment{}, %{})
        |> Payment.validate()

      refute changeset.valid?
      assert Keyword.keys(changeset.errors) == [
        :status,
        :gateway,
        :amount_cents
      ]
    end

    test "when missing required fields for freshcom gateway" do
      changeset =
        change(%Payment{}, %{ gateway: "online" })
        |> Payment.validate()

      refute changeset.valid?
      assert Keyword.keys(changeset.errors) == [
        :status,
        :amount_cents,
        :processor
      ]
    end

    test "when paid amount cents greater than authorization amount cents" do
      changeset =
        change(%Payment{ gateway: "freshcom", processor: "stripe", status: "authorized", amount_cents: 500 }, %{ capture_amount_cents: 501 })
        |> Payment.validate()

      refute changeset.valid?
      assert Keyword.keys(changeset.errors) == [
        :capture_amount_cents
      ]
    end
  end

  describe "changeset/4" do
    test "when there is no primary card saved by owner" do
      IdentityServiceMock
      |> expect(:get_account, fn(_) -> %Account{} end)

      changeset = Payment.changeset(%Payment{}, :update, %{
        amount_cents: 5000,
        gateway: "online",
        processor: "stripe"
      })

      verify!()
      assert changeset.changes[:gross_amount_cents] == 5000
      assert changeset.changes[:net_amount_cents] == 5000
    end
  end

  describe "preprocess/1" do
    test "when source is changed" do
      account = %Account{}
      owner = %{
        id: Ecto.UUID.generate(),
        email: Faker.Internet.safe_email(),
        name: Faker.Name.name(),
        stripe_customer_id: nil
      }
      stripe_customer = %{
        "id" => Faker.String.base64(12)
      }

      changeset = change(%Payment{}, %{
        account: account,
        owner_id: owner.id,
        owner_type: "Customer",
        source: Faker.String.base64(12)
      })

      StripeClientMock
      |> expect(:post, fn(_, _, _) -> {:ok, stripe_customer} end)

      CrmServiceMock
      |> expect(:get_customer, fn(_, _) ->
          owner
         end)
      |> expect(:update_customer, fn(_, _, _) ->
          {:ok, owner}
         end)

      {:ok, changeset} = Payment.preprocess(changeset)

      assert changeset.changes[:stripe_customer_id] == stripe_customer["id"]
    end
  end

  describe "process/1" do
    test "when when payment use freshcom gateway and capture is false" do
      account = Repo.insert!(%Account{})
      IdentityServiceMock
      |> expect(:get_account, fn(_) -> account end)

      stripe_customer_id = Faker.String.base64(12)
      stripe_card_id = "card_" <> Faker.String.base64(12)
      stripe_charge = %{
        "captured" => false,
        "id" => Faker.String.base64(5),
        "amount" => 500
      }
      StripeClientMock
      |> expect(:post, fn(_, _, _) -> {:ok, stripe_charge} end)

      Repo.insert!(%Settings{
        account_id: account.id
      })
      payment = Repo.insert!(%Payment{
        account_id: account.id,
        status: "paid",
        source: stripe_card_id,
        gateway: "freshcom",
        processor: "stripe",
        amount_cents: 500,
        stripe_customer_id: stripe_customer_id,
        capture: false
      })

      changeset = change(%Payment{}, %{ amount_cents: 500 })
      Payment.process(payment, changeset)

      verify!()
    end
  end
end
