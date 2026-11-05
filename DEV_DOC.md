# Developer documentation

## Set up from scratch

1. In a Linux VM, install Docker, Docker Compose, Make and OpenSSL, and add your user to the `docker` group.
2. Point the domain to the machine:

   ```sh
   echo "127.0.0.1 amezoe.42.fr" | sudo tee -a /etc/hosts
   ```

3. Clone the repository and run `make`.

The first `make` creates everything git doesn't store:

- `srcs/.env`, copied from `srcs/.env.example`
- `secrets/*.txt`, with random passwords
- `/home/amezoe/data/mariadb` and `/home/amezoe/data/wordpress`

To use your own values, edit `srcs/.env` or write your own files in `secrets/` before the first `make`.

## Makefile

| Target | Effect |
|---|---|
| `make` | Run `setup`, then build the images and start the containers |
| `make setup` | Create `.env`, the secrets and the data folders |
| `make down` | Remove the containers, keeping images and volumes |
| `make re` | `down`, then `make` |
| `make clean` | Also remove the project's images and Docker volumes, keeping the data on the host |
| `make fclean` | Also delete the data on the host and the secrets (uses `sudo`) |

## Useful commands

```sh
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml build --no-cache nginx
docker exec -it mariadb sh
docker network ls
docker volume ls
docker volume inspect inception_mariadb
```

Log in to the database and check that it isn't empty:

```sh
docker exec -it mariadb sh -c 'mariadb -u root -p"$(cat /run/secrets/db_root_password)" wordpress'
```
```sql
SHOW TABLES;
SELECT user_login FROM wp_users;
```

## Changing the configuration

- **Public port:** set `HTTPS_PORT` in `srcs/.env` and run `make re`. WordPress picks up the new URL on start.
- **NGINX internal port:** change `listen` in `nginx/config/default` and the right side of `ports` in `docker-compose.yml`.
- **php-fpm port:** change `listen` in `wordpress/Dockerfile` and `fastcgi_pass` in `nginx/config/default`.
- **MariaDB port:** change `--port` in `mariadb/tools/setup.sh` and add the port to `--dbhost` in `wordpress/tools/setup.sh`. If the site is already installed, first run `docker exec wordpress wp config set DB_HOST mariadb:<port> --allow-root`.

Run `make re` after each change.

## Data and persistence

| Docker volume | Mounted at | Data on the host |
|---|---|---|
| `inception_mariadb` | `/var/lib/mysql` | `/home/amezoe/data/mariadb` |
| `inception_wordpress` | `/var/www/html` (WordPress and NGINX) | `/home/amezoe/data/wordpress` |

Data stays on the host, so it survives `make down`, `make clean` and a reboot. Only `make fclean` deletes it.

Both setup scripts skip the installation when the data already exists, so a restart never reinstalls anything.
