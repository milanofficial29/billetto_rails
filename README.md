# Billetto Rails Integration

A Rails application that pulls events from the Billetto API, displays them, and lets signed-in users vote on them. Votes are recorded as immutable events in Rails Event Store rather than a plain votes table.

## Requirements

- Ruby 3.3.6
- MySql

## Setup

Clone the repo and install dependencies:

```bash
bundle install
```

Copy the environment file and fill in your credentials:

```bash
cp .env.example .env
```

Open `.env` and add:

```
CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
CLERK_SECRET_KEY=your_clerk_secret_key
BILLETTO_ACCESS_KEY_ID=your_billetto_access_key_id
BILLETTO_ACCESS_KEY_SECRET=your_billetto_access_key_secret
```

Create and migrate the database:

```bash
rails db:create
rails db:migrate
```

Pull events from Billetto:

```bash
rails billetto:ingest
```

Start the server:

```bash
rails server
```

Visit `http://localhost:3000` to see the events listing.

## Running Tests

```bash
bundle exec rspec
```

---

### Billetto API

Events are ingested via a rake task (`rails billetto:ingest`) rather than a scheduled job. The task calls the API, upserts events by their external ID, and marks anything that's no longer in the API response as unavailable. Running the task twice won't create duplicates.

The `Billetto::Event` acts as an anti-corruption layer, it translates the raw API response into `EventData` structs before anything touches the database. This means if Billetto changes a field name, only the adapter needs updating.

### Authentication

User authentication is handled by Clerk.com. The backend verifies the session token from the request and exposes `current_user` across controllers. The events page is public, anyone can browse events, but voting requires being signed in.

### Assumptions

- Vote counts update synchronously in the current setup, so they reflect immediately after voting. In a production deployment with async processing there would be a brief lag, which is acceptable for a voting feature.
- The app doesn't maintain a local user table. The Clerk user ID is the identifier used everywhere, stored in vote events, used for duplicate checking. User profile data (name, email) would come from the Clerk SDK if needed.
- The rake task is designed to be run manually or via cron. There's no in-app trigger for ingestion.