USER = $(shell whoami)

DATA_PATH = /home/$(USER)/data
DOCKER_COMPOSE = docker compose -f ./srcs/docker-compose.yml

all: build

build: setup
	@echo "Lancement du build des conteneurs..."
	$(DOCKER_COMPOSE) up --build -d

bonus: build
	docker compose -f docker-compose-bonus.yml up --build -d

setup:
	@echo "Préparation des dossiers de données..."
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

stop:
	@echo "Arrêt des conteneurs..."
	$(DOCKER_COMPOSE) stop

start:
	@echo "Démarrage des conteneurs..."
	$(DOCKER_COMPOSE) start

down:
	@echo "Suppression des conteneurs..."
	$(DOCKER_COMPOSE) down

re: fclean all

clean:
	@echo "Nettoyage des conteneurs et réseaux..."
	$(DOCKER_COMPOSE) down --rmi all --volumes

fclean: clean
	@echo "Suppression totale des données et des volumes..."
	@sudo rm -rf $(DATA_PATH)/mariadb
	@sudo rm -rf $(DATA_PATH)/wordpress
	@docker system prune -a --force

.PHONY: all build setup stop start down re clean fclean
