defmodule BlueJet.Identity do
  use BlueJet, :context
  use BlueJet.EventEmitter, namespace: :identity

  alias BlueJet.Identity.{Authentication, Policy, Service}

  def create_token(%{ fields: fields }) do
    with {:ok, token} <- Authentication.create_token(fields) do
      {:ok, %AccessResponse{ data: token }}
    else
      {:error, errors} -> {:error, %AccessResponse{ errors: errors }}
    end
  end

  #
  # MARK: Account
  #
  # def list_account(request) do
  #   with {:ok, request} <- preprocess_request(request, "identity.list_account") do
  #     request
  #     |> do_list_account()
  #   else
  #     {:error, _} -> {:error, :access_denied}
  #   end
  # end

  # def do_list_account(request = %{ account: account, vas: %{ user_id: user_id } }) do
  #   accounts =
  #     Account
  #     |> Account.Query.has_member(user_id)
  #     |> Account.Query.live()
  #     |> Repo.all()
  #     |> Translation.translate(request.locale, account.default_locale)

  #   {:ok, %AccessResponse{ data: accounts, meta: %{ locale: request.locale } }}
  # end

  def get_account(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "get_account") do
      do_get_account(authorized_args)
    else
      other -> other
    end
  end

  def do_get_account(args) do
    case Service.get_account(args[:identifiers][:id]) do
      nil ->
        {:error, :not_found}

      account ->
        account = Translation.translate(account, args[:locale], args[:default_locale])
        {:ok, %AccessResponse{ data: account, meta: %{ locale: args[:locale] } }}
    end
  end

  def update_account(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "update_account") do
      do_update_account(authorized_args)
    else
      other -> other
    end
  end

  def do_update_account(args) do
    with {:ok, account} <- Service.update_account(args[:opts][:account], args[:fields], args[:opts]) do
      account = Translation.translate(account, args[:locale], args[:default_locale])
      {:ok, %AccessResponse{ meta: %{ locale: args[:locale] }, data: account }}
    else
      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}

      other -> other
    end
  end

  def reset_account(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "reset_account") do
      do_reset_account(authorized_args)
    else
      other -> other
    end
  end

  def do_reset_account(args) do
    account = args[:opts][:account]

    with {:ok, account} <- Service.reset_account(account) do
      account = Translation.translate(account, args[:locale], args[:default_locale])
      {:ok, %AccessResponse{ meta: %{ locale: args[:locale] }, data: account }}
    else
      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}

      other -> other
    end
  end

  #
  # MARK: Email Verification Token
  #
  def create_email_verification_token(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "create_email_verification_token") do
      do_create_email_verification_token(authorized_args)
    else
      other -> other
    end
  end

  def do_create_email_verification_token(args) do
    with {:ok, _} <- Service.create_email_verification_token(args[:fields], args[:opts]) do
      {:ok, %AccessResponse{}}
    else
      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}

      other -> other
    end
  end

  #
  # MARK: Email Verification
  #
  def create_email_verification(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "create_email_verification") do
      do_create_email_verification(authorized_args)
    else
      other -> other
    end
  end

  def do_create_email_verification(args) do
    with {:ok, _} <- Service.create_email_verification(args[:fields], args[:opts]) do
      {:ok, %AccessResponse{}}
    else
      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}

      other -> other
    end
  end

  #
  # MARK: Phone Verification Code
  #
  def create_phone_verification_code(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "create_phone_verification_code") do
      do_create_phone_verification_code(authorized_args)
    else
      other -> other
    end
  end

  def do_create_phone_verification_code(args) do
    with {:ok, _} <- Service.create_phone_verification_code(args[:fields], args[:opts]) do
      {:ok, %AccessResponse{}}
    else
      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}

      other -> other
    end
  end

  #
  # MARK: Password Reset Token
  #
  def create_password_reset_token(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "create_password_reset_token") do
      do_create_password_reset_token(authorized_args)
    else
      other -> other
    end
  end

  def do_create_password_reset_token(args) do
    with {:ok, _} <- Service.create_password_reset_token(args[:fields], args[:opts]) do
      {:ok, %AccessResponse{}}
    else
      {:error, :not_found} ->
        {:ok, %AccessResponse{}}

      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}
    end
  end

  #
  # MARK: Password
  #
  def update_password(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "update_password") do
      do_update_password(authorized_args)
    else
      other -> other
    end
  end

  def do_update_password(args) do
    with {:ok, _} <- Service.update_password(args[:identifiers], args[:fields]["value"], args[:opts]) do
      {:ok, %AccessResponse{}}
    else
      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}

      other -> other
    end
  end

  #
  # MARK: Refresh Token
  #
  def get_refresh_token(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "get_refresh_token") do
      do_get_refresh_token(authorized_args)
    else
      other -> other
    end
  end

  def do_get_refresh_token(args) do
    case Service.get_refresh_token(args[:opts]) do
      nil ->
        {:error, :not_found}

      refresh_token ->
        {:ok, %AccessResponse{ data: refresh_token }}
    end
  end

  #
  # MARK: User
  #
  def create_user(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "create_user") do
      do_create_user(authorized_args)
    else
      other -> other
    end
  end

  def do_create_user(args) do
    with {:ok, user} <- Service.create_user(args[:fields], args[:opts]) do
      user = if user.account_id do
        Translation.translate(user, args[:locale], args[:default_locale])
      else
        user
      end

      {:ok, %AccessResponse{ data: user }}
    else
      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}
    end
  end

  def get_user(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "get_user") do
      do_get_user(authorized_args)
    else
      other -> other
    end
  end

  def do_get_user(args) do
    case Service.get_user(args[:identifiers], args[:opts]) do
      nil ->
        {:error, :not_found}

      user ->
        user = if user.account_id do
          Translation.translate(user, args[:locale], args[:default_locale])
        else
          user
        end

        {:ok, %AccessResponse{ data: user }}
    end
  end

  def update_user(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "update_user") do
      do_update_user(authorized_args)
    else
      other -> other
    end
  end

  def do_update_user(args) do
    with {:ok, user} <- Service.update_user(args[:id], args[:fields], args[:opts]) do
      user = if user.account_id do
        Translation.translate(user, args[:locale], args[:default_locale])
      else
        user
      end

      {:ok, %AccessResponse{ meta: %{ locale: args[:locale] }, data: user }}
    else
      {:error, %{ errors: errors }} ->
        {:error, %AccessResponse{ errors: errors }}

      other -> other
    end
  end

  def delete_user(request) do
    with {:ok, authorized_args} <- Policy.authorize(request, "delete_user") do
      do_delete_user(authorized_args)
    else
      other -> other
    end
  end

  def do_delete_user(args) do
    with {:ok, _} <- Service.delete_user(args[:id], args[:opts]) do
      {:ok, %AccessResponse{}}
    else
      other -> other
    end
  end
end
