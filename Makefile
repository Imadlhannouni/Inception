USER = $(shell whoami)

DATA_PATH = /home/$(USER)/data

COMPOSE_MANDATORY = docker compose -f ./srcs/docker-compose.yml
COMPOSE_BONUS     = docker compose -f ./srcs/docker-compose-bonus.yml

# ===================== MAIN =====================

all: setup up

setup:
	@echo "Création des dossiers de données..."
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress

up:
	@echo "Lancement mandatory..."
	$(COMPOSE_MANDATORY) up --build -d

# ===================== BONUS =====================

bonus: setup up_bonus

up_bonus:
	@echo "Lancement bonus..."
	$(COMPOSE_BONUS) up --build -d

# ===================== CONTROL =====================

stop:
	@echo "Stop mandatory..."
	$(COMPOSE_MANDATORY) stop

stop_bonus:
	@echo "Stop bonus..."
	$(COMPOSE_BONUS) stop

down:
	@echo "Down mandatory..."
	$(COMPOSE_MANDATORY) down

down_bonus:
	@echo "Down bonus..."
	$(COMPOSE_BONUS) down

restart: down up

# ===================== CLEAN =====================

clean:
	@echo "Clean mandatory stack..."
	$(COMPOSE_MANDATORY) down --volumes --rmi all

clean_bonus:
	@echo "Clean bonus stack..."
	$(COMPOSE_BONUS) down --volumes --rmi all

fclean: clean clean_bonus
	@echo "Suppression des données locales..."
	@sudo rm -rf $(DATA_PATH)/mariadb
	@sudo rm -rf $(DATA_PATH)/wordpress
	@docker system prune -f

re: fclean all

.PHONY: all setup up bonus up_bonus stop stop_bonus down down_bonus clean clean_bonus fclean re restart