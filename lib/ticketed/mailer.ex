defmodule Ticketed.Mailer do
  use Swoosh.Mailer, otp_app: :ticketed

  def send_confirmation(user, event) do
    import Swoosh.Email

    new()
    |> to({user.name, user.email})
    |> from({"Ticketed", "noreply@ticketed.com"})
    |> subject("Your #{event.name} Ticket!")
    |> html_body("""
      <h1>Hello #{user.name}</h1>
      <p>Your order has been confirmed for #{event.name}!</p> 
    """)
    |> deliver()
  end
end
