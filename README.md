*This project has been created as part of the 42 curriculum by amezoe.*

# Inception

## Description

Inception sets up a small web infrastructure with Docker Compose, inside a virtual machine. A WordPress website runs on three containers, each built from its own Dockerfile on `debian:bookworm`, the penultimate stable Debian:

| Service | Role | Port (internal) |
|---|---|---|
| `nginx` | HTTPS only entry point (TLSv1.2 and TLSv1.3) | 443 |
| `wordpress` | WordPress and php-fpm | 9000 |
| `mariadb` | Database | 3306 |

Only NGINX publishes a port on the host. The containers talk to each other over a private Docker network, and two named volumes keep the data.

## Project description

### Use of Docker and sources

The `Makefile` calls `srcs/docker-compose.yml`, which builds the three images from `srcs/requirements/<service>/` and starts them.

- `nginx/config/default` is the NGINX server configuration.
- Each `tools/setup.sh` does the first-start setup, then uses `exec` to replace itself with the service, so the service runs as PID 1.
- `srcs/.env` holds the non-sensitive settings. It is created from `srcs/.env.example`.
- `secrets/` holds the passwords. `make` generates them randomly.

Both `srcs/.env` and `secrets/` are ignored by git.

### Main design choices

- **Debian rather than Alpine:** the penultimate version stays the same for much longer, and the packages are well documented.
- **Healthcheck instead of a wait loop:** WordPress waits for MariaDB through `depends_on: condition: service_healthy`, so no script needs a loop. If MariaDB is down during a reboot, the WordPress container exits and `restart: always` retries it.
- **WordPress URL set on every start:** the port can be changed with a single line in `.env`.
- **Generated passwords:** they exist only locally, and a fresh clone runs with a single `make`.

### Virtual Machines vs Docker

A VM emulates a whole machine and boots its own kernel, so it is heavy but strongly isolated. A container is an isolated group of processes that shares the host's kernel, so it starts in seconds, uses less memory, and its image can be rebuilt the same way anywhere. The isolation is weaker. This project uses both: the containers run inside a VM.

### Secrets vs Environment Variables

Environment variables are simple, but any process in the container can read them, and they appear in `docker inspect`. Docker secrets are files mounted at `/run/secrets/` only in the services that declare them, and they don't appear in the container's configuration. Here, settings such as the domain name are environment variables and all passwords are secrets.

### Docker Network vs Host Network

On a Docker bridge network, containers have their own network stack, reach each other by service name (`wordpress:9000`), and are reachable from outside only through published ports. With the host network, a container shares the host's network stack, so every port it opens is exposed and there is no isolation. That is why only port 443 is published here, and why host networking is forbidden.

### Docker Volumes vs Bind Mounts

A named volume is managed by Docker: it has a name and can be listed and inspected with `docker volume`. A bind mount maps a chosen host path directly into a container, so it depends on the host's folder layout. This project uses named volumes with `driver_opts`, which makes Docker store their data in `/home/<login>/data` while they remain named volumes.

## Instructions

Requirements: a Linux VM with Docker, Docker Compose, Make and OpenSSL.

```sh
echo "127.0.0.1 amezoe.42.fr" | sudo tee -a /etc/hosts
make
```

Then open <https://amezoe.42.fr> and accept the self-signed certificate warning.

See [USER_DOC.md](USER_DOC.md) for how to use the stack and [DEV_DOC.md](DEV_DOC.md) for development details.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Compose file reference](https://docs.docker.com/reference/compose-file/)
- [Dockerfile best practices](https://docs.docker.com/build/building/best-practices/)
- [Compose secrets](https://docs.docker.com/compose/how-tos/use-secrets/)
- [NGINX: configuring HTTPS servers](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WP-CLI commands](https://developer.wordpress.org/cli/commands/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Inception VM guide](https://github.com/Bakr-1/inceptionVm-guide)
- [Inception reference by Forstman1](https://github.com/Forstman1/inception-42)

### Use of AI

Claude Code (Anthropic) was used to read the subject and evaluation sheet, generate the first version of the Makefile, Compose file, Dockerfiles, configuration files and setup scripts, draft this documentation, and test the stack against the evaluation sheet. All of it was then reviewed and tested by the author.
