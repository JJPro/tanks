#!/bin/bash

# Load Libraries
. /app/scripts/lib.sh

_init() {
  # Ensure required environment variables are provided
  validate_env_vars

  # generate `SECRET_KEY_BASE`
  generate_secret

  # Ensure database is ready
  wait_for_db

  # Ensure migration is finished
  migrate
}

print_welcome_page

# Start server application or user provided command
if [ "$@" == "/app/bin/server" ]; then
  _init
fi

exec "$@"