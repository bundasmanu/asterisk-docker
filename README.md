# asterisk-docker

Asterisk to be used as a container.
This is a simple backbone, that must grow and be improved, to suite the needs of the wanted project.

**Note:** This is a work in progress, and the idea is to keep improving it, as we go. Improvements on Dockerfile will be made, as soon as possible, to look directly to github repo.

## Purpose

The main reasons behind the need to create this repo, are mainly:

- The need to get a easy way to switch between different `Asterisk` versions;
- The need to make easy the process to install, test and debug `Asterisk` in a docker container;
- The need to get a functional `backbone` that it's easy to scale and integrate with `Asterisk`;
  - Useful to have a simple `B2BUA`;
  - Help testing some app integrations in a SIP Flow;

## What offers

- `Asterisk` working in a container;
- Easy way to manage and switch between different `Asterisk` versions;
- Easy way to scale multiple `Asterisk` containers, changing only some environment variables;
- Add and update on-demand the configuration files - volume integration;
- Log file volume integration;
- Access to `Asterisk` CLI;
- Easy integration with `Kamailio` to be tested behind;

## .env file

Vars used on build and others used to customize mainly configuration files.
The important ones are:

- `ASTERISK_BRANCH`: Branch used to compile and install `Asterisk`;
- `ASTERISK_MODULES_ENABLE`: List of modules, that by default are not installed, and must be. Use `,` as a delimiter;
- `ASTERISK_MODULES_DISABLE`: List of modules, that by default are installed, and must not be. Use `,` as a delimiter;
- `ASTERISK_CATEGORY_DISABLE`: List of categories, that by default are installed, and must not be. Use `,` as a delimiter;
- `ASTERISK_USER`: User that will run `Asterisk` inside the container;
- `ASTERISK_GROUP`: Group that will run `Asterisk` inside the container;
- `ASTERISK_ETC_DIR`: Directory where the configuration files are stored in the container;
  - `ASTERISK_TEMP_ETC_DIR`: Directory used to store the configuration files via mounted volume, and to avoid overwriting of the original files on the host;
- `ASTERISK_LOG_DIR`: Directory where the log files are stored in the container (will be available in the host, as a mounted volume as used and points to this directory);

**Note:** Keep in mind that more environment variables could be introduced to make the container and the configuration more flexible.

## Networks

By default, this build was built for a local environment. But could be used for other purposes, should only be needed to changes the networks on `docker-compose` file and change the IP address on `.env` file.

Requirements:

- `common-network`: This is a external network used in common with other containers, like: `kamailio` and `postgres` container. More details about how to create the network are described in: [postgres-kamailio-docker](https://github.com/bundasmanu/postgres-kamailio-docker);

## Integration with Kamailio

The integration with `Kamailio` is quite simple. Inside `pjsip.conf` and `extensions.conf` files, are included examples, how to integrate both.
On [kamailio-docker](https://github.com/bundasmanu/kamailio-docker); side, we only need to update `dispatcher` and `carrier_dids` logic to balance to the `Asterisk` container, on both sides;

## Build image

```sh
docker compose build asterisk
```

## Run Asterisk

```sh
docker compose up asterisk -d
```

### Run Multiple Instances

At this phase, to run multiple instance, we only need to update the listen IP, used to execute the container. No more is required.
In the future, makes sense to customize a bit more the configuration files, to address RTP/SIP IP's ports dinamically, etc.

After that, run container as usual:

```sh
docker compose up asterisk -d
```

## CLI Interface

```sh
docker exec -it asterisk asterisk -r
```

## Some considerations

- In the future configuration files,could be managed by `ansible`, `consul`, ...;
  - If we want to avoid volumes, we could copy on build;

- More configuration files, could be introduced;
  - Scripts;
- More environment variables could be introduced, to handle and manage more things;
