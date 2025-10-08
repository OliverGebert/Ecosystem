# Readme for Ecosystem setup and deployment

## CLI client

## Vue SPA

## python fastAPI

the ecoAPI can be run via Make locally
it needs to be prvisioned with data from provision.hurl file with Make

## Deployment

### fastAPI

first the terraform init needs to run
second the terraform apply needs to deploy the container registry adn the web app
third the container needs to be built with docker
fourth the image has to pushed o the acr with docker
fifth the azure web app needs to restart to fetch the new image

all this is done with Make targets
