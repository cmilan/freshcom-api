defmodule BlueJet.Distribution.CrmService do
  alias BlueJet.Crm.{Customer, PointAccount, PointTransaction}

  @crm_service Application.get_env(:blue_jet, :distribution)[:crm_service]

  @callback get_customer(map, map) :: Customer.t | nil
  @callback get_point_account(map, map) :: PointAccount.t | nil
  @callback create_point_transaction(map, map) :: {:ok, PointTransaction.t} | {:error, any}
  @callback update_point_transaction(String.t, map, map) :: {:ok, PointTransaction.t} | {:error, any}

  defdelegate get_customer(fields, opts), to: @crm_service
  defdelegate get_point_account(fields, opts), to: @crm_service
  defdelegate create_point_transaction(fields, opts), to: @crm_service
  defdelegate update_point_transaction(id, fields, opts), to: @crm_service
end