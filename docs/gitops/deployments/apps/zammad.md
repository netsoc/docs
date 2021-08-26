# Zammad

[Zammad](https://zammad.org/) is an open-source support / ticketing system. It's accessible at
[support.netsoc.ie][support_site]. Users can email [support@netsoc.ie][support_mail] and
Zammad will automatically create tickets for them. There's also an embeddable live chat widget, this is set up for the
website (see `website-ng/_layouts/splash.html`).

## Adding new admin users

All new users should sign up through the registration form at [support.netsoc.ie][support_site]. If they
have emailed [support@netsoc.ie][support_mail] before, an account will already exist. In this case they should use the
password reset form to set an initial password. The dashboard can be used to make a user an "Agent" (can respond to
tickets) and/or an "Admin" (can manage the Zammad installation).

If the admin dashboard is inaccessible, the Zammad Rails console can be used to set a user's roles:

1. Get a rails console via the Zammad container:

    ```
    kubectl -n extra exec -ti zammad-0 -c zammad-railsserver -- bundle exec rails c
    ```

2. Use the following snippet to set their roles:

    ```ruby
    u = User.find_by(email: 'some_admin@tcd.ie')
    u.roles = Role.where(name: ['Agent', 'Admin'])
    u.save!
    ```

[support_site]: https://support.netsoc.ie
[support_mail]: mailto:support@netsoc.ie

## Setting email configuration

It's easiest to change the email configuration (sending notifications, sending / receiving ticket updates) from the
dashboard. Head to Settings > Channels > Email. The screen should look something like this:

![Zammad email config](../../../assets/zammad_email.png)

Refer to the following screenshots for how inbound, outbound and notifications should be set up:

![Zammad outbound email config](../../../assets/zammad_outbound.png)
![Zammad inbound email config](../../../assets/zammad_inbound.png)
![Zammad notifications email config](../../../assets/zammad_notifications.png)
