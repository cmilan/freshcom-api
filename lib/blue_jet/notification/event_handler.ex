defmodule BlueJet.Notification.EventHandler do
  alias BlueJet.Repo
  alias BlueJet.Notification.Service
  alias BlueJet.GlobalMailer
  alias BlueJet.Notification.{Trigger, Email}

  @behaviour BlueJet.EventHandler

  # Creates the default email template and notification trigger for account when
  # an account is first created.
  def handle_event("identity.account.create.success", %{ account: account, test_account: test_account }) do
    Service.create_system_default_trigger(%{ account: account })
    Service.create_system_default_trigger(%{ account: test_account })

    {:ok, nil}
  end

  def handle_event("identity.email_verification_token.create.success", %{ user: %{ account_id: nil } }) do
    {:ok, nil}
  end

  def handle_event("identity.password_reset_token.create.success", %{ user: user = %{ account_id: nil } }) do
    Email.Factory.password_reset_email(user)
    |> GlobalMailer.deliver_later()

    {:ok, nil}
  end

  def handle_event("identity.password_reset_token.create.error.email_not_found", %{ email: email, account_id: nil }) do
    Email.Factory.password_reset_not_registered_email(email)
    |> GlobalMailer.deliver_later()

    {:ok, nil}
  end

  def handle_event(event, data = %{ account: account }) when not is_nil(account) do
    triggers =
      Trigger.Query.default()
      |> Trigger.Query.for_account(account.id)
      |> Trigger.Query.filter_by(%{ event: event })
      |> Repo.all()

    Enum.each(triggers, fn(trigger) ->
      Trigger.fire_action(trigger, data)
    end)

    {:ok, nil}
  end

  def handle_event(_, _) do
    {:ok, nil}
  end
end