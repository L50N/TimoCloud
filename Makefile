.PHONY: help build up down logs clean restart status shell

help:
	@echo "  build          - Build Docker image"
	@echo "  up             - Start TimoCloud container"
	@echo "  down           - Stop TimoCloud container"
	@echo "  logs           - Show logs from container"
	@echo "  restart        - Restart container"
	@echo "  status         - Show container status"
	@echo "  shell          - Open shell in container"
	@echo "  screen-core    - Connect to core screen session"
	@echo "  screen-base    - Connect to base screen session"
	@echo "  screen-cord    - Connect to cord screen session"
	@echo "  clean          - Clean up container and volumes"
	@echo "  clean-all      - Clean up everything including images"

build:
	docker compose build --no-cache

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

restart:
	docker compose restart

status:
	docker compose ps

shell:
	docker compose exec timocloud-main /bin/bash

screen-core:
	docker compose exec timocloud-main screen -x core

screen-base:
	docker compose exec timocloud-main screen -x base

screen-cord:
	docker compose exec timocloud-main screen -x cord

clean:
	docker compose down -v
	docker system prune -f

clean-all:
	docker compose down -v --rmi all
	docker system prune -a -f