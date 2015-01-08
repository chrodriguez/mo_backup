# Cookbook: mo_backup

Cookbook to perform application backups. This cookbook uses
[backup gem](http://meskyanichi.github.io/backup/v4/) to run the backups.

## Table of Contents

* [Development](#development)
  * [Current state](#current-state)
  * [Features planned](#features-planned)
* [Supported Platforms](#supported-platforms)
* [Recipes](#recipes)
* [Libraries](#libraries)
* [Attributes](#attributes)
* [Usage](#usage)
  * [Required attributes](#required-attributes)
  * [Required databag and databag items](#required-databag-and-databag-items)
    * [Application databag item](#application-databag-item)
    * [Storage databag item](#storage-databag-item)
    * [Mail databag item](#mail-databag-item)
  * [Backup recipe](#backup-recipe)
* [License](#license)
* [Authors](#authors)

## Development

This cookbook is still in development but can be used if current features cover
your needs.

### Current state

For now, this cookbook:

* Supports installing rbenv globally and the backup gem inside it.
* Provides a method to generate the backup configuration file (the model) for:
  * Application files.
  * MySQL databases.
* Supports:
  * Amazon S3 as the only storage.
  * Backup scheduling.
  * Compression with Gzip.
  * Mail relay configuration.

### Features planned

Features to be implemented:

* Databases.
  * MongoDB.
  * Redis.
* Encryptors.
  * OpenSSL.
* Notifiers: not sure yet about this.
* Storages.
  * Dropbox.
  * Local.
  * Rsync.
  * SCP.
  * SFTP.
* Syncers.
  * Rsync.

## Supported Platforms

Tested on Ubuntu 14.04, should work on:

* Centos / Redhat / Fedora / Ubuntu / Debian.

## Recipes

This cookbook has only one recipe which is `install`, the one that sets up the
global rbenv environment and the backup gem inside that environment. Must be
run on every server that will execute backups with this cookbook.

## Libraries

`mixin_model`: this library is the one used to create and schedule the
applications backup configuration. It provides two methods:

* `mo_backup_generate_model(app)`
* `mo_backup_schedule_job(app, [action])`

where:

* **app**: is the hash with the required values to configure the backup (check usage
  below).
* **action**: could be `create` or `delete` and it's optional. If not specified, create
  is the default value.

## Attributes

The only attribute this cookbook has is the ruby version to install on the
server, when using `install` recipe.

## Usage

For an usage example, check out the
[mo_backup_sample](https://github.com/Desarrollo-CeSPI/mo_backup_sample)
cookbook which provides a complete sample application.

To use this cookbook you'll need to fulfill the following requirements.

### Required attributes

To generate the backup configuration file you'll need to pass to the
mo_backup_generate_model method a hash with the following attributes:

* **id**: application id, the one that will be used to look for the
  corresponding data bag item.
* **databag**: the applications databag, where the application with the id **id** is
  defined.
* **description**: a description for the application.
* **user**: the user the application runs or is deployed with.
* **backup**: this key should have the following subkeys:
  * **storages_databag**: the databag where the different storages are defined.
  * **mail_databag**: the databag where the mail relay configuration is specified.

### Required databag and databag items

This cookbook needs three databags and each defines different items. Sample
databags are shown in the mo_backup_sample cookbook.

Following, databag examples will be shown. These databags are the ones included
in mo_backup_sample cookbook.

#### Aplication databag item

The application databag will need to define a backup section and a databases
section in case it uses databases. Along with the database name, username,
password and host it is necessary to specify its type.

An example databag:

`knife solo data bag show applications my_app -Fj`

```json
{
  "id": "my_app",
  "production": {
    "databases": [
      {
        "name": "my_app",
        "username": "my_app",
        "password": "my_apppass",
        "host": "172.17.2.1",
        "type": "mysql"
      },
      {
        "name": "my_app2",
        "username": "my_app2",
        "password": "my_app2pass",
        "type": "mysql"
      }
    ],
    "backup": {
      "archive": {
        "root": "/opt/applications/my_app",
        "add": [
          "/app/",
          "/log"
        ],
        "use_sudo": false
      },
      "schedule": {
        "hour": "3"
      },
      "databases": [
        "my_app",
        "my_app2"
      ],
      "compress": true,
      "storages": [
        {
          "id": "s3",
          "path": "my_app",
          "keep": 30
        },
        {
          "id": "otro_s3",
          "path": "backups",
          "keep": 60
        }
      ],
      "mail": {
        "mail_id": "mail_app",
        "on_success": "false",
        "from": "my-app-backups@example.local",
        "to": "my-app-group@example.local"
      },
      "encryptor": {

      }
    }
  }
}
```

#### Storage databag item

Storage databag will have all the possible storages used for backups. Each
application could use a different storage and the configuration will use the
values defined in the corresponding item.

An example databag:

`knife solo data bag show backup_storages s3 --secret-file .chef/data_bag_key -Fj`

```json

{
  "id": "s3",
  "access_key_id": "fbiuhfiu23hof3189",
  "secret_access_key": "hgw87qydiu1hoG/yhdw8ydgw7iuyK",
  "region": "us-west-2",
  "bucket": "backups",
  "encryption": "aes256",
  "type": "s3"
}
```

Besides the storages databag, a storage section is optionally present in the
application databag to overwrite or add some configuration values.

#### Mail databag item

Mail is used to send notifications after backups are executed. Can be configured
to send notifications on success, on warnings and/or on failures.

An example databag:

`knife solo data bag show mail_databag mail_app --secret-file .chef/data_bag_key -Fj`

```json
{
  "id": "mail_app",
  "from": "no-reply@example.local",
  "to": "ti@example.local",
  "address": "smtp.example.local",
  "port": 465,
  "domain": "example.local",
  "user_name": "no-reply",
  "password": "nd238diqwkjbh2",
  "authentication": "login",
  "encryption": "starttls"
}
```

Besides the mail databag, a mail section is optionally present in the
application databag to overwrite or add some configuration values.

### Backup recipe

On your application, write a backup recipe calling the mo_backup_generate_model
method, giving it the necessary parameters.

If you want to schedule the job you'll need to also call the
mo_backup_schedule_job method. In that case, you'll probably want to specify
when you wish to run the backups which will require adding some parameters to
the application databag. If you don't want to give your own scheduling
parameters, defaults will be used.

## License

The MIT License (MIT)

Copyright (c) 2014 Christian Rodriguez & Leandro Di Tommaso

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Authors

* Author:: Christian Rodriguez (chrodriguez@gmail.com)
* Author:: Leandro Di Tommaso (leandro.ditommaso@mikroways.net)
