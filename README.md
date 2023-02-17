# README

- [README](#readme)
  - [UPDATE 2023-02-17 12:36:17](#update-2023-02-17-123617)
    - [Migrate old apps to new ones](#migrate-old-apps-to-new-ones)
  - [Assumptions](#assumptions)
  - [Tutorial](#tutorial)
    - [Boostrap boilerplate c3App](#boostrap-boilerplate-c3app)
      - [Checkout Project](#checkout-project)
      - [Follow Tutorial](#follow-tutorial)

this repo is a simple template to generate **critical-links c3Apps**, with some instructions and a tutorial of how to create a new c3App,

in this pratical use case, we will use `wordpress` docker image with `mysql`,
this is useful to bootstrap a `docker-compose.yml` file with two connected component services in this case `wordpress` and `mysql`

## UPDATE 2023-02-17 12:36:17

**apps scripts and structure have changed**, now we don't use `/srv` as basePath,
ex `/srv/docker/thirdparty/${APP_NAME}`
this changes were required to support new **c3next 5.x second disk** as `/data`, and to keep support **c3legacy 4.x** versions

now the target path of c3apps will be:

- c3legacy 4.x version > `/srv/docker/thirdparty/${APP_NAME}`
- c3next 5.x version > `/data/docker/thirdparty/${APP_NAME}`

### Migrate old apps to new ones

1. move `${APP_NAME}/srv/docker` to `${APP_NAME}/docker` (one level down)
2. delete the empty `${APP_NAME}/srv/docker/srv`
3. and rebundle the app with `bundleApp.sh` script
4. deploy the app and test it

## Assumptions

- we assume that this c3Apps with be deployed and used on a c3 environment with all pre requirements installed, like docker, docker-compose etc
- we assume that this tutorial is followed in a linux machine like c3 or other linux environment, currently we don't support any other os
- we assume that user as some knowledge about shell, bash script, linux, apache, newtork and docker in general

## Tutorial

### Boostrap boilerplate c3App

we will use app name `wordpress-tutorial` as a key for files and variables in c3apps files, and will use exposed port `8280`,
one can choose any other appname or port, but try keep appname simple, using alphanumeric chars, dash, underscore, simple characters, this is a advice to prevent regex and find and replaces errors

#### Checkout Project

enter a working path ex `~`

```shell
# enter home path
$ cd ~
$ git clone https://github.com/critical-links/c3-apps-starter.git
$ cd c3-apps-starter
```

#### Follow Tutorial

please follow tutorial at [TUTORIAL.md](TUTORIAL.md)