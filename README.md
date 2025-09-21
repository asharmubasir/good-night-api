# Good Night API

Good Night API is a backend service built with Ruby on Rails and PostgreSQL. This guide will help you set up the project locally or using Docker for development and testing.

### For more details about the API, see the [API documentation](/docs/API_DOC.md).
### For the related architecture decision, see the [LADR record](/docs/ladr/0002-use-query-based-for-sleep-record-timeline.md).


## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Setup](#local-setup)
3. [Dockerized Setup](#dockerized-setup)
4. [Available Commands](#available-commands)
5. [Running Tests](#running-tests)
6. [API Access](#api-access)

---

## Prerequisites

Before setting up the project, make sure you have the following installed:

- **Ruby** – Check the `.ruby-version` file for the required version
- **PostgreSQL** – Database server must be running
- **Docker & Docker Compose** – For containerized development (optional)

---

## Local Setup

Follow these steps to get the application running locally without Docker:

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd good-night-api
   ```

2. **Ensure PostgreSQL is running**

3. **Set up the project**
   ```bash
   bin/setup
   ```
   This will install dependencies, set up the database, and prepare the environment.

4. **Run the tests**
   ```bash
   rspec spec
   ```
   Ensure all tests pass before starting development.

5. **Start the server**
   ```bash
   rails s
   ```
   The API will be running at `http://localhost:3000`.

---

## Dockerized Setup

For a consistent development environment across different machines, you can use Docker:

1. **Start the development environment**
   ```bash
   make start-local-dev
   ```

2. **Install gems** (if needed)
   ```bash
   make bundle-install
   ```

3. **Run database migrations**
   ```bash
   make migrate-local-dev
   ```

4. **Run tests**
   ```bash
   make rspec
   ```

The API will be available at `http://localhost:3003` when using Docker.

---

## Available Commands

| Command | Description |
|---------|-------------|
| `make start-local-dev` | Start the local development environment with Docker |
| `make stop-local-dev` | Stop the local development environment |
| `make restart-local-dev` | Restart the local development environment |
| `make reset-local-dev` | Reset the environment (clears databases and rebuilds containers) |
| `make bundle-install` | Install Ruby gems in the Docker container |
| `make migrate-local-dev` | Run database migrations in the Docker environment |
| `make rspec [spec_file]` | Run the test suite inside Docker |
| `make rm-rails-pid` | Remove Rails PID files |

---

## Running Tests

### Local Environment
```bash
rspec spec
```

### Docker Environment
```bash
make rspec
```

### Run specific tests
```bash
# Local
rspec spec/models/user_spec.rb

# Docker
make rspec spec/models/user_spec.rb
```

---

## API Access

- **Local development**: `http://localhost:3000`
- **Docker development**: `http://localhost:3003`

Make sure your database is migrated and up-to-date before making API calls.

---

## Development Workflow

1. Start the development environment:
   ```bash
   make start-local-dev
   ```

2. Make your changes to the code

3. Run tests to ensure everything works:
   ```bash
   make rspec
   ```

4. If you need to install new gems:
   ```bash
   make bundle-install
   ```

5. If you create new migrations:
   ```bash
   make migrate-local-dev
   ```

---

## Troubleshooting

**Having issues with the Docker build**
- Try rebuilding the containers: `make reset-local-dev`
