# Humhub

This creates a [Docker](http://www.docker.com) image of the [Humhub](https://www.humhub.org) Social Network Kit.

This is a fork of [cboulanger/humhub-docker](https://hub.docker.com/r/cboulanger/docker-humhub/), using a [Turnkeylinux LAMP](https://www.turnkeylinux.org/lampstack) [base image](https://hub.docker.com/r/cboulanger/turnkeylinux-lamp/).

MySQL is configured with a **humhub** database with a **humhub** user with a **HuMhUb** password

## Howto

Clone it:

```
git clone https://github.com/krismas/humhub-docker.git
cd humhub-docker
git checkout 1.0.0-beta 
docker build -t ackwa/humhub-docker .
```

Check PHP configuration in the Dockerfile:

```
POST_MAX_SIZE        default to 20M
UPLOAD_MAX_FILESIZE  default to 10M
MEMORY_LIMIT         default to 128M
```

Build it:

```
docker build -t ackwa/humhub-docker .
```

Run it:

```
docker run -p 80:80 -p 443:443 --name humhub -d ackwa/humhub-docker
```

## Data migration

You can also [migrate data from and to a different container](humhub-data/readme.md).

## Post-Installation steps:
- Make sure that there is no file `XX-xcache.ini` in `/etc/php5/(apache2|cli)/conf.d/`.
- Also, see [here](https://www.humhub.org/docs/guide-admin-installation.html#4-fine-tuning). Already taken care of by the Dockerfile are cron jobs.

## Turnkey Backup et Migration
- Since the basis of this image is Turnkey Linux, the automated backup tool [TKLBAM](https://www.turnkeylinux.org/docs/tklbam) is available out of the box.
- If you use TKLBAM, make sure to include any SSL-Certificates in the backup, otherwise the apache server will not start if you restore the backup to another machine. In the current setup, you need to add `/humhub/data/*.crt` and `/humhub-data/*.key` to `/etc/tklbam/overrides`.