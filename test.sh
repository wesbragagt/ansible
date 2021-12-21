#!/bin/bash

set -e

docker build -t new-computer . &&
docker run -it --rm new-computer 
