# rclone many to many sync

[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/huzgrisyon/rclone-m2m-backup?label=Version&logo=docker)](https://hub.docker.com/r/huzgrisyon/rclone-m2m-backup/tags) [![Docker Pulls](https://img.shields.io/docker/pulls/huzgrisyon/rclone-m2m-backup?label=Docker%20Pulls&logo=docker)](https://hub.docker.com/r/huzgrisyon/rclone-m2m-backup) [![GitHub](https://img.shields.io/github/license/dayantrivani/rclone-backup?label=License&logo=github)](https://github.com/dayantrivani/rclone-backup/blob/master/LICENSE)

Docker container for sync multiple sources to multiple destinations using rclone. It's usually used for backup.

- [Docker Hub](https://hub.docker.com/r/huzgrisyon/rclone-m2m-backup)
- [GitHub](https://github.com/dayantrivani/rclone-backup)

## Feature

This tool supports backing up multiple sources to multiple destinations via rclone.

And the following ways of notifying sync results are supported.

- Ping (only send on success)
- Mail (SMTP based, send on success and on failure)

## Usage

### Configure Rclone

> **You need to configure Rclone first, otherwise the sync tool will not work.**

The tool performs [Rclone](https://rclone.org/) [sync](https://rclone.org/commands/rclone_sync/).

#### Configure and Check

You can set rclone up by the following command.

```shell
docker run --rm -it \
  huzgrisyon/rclone-m2m-backup:latest \
  rclone config
```

After setting, check the configuration content by the following command.

```shell
docker run --rm -it \
  huzgrisyon/rclone-m2m-backup:latest \
  rclone config show

# Microsoft Onedrive Example
# [SourceBackup]
# type = onedrive
# token = {"access_token":"access token","token_type":"token type","refresh_token":"refresh token","expiry":"expiry time"}
# drive_id = driveid
# drive_type = personal
```

### Automatic sync

Start the container with custom settings. (See variables below, default to automatic backup at 5 minute every hour)

```shell
docker run -d \
  --restart=always \
  --name m2m_backup \
  --e ... \
  huzgrisyon/rclone-m2m-backup:latest
```

## Environment Variables

### SOURCES and REMOTES

The values of `RCLONE_SOURCE_NAME_X` and `RCLONE_REMOTE_NAME_X` need to be consistent with the name in the rclone config.

You can view the names with the following command.

```shell
docker run --rm -it \
  huzgrisyon/rclone-m2m-backup:latest \
  rclone config show

# [SourceBackup] <- this
# ...
```

You can set multiple sources and remotes, each source will be synced to each remote. To do that, use the environment variables `RCLONE_SOURCE_NAME_N` ,`RCLONE_SOURCE_DIR_N` and `RCLONE_SOURCE_DESC_N`  as well as `RCLONE_REMOTE_NAME_N` and `RCLONE_REMOTE_DIR_N`, where:

- `N` is a serial number, starting from 0 and increasing consecutively for each source and destination
- They cannot be empty
- They cannot contain these characters: `:,()`

Note that if the serial number is not consecutive or the value is empty, the script will break parsing the environment variables.

#### Example

```yml
...
environment:
  RCLONE_SOURCE_NAME_0: source
  RCLONE_SOURCE_DIR_0: /sourcedir/
  RCLONE_SOURCE_DESC_0: sourcedescription
  RCLONE_SOURCE_NAME_1: source1
  RCLONE_SOURCE_DIR_1: /source1dir/
  RCLONE_SOURCE_DESC_1: source1description
  RCLONE_REMOTE_NAME_0: remote
  RCLONE_REMOTE_DIR_0: /remotedir/
  RCLONE_REMOTE_NAME_1: remote1
  RCLONE_REMOTE_DIR_1: /remote1dir/
...
```

With the above example, `source:/sourcedir/` will be synced to both remote destinations: `remote:/remotedir/sourcedescription/` and `remote1:/remote1dir/sourcedescription/`, after that, `source1:/source1dir/` will be synced to both remote destinations: `remote:/remotedir/source1description/` and `remote1:/remote1dir/source1description/`.

Note that if the source directory `source:/sourcedir/` is empty, after the sync process, the destination directory `remote:/remotedir/sourcedescription/` will be empty too. Use with caution.

```yml
...
environment:
  RCLONE_SOURCE_NAME_0: source
  RCLONE_SOURCE_DIR_0: /sourcedir/
  RCLONE_SOURCE_DESC_0: sourcedescription
  RCLONE_REMOTE_NAME_0: remote1
  RCLONE_REMOTE_DIR_0: /remote1dir/
  RCLONE_REMOTE_NAME_1: extraRemoteName1
  RCLONE_REMOTE_DIR_1: extraRemoteDir1
  RCLONE_REMOTE_NAME_2: extraRemoteName2
  RCLONE_REMOTE_DIR_2: extraRemoteDir2
  RCLONE_REMOTE_NAME_3: extraRemoteName3
  RCLONE_REMOTE_DIR_3: extraRemoteDir3
  RCLONE_REMOTE_NAME_4: extraRemoteName4
  RCLONE_REMOTE_DIR_4: extraRemoteDir4
...
```

With the above example, all 5 remote destinations are available.

```yml
...
environment:
  RCLONE_SOURCE_NAME_0: source
  RCLONE_SOURCE_DIR_0: /sourcedir/
  RCLONE_SOURCE_DESC_0: sourcedescription
  RCLONE_REMOTE_NAME_0: remote1
  RCLONE_REMOTE_DIR_0: /remote1dir/
  RCLONE_REMOTE_NAME_1: extraRemoteName1
  RCLONE_REMOTE_DIR_1: extraRemoteDir1
  RCLONE_REMOTE_NAME_2: extraRemoteName2
  # RCLONE_REMOTE_DIR_2: extraRemoteDir2
  RCLONE_REMOTE_NAME_3: extraRemoteName3
  RCLONE_REMOTE_DIR_3: extraRemoteDir3
  RCLONE_REMOTE_NAME_4: extraRemoteName4
  RCLONE_REMOTE_DIR_4: extraRemoteDir4
...
```

With the above example, only the remote destinations before `RCLONE_REMOTE_DIR_2` are available: `remoteName:remoteDir` and `extraRemoteName1:extraRemoteDir1`.

#### RCLONE_GLOBAL_FLAG

Rclone global flags, see [flags](https://rclone.org/flags/).

**Do not add flags that will change the output, such as `-P`, which will affect the deletion of outdated backup files.**

Default: `''`

#### CRON

Schedule to run the backup script, based on [`supercronic`](https://github.com/aptible/supercronic). You can test the rules [here](https://crontab.guru/#5_*_*_*_*).

Default: `5 * * * *` (run the script at 5 minute every hour)

#### TIMEZONE

Set your timezone name.

Here is timezone list at [wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

Default: `UTC`

#### PING_URL

Use [healthcheck.io](https://healthchecks.io/) url or similar cron monitoring to perform `GET` requests after a **successful** backup.

#### WGET_OPTION

Options used in wget, for example, `-Y on` toggles proxy on for wget in busybox. Call `wget --help` for more information.

#### MAIL_SMTP_ENABLE

The tool uses [`s-nail`](https://www.sdaoden.eu/code-nail.html) to send mail.

Default: `FALSE`

#### MAIL_SMTP_VARIABLES

Because the configuration for sending emails is too complicated, we allow you to configure it yourself.

**We will set the subject according to the usage scenario, so you should not use the `-s` option.**

During testing, we will add the `-v` option to display detailed information.

```text
# My example:

# For Zoho
-S smtp-use-starttls \
-S smtp=smtp://smtp.zoho.com:587 \
-S smtp-auth=login \
-S smtp-auth-user=<my-email-address> \
-S smtp-auth-password=<my-email-password> \
-S from=<my-email-address>
```

Console showing warnings? Check [issue #177](https://github.com/ttionya/vaultwarden-backup/issues/117#issuecomment-1691443179) for more details.

#### MAIL_TO

This specifies the recipient of the notification email.

#### MAIL_WHEN_SUCCESS

Sends an email when the backup is successful.

Default: `TRUE`

#### MAIL_WHEN_FAILURE

Sends an email when the backup fails.

Default: `TRUE`

## Using `.env` file

If you prefer using an env file instead of environment variables, you can map the env file containing the environment variables to the `/.env` file in the container.

```shell
docker run -d \
  --mount type=bind,source=/path/to/env,target=/.env \
  huzgrisyon/rclone-m2m-backup:latest
```

## About Priority

We will use the environment variables first, then the values from the `.env` file.

## Mail Test

You can use the following command to test mail sending. Remember to replace your SMTP variables.

```shell
docker run --rm -it -e MAIL_SMTP_VARIABLES='<your smtp variables>' huzgrisyon/rclone-m2m-backup:latest mail <mail send to>

# Or

docker run --rm -it -e MAIL_SMTP_VARIABLES='<your smtp variables>' -e MAIL_TO='<mail send to>' huzgrisyon/rclone-m2m-backup:latest mail
```

## Manually trigger a backup

Sometimes, it's necessary to manually trigger backup actions.

This can be useful when other programs are used to consistently schedule tasks or to verify that environment variables are properly configured.

```shell
docker run \
  --rm \
  -e ... \
  huzgrisyon/rclone-m2m-backup:latest backup
```

The only difference is that the environment variable `CRON` does not work because it does not start the CRON program, but exits the container after the backup is done.

## Changelog

Check out the [CHANGELOG](https://github.com/dayantrivani/rclone-backup/blob/master/CHANGELOG.md) file.

## License

MIT
