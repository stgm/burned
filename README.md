# Burned

Group chat for small teams, built with Hanami 3. Threads instead of channels, and no notifications. A thread only
bubbles up when you asked it to.

## How it works

- Three panes, like a mail client. **Teams** are on the left, the **threads** of the open team are in the middle,
  and the open thread is on the right. Opening a team opens its most recent thread.
- The thread list is in your personal bubble order: threads that bubble up for you first (with a count), then the
  rest by recent activity, then the threads you quieted.
- A bar across the top shows the threads you posted in most recently, across all your teams. Threads that bubble up
  are highlighted there too.
- On a phone you see one pane at a time: the thread list or the thread (with a back link). Teams slide in from the
  left with the menu button. **+** starts a thread and **@** shows the team's people.
- Each person sets, per thread, when it bubbles up: on every message, only on an @mention, or never. This only
  changes the bubbles and counts. Nothing pings anyone.
- **Select** in a thread lets you pick messages and move them into a new thread. The old thread keeps a link to it.
- People appear as initials in a style that is generated from a number stored with each person: font, colors,
  shape, shadow or outline.
- No reactions, no photos, no passwords.

## Sign-in

An admin invites a person by email (the People page). That person enters their address on the sign-in page and gets
a six digit code by mail. The code works for 10 minutes and allows 5 attempts. The session cookie lasts 3 months.
Inside a team, any member can invite a person who already has an account. Team invitations show up on the
Teams page and need to be accepted.

The first admin comes from the seeds:

```bash
ADMIN_EMAIL=you@example.com bundle exec hanami db seed
```

## Development

Ruby is managed with `rv`.

```bash
rv ruby install 4.0.6      # once
bundle install
npm install
bundle exec hanami db prepare
ADMIN_EMAIL=you@example.com bundle exec hanami db seed
bundle exec hanami dev     # http://localhost:2300
```

Without SMTP settings, development prints each mail to the server log and appends it to `log/mail.log`, so you can read the sign-in code there.

To fill the database with example people and threads (sign in as `admin@example.com`):

```bash
bundle exec hanami db reset && bundle exec hanami run config/db/demo.rb
```

Run the tests with `bundle exec rake test`. CSRF checks are off in the test environment (Hanami's rule), so check
them by hand.

## Deploying on PostgreSQL

The same migrations run on SQLite and PostgreSQL. The `pg` gem is in the `production` group of the Gemfile and needs
libpq installed. Set these in the environment:

| Variable | Value |
| --- | --- |
| `HANAMI_ENV` | `production` |
| `DATABASE_URL` | `postgres://user:password@host/dbname` |
| `SESSION_SECRET` | at least 64 random characters, for example `ruby -rsecurerandom -e 'puts SecureRandom.hex(48)'` |
| `APP_URL` | public address, used in links inside mails |
| `MAIL_FROM` | sender address of mails |
| `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_AUTHENTICATION` | your mail server |

Then:

```bash
bundle install --without development test
npm install && bundle exec hanami assets compile
bundle exec hanami db migrate
ADMIN_EMAIL=you@example.com bundle exec hanami db seed
bundle exec puma -C config/puma.rb
```

The cookie is marked secure in production, so serve the app over HTTPS and have the proxy send
`X-Forwarded-Proto: https`. The value of `SESSION_SECRET` in `.env` is for development only.

## Notes on the code

- `app/repos` holds the queries. They use Sequel through ROM and return plain hashes.
- `app/auth` and `app/chat` hold operations (sign-in codes, invitations, posting, splitting a thread).
- `app/actions/chat_action.rb` loads the teams and bubbles that every chat page shows.
- Pages update by polling `/updates` every 3 seconds (8 seconds outside a thread) and swapping in server-rendered
  HTML. There is no websocket, so it needs no extra service.
- Times are stored in UTC and shown in the viewer's time zone by `app/assets/js/app.js`.
