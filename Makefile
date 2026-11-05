COMPOSE = docker compose -f srcs/docker-compose.yml

all: setup
	$(COMPOSE) up -d --build

# Make creates this file from the rule below if it is missing, then reloads.
include srcs/.env

srcs/.env:
	cp srcs/.env.example srcs/.env

# Creates what git must not store: data folders and random passwords.
setup:
	mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress secrets
	@for s in db_root_password db_password wp_admin_password wp_user_password; do \
		[ -f secrets/$$s.txt ] || openssl rand -hex 16 > secrets/$$s.txt; \
	done

down:
	$(COMPOSE) down

# Removes containers, images and volumes, but keeps the data on the host.
clean:
	$(COMPOSE) down -v --rmi all

# Also deletes the website, the database and the passwords.
fclean: clean
	sudo rm -rf $(DATA_PATH)
	rm -rf secrets

re: down all

.PHONY: all setup down clean fclean re
