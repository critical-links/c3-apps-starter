# TUTORIAL

## Enter Repo Path

after clone repo <https://github.com/critical-links/c3-apps-starter.git>, continue in cloned folder

```shell
# enter path
$ cd ~/home/c3-apps-starter
```

## Bootstrap boilerplate files

```shell
$ ./bootstrapNewApp.sh wordpress 8220
```

> NOTE: `wordpress/` was previously added to `.gitignore`, with that git will not track `wordpress` changes

## Inspect boilerplate files

```shell
wordpress/                                          app root folder
├── app.env                                         app environment variables config
├── bundle.env                                      app environment variables used by bundle script
├── etc                                             files that will be deployed on c3 /etc folder
│   ├── apache2                                     apache config files
│   │   └── sites-available                         apache sites-available config files
│   │       ├── c3app-wordpress.com-le-ssl.conf     apache https config file
│   │       └── c3app-wordpress.conf                apache http forword config file
│   └── monit                                       monit config files
│       └── conf-available                          monit conf-available config files
│           └── host-c3app-wordpress                monit host config file
├── srv                                             files that will be deployed on c3 /srv folder
│   └── docker                                      c3 docker root folder
│       └── thirdparty                              c3 docker third party root folder
│           └── wordpress                           app docker root folder
│               └── docker-compose.yml              app docker-compose.yml file
└── VERSION                                         app version used in bundle script
```
