#!/bin/bash

container_image="new_computer"

docker-compose down && 
docker-compose up -d --build && 
docker-compose exec $container_image bash
