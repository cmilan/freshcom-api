defmodule BlueJet.Identity.Policy do
  alias BlueJet.AccessRequest
  alias BlueJet.Identity.Service

  #
  # MARK: Account
  #
  def authorize(%{ role: role }, "get_account") when role in ["anonymous"] do
    {:error, :access_denied}
  end

  def authorize(request = %{ role: role, account: account }, "get_account") when not is_nil(role) do
    authoirzed_args = AccessRequest.to_authorized_args(request, :get)
    identifiers = Map.merge(authoirzed_args[:identifiers], %{ id: account.id })
    authoirzed_args = %{ authoirzed_args | identifiers: identifiers }

    {:ok, authoirzed_args}
  end

  def authorize(request = %{ role: role }, "update_account") when role in ["developer", "administrator"] do
    {:ok, AccessRequest.to_authorized_args(request, :update)}
  end

  def authorize(request = %{ role: role }, "reset_account") when role in ["developer", "administrator"] do
    {:ok, AccessRequest.to_authorized_args(request, :update)}
  end

  #
  # MARK: Email Verification Token
  #
  def authorize(%{ role: role }, "create_email_verification_token") when role in ["anonymous", "guest"] do
    {:error, :access_denied}
  end

  def authorize(request = %{ role: role }, "create_email_verification_token") when not is_nil(role) do
    {:ok, AccessRequest.to_authorized_args(request, :create)}
  end

  #
  # MARK: Email Verification
  #
  def authorize(%{ role: role }, "create_email_verification") when role in ["anonymous", "guest"] do
    {:error, :access_denied}
  end

  def authorize(request = %{ role: role }, "create_email_verification") when not is_nil(role) do
    {:ok, AccessRequest.to_authorized_args(request, :create)}
  end

  #
  # MARK: Phone Verification Code
  #
  def authorize(%{ role: role }, "create_phone_verification_code") when role in ["anonymous"] do
    {:error, :access_denied}
  end

  def authorize(request = %{ role: role }, "create_phone_verification_code") when not is_nil(role) do
    {:ok, AccessRequest.to_authorized_args(request, :create)}
  end

  #
  # MARK: Password Reset Token
  #
  def authorize(request = %{ role: role }, "create_password_reset_token") when not is_nil(role) do
    {:ok, AccessRequest.to_authorized_args(request, :create)}
  end

  #
  # MARK: Password
  #
  def authorize(request = %{ role: role }, "update_password") when not is_nil(role) do
    authorized_args = AccessRequest.to_authorized_args(request, :update)

    identifiers = Map.merge(authorized_args[:identifiers], %{ reset_token: authorized_args[:fields]["reset_token"] })
    authorized_args = %{ authorized_args | identifiers: identifiers}

    {:ok, authorized_args}
  end

  #
  # MARK: Refresh Token
  #
  def authorize(request = %{ role: role }, "get_refresh_token") when role in ["developer", "administrator"] do
    {:ok, AccessRequest.to_authorized_args(request, :get)}
  end

  #
  # MARK: User
  #
  def authorize(request = %{ role: "guest" }, "create_user") do
    authorized_args = AccessRequest.to_authorized_args(request, :create)

    fields = Map.merge(authorized_args[:fields], %{ "role" => "customer" })
    authorized_args = %{ authorized_args | fields: fields }

    {:ok, authorized_args}
  end

  def authorize(request = %{ role: role }, "create_user") when role in ["anonymous", "developer", "administrator"] do
    {:ok, AccessRequest.to_authorized_args(request, :create)}
  end

  def authorize(%{ role: role }, "get_user") when role in ["anonymous", "guest"] do
    {:error, :access_denied}
  end

  def authorize(request = %{ role: role, user: user }, "get_user") when role in ["developer", "administrator"] do
    authorized_args = AccessRequest.to_authorized_args(request, :get)

    id = authorized_args[:identifiers][:id] || user.id
    identifiers = %{ authorized_args[:identifiers] | id: id }
    authorized_args = %{ authorized_args | identifiers: identifiers }

    {:ok, authorized_args}
  end

  def authorize(request = %{ role: role, user: user }, "get_user") when not is_nil(role) do
    authorized_args = AccessRequest.to_authorized_args(request, :get)

    identifiers = Map.merge(authorized_args[:identifiers], %{ id: user.id })
    authorized_args = %{ authorized_args | identifiers: identifiers }

    {:ok, authorized_args}
  end

  def authorize(%{ role: role }, "update_user") when role in ["anonymous", "guest"] do
    {:error, :access_denied}
  end

  def authorize(request = %{ role: role, user: user }, "update_user") when role in ["developer", "administrator"] do
    authorized_args = AccessRequest.to_authorized_args(request, :update)

    id = authorized_args[:id] || user.id
    authorized_args = %{ authorized_args | id: id }

    {:ok, authorized_args}
  end

  def authorize(request = %{ role: role, user: user }, "update_user") when not is_nil(role) do
    authorized_args = AccessRequest.to_authorized_args(request, :update)
    authorized_args = %{ authorized_args | id: user.id }

    {:ok, authorized_args}
  end

  def authorize(request = %{ role: role }, "delete_user") when role in ["developer", "administrator"] do
    {:ok, AccessRequest.to_authorized_args(request, :delete)}
  end

  #
  # MARK: Other
  #
  def authorize(request = %{ role: nil }, endpoint) do
    request
    |> Service.put_vas_data()
    |> authorize(endpoint)
  end

  def authorize(_, _) do
    {:error, :access_denied}
  end
end
