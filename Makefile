.PHONY: help build up down logs clean restart status

help:
	@echo "  build          - Build all Docker images"
	@echo "  up             - Start all services"
	@echo "  down           - Stop all services"
	@echo "  logs           - Show logs from all services"
	@echo "  restart        - Restart all services"
	@echo "  status         - Show status of all services"
	@echo "  clean          - Clean up containers and volumes"
	@echo "  clean-all      - Clean up everything including images"
	@echo "  shell  	    - Open shell in container"

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

clean:
	docker compose down -v
	docker system prune -f

clean-all:
	docker compose down -v --rmi all
	docker system prune -a -f