#!/bin/bash

docker compose down &&
docker compose up --build -d &&
docker compose exec new_computer bash
