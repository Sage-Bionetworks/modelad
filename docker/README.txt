# Docker Compose Cheatsheet

## Build and Start Containers
docker-compose up --build

## Stop and Remove Containers, Networks, and Images
docker-compose down --rmi all

## Start Containers
docker-compose up

## Stop Containers
docker-compose down

## View Running Containers
docker-compose ps

## View Logs
docker-compose logs

## Execute Command in Running Container
docker-compose exec <service_name> <command>

## Scale Service
docker-compose up --scale <service_name>=<number_of_instances>

## Rebuild Specific Service
docker-compose up --build <service_name>

## Force Recreate Containers
docker-compose up --force-recreate

## Run Containers in Detached Mode
docker-compose up -d
