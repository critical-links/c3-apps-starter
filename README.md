# README

this repo is a simple template to generate **critical-links c3Apps**, with some instructions and a tutorial of how to create a new c3App, 

in this pratical use case, we will use `wordpress` docker image with `mysql`, this is useful to bootstrap a `docker-compose.yml` file with two connected component services in this case `wordpress` and `mysql`

## Assumptions

- we assume that this c3Apps with be deployed and used on a c3 environment with all pre requirments installed
- we assume that this tutorial is followed in a linux machine like c3 or other linux environment
- we assume that user as some knowledge about bash, linux, apache and docker in general

## Tutorial

### Boostrap boilerplate c3App

we will use app name `wordpress` as a key for files and variables in c3apps files, and will use exposed port `8280`,
one can choose any other appname or port, but try keep appname simple, using alphanumeric chars, and simple characters like `-`, `_` etc ex `wordpress-mysql-app`, else we can have some issues with regex and find and replaces

#### Checkout Project

enter a working path ex ~/home/

```shell
$ cd ~/home/
$ git clone https://github.com/critical-links/critical-links-c3-apps.git
```
