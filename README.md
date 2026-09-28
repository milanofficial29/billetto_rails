# Billetto Rails Integration

A Rails application that fetches events from the Billetto API, displays them, and allows signed-in users to like or dislike events.

Votes are stored as immutable events using Rails Event Store instead of a traditional `votes` table.

## Requirements

* Ruby 3.3.6
* MySQL

## Setup

Clone the repository and install the dependencies:

```bash
bundle install
```

Copy the environment file:

```bash
cp .env.example .env
```

Add the required credentials to `.env`:

```env
CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
CLERK_SECRET_KEY=your_clerk_secret_key

BILLETTO_ACCESS_KEY_ID=your_billetto_access_key_id
BILLETTO_ACCESS_KEY_SECRET=your_billetto_access_key_secret

DATABASE_USERNAME="your_db_username"
DATABASE_PASSWORD="your_db_password"
```

Create and migrate the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

Import events from Billetto:

```bash
bin/rails billetto:ingest
```

Start the application:

```bash
bin/rails server
```

Then open:

```text
http://localhost:3000
```

## Billetto API

Events are imported using the `billetto:ingest` Rake task.

The task:

* Fetches events from the Billetto API
* Creates or updates events using the external Billetto ID
* Avoids creating duplicate events when run multiple times
* Marks events that are no longer returned by the API as unavailable

The `Billetto::Event` class handles the API response and converts it into an `EventData` struct before saving anything to the database.

This keeps the Billetto API structure separate from the rest of the application. If Billetto changes a response field, the adapter can be updated without changing the application code that uses the event data.

## Authentication

Authentication is handled by Clerk.

The events page is public, so users can browse events without signing in. Users need to be signed in to like or dislike an event.

The backend verifies the Clerk session and makes the authenticated user available through `current_user`.

For automated system tests, Clerk authentication is mocked so the tests don't depend on the external Clerk authentication flow or CAPTCHA.

## Voting

Users can like or dislike an event when they are signed in.

Votes are stored using Rails Event Store rather than a regular votes table. Each voting action is recorded as an immutable event.

The application uses these events to determine the current like and dislike counts.

## Tests

Run the RSpec tests with:

```bash
bundle exec rspec
```

Run the Rails system tests with:

```bash
bin/rails test:system
```

The system tests cover the main user flow, including:

* Events page
* Loading additional events while scrolling
* Clerk authentication state
* Like and dislike actions
* Vote counter updates
* Sign out

## Event Ingestion

Events are currently imported manually using:

```bash
bin/rails billetto:ingest
```

The task is idempotent, so running it multiple times will update existing events instead of creating duplicates.
