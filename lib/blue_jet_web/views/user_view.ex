defmodule BlueJetWeb.UserView do
  use BlueJetWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :email,
    :username,
    :first_name,
    :last_name,
    :name,
    :role,
    :email_confirmed,
    :inserted_at,
    :updated_at
  ]

  has_one :account, serializer: BlueJetWeb.AccountView, identifiers: :always

  def type do
    "User"
  end

  def account(%{ account_id: nil }, _) do
    nil
  end

  def account(%{ account_id: account_id, account: %Ecto.Association.NotLoaded{} }, _) do
    %{ id: account_id, type: "Account" }
  end

  def account(%{ account: account }, _), do: account
end
