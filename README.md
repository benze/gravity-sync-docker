[![CI Pipeline](https://github.com/benze/gravity-sync-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com//benze/gravity-sync-docker/actions/workflows/docker-image.yml)
# Gravity Sync Docker

https://github.com/benze/gravity-sync-docker

These are the files required to run a Docker image running [Gravity Sync](https://github.com/vmstan/gravity-sync). Supports X86/64 and ARM.

Heavily inspired by:
- https://github.com/systemofapwne/gravity-sync
- https://github.com/nh-mike/gravity-sync-docker


## Purpose of the container
This container was designed to run alongside a PiHole 5+ container runtime.  The purpose was to be able to run Gravity-Sync between 
two containers running PiHole 5+ without requiring installation of the Gravity-Sync scripts on the Host Engine.

This container is fully self-contained.  It uses a Docker-In-Docker (dind) container to access the docker demon and the PiHole container. 
This requires the mount of the /var/run/docker.sock socket for the DIND's docker to leverage.  Due to the way that Gravity-Sync accesses
the PiHole configuration files, the PiHole config files must also be mounted to the container.  It has NOT been tested using volume mounts. 



#### Before Running!
As always, fully backup your PiHole configuration folders before running the container.


#### Manual pre-launch
Pre-generate your SSH keys and mount them into the container. Follow the instructions in the [SSH Keys section](#ssh-keys). I also recommend you create a user on the remote machine for the purpose of receiving the SSH connection. I personally created the user gravitysync. See the sections [SSH Keys](#ssh-keys) and [User Creation Recommendation](#user-creation-recommendation) below.

#### Configuration of the container
For instructions on how to configure the Gravity Sync service, please see https://github.com/vmstan/gravity-sync<br />
All configuration values from the gravity-sync project can be specified as docker environment variables.
By default, the container is built with ENV vars to point to the correct location of the docker/podman executables as well
as specifying the LOCAL and REMOTE types as podman.

The use of podman type for REMOTE and LOCAL PIHOLE TYPE (rather than DIND) is because the logic for podman or a DIND container would be the same and
gravity-script does not provide an explicit option for DIND.  If you want to use automatic detection of the remote Pihole type,
set REMOTE_PIHOLE_TYPE to empty string in the docker environment.


It is important to note that in the interests of making configuration values more sensical to most people, not all setting names in this "Docker Image" are identical to those in "Vanialla Gravity Sync". You can see these changes marked with an explaimation mark in the table below. Simply, the defined Environmental variables are mapped to the settings name upon the container's first run (install run) when the container builds the configuration file. Please do not try to mount your own configuration file as this will cause failure of the container.

|| Vanilla GS          | Docker Image                                                                                            |
| ------ |---------------------|---------------------------------------------------------------------------------------------------------|
|| REMOTE_HOST         | Remote host to conect to                                                                                |
|| GS_SSH_PORT         | Remote SSH port (need to map port 22 of this container to an external accessible port                   |
|| REMOTE_USER         | Remote SSH user (gravityscript by default)                                                              |
|| LOCAL_USER          | Unpriviledged local account (automatically created by container if not present) - `gravitysync` by default 
|| GS_AUTO_MODE        | Mode to use to launch Gravity Script  (default = sync)                                                  
|| GS_AUTO_DELAY       | Delay between gravity-script executions for the cron job                                                |
|| GS_AUTO_JITTER      | Random delay (# seconds) to offset from each execution                                                  |
|| GS_AUTO_DEBUG       | Overrwites the AUTO_DELAY and AUTO_JITTER to 1 & 0 respectively for debugging purposes                  |
|| LOCAL_FILE_OWNER    | Defaults to 999:1000 to match the PiHole user & group present in the official PiHole container          | 
|| REMOTE_FILE_OWNER   | Defaults to 999:1000 to match the PiHole user & group present in the official PiHole container       | 
|| GS_SSH_PKIF         | Path to the ssh key to use to connect to the remote SSH instance                                        |

#### Docker Compose example:
```

version: "3.8"

services:
  pihole:
    image: pihole/pihole
    container_name: pihole
    restart: unless-stopped
    environment:
      WEBPASSWORD: "admin"
    ports:
      # Webinterface on HOST of main
      - "8081:80"
      - "5553:53/tcp"
      - "5553:53/udp"
    volumes:
      - /docker/pihole/etc/pihole:/etc/pihole
      - /docker/pihole/etc/dnsmasq.d:/etc/dnsmasq.d:rw

gravitysync:
  build:
    dockerfile: Dockerfile
  container_name: "gravitysync"
  restart: "unless-stopped"
  environment:
    TZ: "ETC/UTC"
    LOCAL_DOCKER_CONTAINER: "pihole"
    REMOTE_DOCKER_CONTAINER: "pihole"
    REMOTE_HOST: "10.1.2.3"
    REMOTE_USER: "gravitysync"
    GS_SSH_PORT: 2222
    GS_SSH_PKIF: "~/.ssh/id_ed25519"
  ports:
    # SSH port on HOST of main (for to allow for external container to connnect)
    - "2222:22"    
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /docker/gravity-sync:/config:rw
    - /docker/pihole/etc/pihole:/etc/pihole
    - /docker/pihole/etc/dnsmasq.d:/etc/dnsmasq.d
    - /docker/gravity-sync/ssh/id_ed25519.pub:/config/home/.ssh/authorized_keys:ro
    - /docker/gravity-sync/ssh/id_ed25519:/config/.ssh/id_ed25519:ro

```

#### Mount Points
The following are the mount points within the container. You can map them to wherever you like on your host.

###### Docker Socket
`/var/run/docker.sock - READ ONLY`<br />
This is required to allow the container to interact with the Docker process on the host, to pass along commands to your PiHole container.<br />
It is located at `/var/run/docker.sock` and should be mounted at `/var/run/docker.sock` and only requires read access.

######  PiHole Configuration Directory
`/etc/pihole/ - READ / WRITE`<br />
This is where your gravity database sits. On a standard PiHole install, it would sit at `/etc/pihole`. Ensure that wherever you mount this in the Gravity Sync container, you configure the ***LOCAL_PIHOLE_DIR*** to the same value (directory within the container). I personally prefer to mount it at `/etc/pihole/`.

`/etc/dnsmasq.d/ - READ / WRITE`<br />
This is where your gravity database sits. On a standard PiHole install, it would sit at `/etc/dnsmasq.d`. Ensure that wherever you mount this in the Gravity Sync container, you configure the ***LOCAL_PIHOLE_DIR*** to the same value (directory within the container). I personally prefer to mount it at `/etc/dnsmasq.d/`.

###### Gravity Sync Log Files
`/config`<br />
This is where all configuration is located for the container.

| Path                    | Used for                                                                                                                                                                                                                                                                                                     |
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `/config/.ssh`          | Private ssh key used to connect to remote system                                                                                                                                                                                                                                                             |
| `/config/home/.ssh`     | Public key location used to authenticate against the `REMOTE_USER` 
| `/config/ssh_host_keys` | Host SSH keys (generated by ssh-keygen -A) used by sshd server.  Automatically created at startup time if not present                                                                                                                                                                                        |
| `/config/gravity-sync`  | Configuration file and log folder for the gravity-sync.  Gravity Sync keeps a log file of it's most recent Cron run and also records of previous runs. You may find it useful to mount these from the host for easy viewing and also, if you wish to persist your logs between container rebuilds executable |


###### Gravity Sync Log Files
`/config/gravity-sync/gravity-sync/logs/gravity-sync.log - READ / WRITE`<br />
`/config/gravity-sync/gravity-sync/logs/gravity-sync.cron - READ / WRITE`<br />
Gravity Sync keeps a log file of it's most recent Cron run and also records of previous runs. You may find it useful to mount these from the host for easy viewing and also, if you wish to persist your logs between container rebuilds.

###### Gravity Sync MD5 File
`/config/gravity-sync/gravity-sync/gravity-sync.md5 - READ / WRITE`<br />
Gravity Sync records the MD5 hash for both the local and remote gravity.db, custom.list and 05-pihole-custom-cname.conf within this file. Ideally, we want to preserve these hashes between instances of the container.

###### SSH Keys Directory
`/config/.ssh/ - READ ONLY*`<br />
SSH Keys must be configured and in place before the container is run for the first time. Without this, the initial run will try to generate keys. Without persisting this directory, the container continue to generate new keys with each run and so will be unable to connect to the remote host. Review the [SSH Keys section](#ssh-keys) below.

#### User Creation Recommendation
The container will automatically create an unprivileged user `LOCAL_USER` upon startup if it is not already present, and set the home path to /config/home.
This user is used by a remote process to connect via SSH to the container to execute requisite tasks.  Therefore the `/config/home/.ssh/authorized_keys` should contain
the public key from the keypair used on the remote machine to connect (the one in the `/root/.ssh` folder on the remote machine)

I also reccomend for the security conscious, to create a more locked down sudoers file, following the discussion [here](https://github.com/vmstan/gravity-sync/discussions/153).

#### SSH KEYS
In order to communicate with the remote host, SSH keys are required. An easy way to generate them is using the OpenSSH client. Using the following single liner, we can be sure on being able to generate these keys on any system.<br />
`docker run -t -i --rm alpine:latest apk --update add openssh-client && ssh-keygen -t ed25519 -f /tmp/id_rsa`<br />

#### Upgrade Instructions
###### 4.0.0
This version is not backwards compatible with previous versions of this container or script and must be reiniitialized
