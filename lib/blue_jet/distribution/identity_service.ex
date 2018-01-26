defmodule BlueJet.Distribution.IdentityService do
  @identity_service Application.get_env(:blue_jet, :distribution)[:identity_service]

  @callback get_account(String.t | map) :: map

  defdelegate get_account(id_or_struct), to: @identity_service
end