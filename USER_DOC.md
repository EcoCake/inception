# User documentation

## Services

- **NGINX**: receives all visits, over HTTPS on port 443.
- **WordPress**: the website and its administration panel.
- **MariaDB**: the database that stores the site's content and users.

## Start and stop

Run these from the root of the repository:

| Command | Effect |
|---|---|
| `make` | Build if needed and start everything |
| `make down` | Stop and remove the containers, keeping all data |
| `make re` | Restart with a rebuild, keeping all data |

## Access the website

- Website: <https://amezoe.42.fr>
- Administration panel: <https://amezoe.42.fr/wp-admin>

The certificate is self-signed, so the browser shows a warning that you need to accept. The address must point to this machine; see [DEV_DOC.md](DEV_DOC.md) if it doesn't load.

## Credentials

Passwords are created by the first `make` and stored in `secrets/`. Usernames are in `srcs/.env`.

| Account | Username (`srcs/.env`) | Password file |
|---|---|---|
| WordPress administrator | `WP_ADMIN_USER` | `secrets/wp_admin_password.txt` |
| WordPress author | `WP_USER` | `secrets/wp_user_password.txt` |
| Database user | `MYSQL_USER` | `secrets/db_password.txt` |
| Database root | `root` | `secrets/db_root_password.txt` |

Passwords are only applied during the first installation. Changing a file later doesn't change the password of an existing account, unless the data is wiped with `make fclean`.

Never commit these files. They are already ignored by git.

## Check that it works

```sh
docker compose -f srcs/docker-compose.yml ps    # all three "Up", mariadb "healthy"
docker compose -f srcs/docker-compose.yml logs  # logs of every service
curl -kI https://amezoe.42.fr                   # should answer HTTP 200
```
