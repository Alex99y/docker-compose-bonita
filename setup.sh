#!/bin/bash

## IMPORTANT
export POSTGRES_USER="postgres"
export POSTGRES_PASSWORD="000000"
export TENANT_LOGIN="admin" 
export TENANT_PASSWORD="admin"
    ## API Rest credentials
export PLATFORM_LOGIN="admin"
export PLATFORM_PASSWORD="admin"
    ## Database configuration
export DB_VENDOR=postgres
export DB_HOST="posgresql"
export DB_PORT="5432"
export DB_ADMIN_USER=$POSTGRES_USER
export DB_ADMIN_PASS=$POSTGRES_PASSWORD
    ## Bonita Database
export DB_NAME="bonitadb"
export DB_USER=$POSTGRES_USER
export DB_PASS=$POSTGRES_PASSWORD
    ## Bonita business database
export BIZ_DB_NAME="bonitabizdb"
export BIZ_DB_USER=$POSTGRES_USER
export BIZ_DB_PASS=$POSTGRES_PASSWORD

function createScript(){
    rm ./scripts/createDatabase.sql
    touch ./scripts/createDatabase.sql
    echo "CREATE DATABASE $DB_NAME;" >> ./scripts/createDatabase.sql
    echo "CREATE DATABASE $BIZ_DB_NAME;" >> ./scripts/createDatabase.sql
}

function error() {
    echo "Invalid arguments"
    exit 1
}


if [ $# == 0 ] 
then
    echo "Missing arguments"
    echo "./setup.sh up"
    echo "./setup.sh up daemon"
    echo "./setup.sh down"
    echo "./setup.sh down volumes"
    echo "./setup.sh import database"
    echo "./setup.sh export [database].sql"
    exit 0
fi

if [[ ( $0 == "./setup.sh" && $1 == "up" && $# == 1) ]]
then
    echo "Running containers and printing logs in stdout"
    createScript
    docker-compose up
    exit 0
fi

if [[ ( $0 == "./setup.sh" && $1 == "up" && $2 == "daemon" && $# == 2) ]]
then
    echo "Running containers in detached mode"
    createScript
    docker-compose up -d
    exit 0
fi

if [[ ( $0 == "./setup.sh" && $1 == "down" && $# == 1) ]]
then
    echo "Stopping containers"
    docker-compose down
    exit 0
fi

if [[ ( $0 == "./setup.sh" && $1 == "down" && $2 == "volumes" && $# == 2) ]]
then
    echo "Stopping containers and deleting volumes"
    docker-compose down --volumes
    exit 0
fi

if [[ ( $0 == "./setup.sh" && $1 == "import" && $2 == "database" && $# == 2) ]]
then
    echo "Importing database and saving it in the backup directory"
    docker exec -t postgresql pg_dumpall -c -U postgres > backups/dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql
    exit 0
fi

if [[ ( $0 == "./setup.sh" && $1 == "export" && $# == 2) ]]
then
    echo "Exporting database from file"
    docker-compose stop bonita
    cat $2 | docker exec -i postgresql psql -U postgres
    docker-compose up -d
    exit 0
fi
error