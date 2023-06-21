#!/bin/bash

# Load Libraries
. /app/scripts/liblog.sh

# Constants
BOLD='\033[1m'

validate_env_vars() {
    required_env_vars=(
        POSTGRES_HOST
        POSTGRES_USER
        POSTGRES_PASSWORD
        POSTGRES_DB
    )

    for env_var in "${required_env_vars[@]}"; do
        if [[ -v $env_var ]]; then 
            export "$env_var"="${!env_var}"
        else
            error "environment variable ${env_var} is missing." >&2
            exit 1
        fi
    done

    export DATABASE_URL="ecto://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB}"
    export PHX_HOST="${PHX_HOST:-localhost}"
}

generate_secret() {
    if [ -z "$SECRET_KEY_BASE" ]; then
        export SECRET_KEY_BASE=$(/usr/bin/openssl rand -base64 48)
        info "SECRET_KEY_BASE generate successful"
    fi
}

wait_for_db() {
    max_attempts=10
    attempt=1

    # Loop until the database connection is successful or the maximum number of attempts is reached
    while [ $attempt -le $max_attempts ]; do
        # Try connecting to the database
        PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p 5432 -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1" >/dev/null 2>&1

        # Check the exit status of the psql command
        if [ $? -eq 0 ]; then
            info "Database connection successful"
            break
        fi

        warn "Attempt $attempt: Database connection failed. Retrying in 5 seconds..."
        attempt=$((attempt + 1))
        sleep 5
    done

    # If the maximum number of attempts is reached without a successful connection, exit with an error
    if [ $attempt -gt $max_attempts ]; then
        error "Unable to establish database connection after $max_attempts attempts. Exiting..." >&2
        exit 1
    fi
}

# Run migration if not yet
migrate() {
    if [ ! -f "/app/migration_complete" ]; then
        /app/bin/migrate

        if [ $? -eq 0 ]; then
            touch /app/migration_complete
            info "Migration successful"
        else
            error "Migration failed" >&2
            exit 1
        fi
    fi
}

print_welcome_page() {
    local github_url="https://github.com/JJPro/tanks"

    log ""
    log "${BOLD}Welcome to the Real-time Multi-player Tanks Game container${RESET}"
    log "Subscribe to project updates by watching ${BOLD}${github_url}${RESET}"
    log "Have Fun!${RESET}"
    log ""
}