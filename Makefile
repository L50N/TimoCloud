.PHONY: help build up down logs clean restart status health

help:
	@echo "  build          - Build all Docker images"
	@echo "  up             - Start all services"
	@echo "  up-{SERVICE}   - Start only core services (core, base, cord)"
	@echo "  down           - Stop all services"
	@echo "  logs           - Show logs from all services"
	@echo "  logs-core      - Show logs from core service"
	@echo "  logs-base      - Show logs from base service"
	@echo "  logs-cord      - Show logs from cord service"
	@echo "  restart        - Restart all services"
	@echo "  status         - Show status of all services"
	@echo "  clean          - Clean up containers and volumes"
	@echo "  clean-all      - Clean up everything including images"
	@echo "  shell-core     - Open shell in core container"
	@echo "  shell-base     - Open shell in base container"
	@echo "  shell-cord     - Open shell in cord container"

build:
	docker compose build --no-cache

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

logs-core:
	docker compose logs -f timocloud-core

logs-base:
	docker compose logs -f timocloud-base

logs-cord:
	docker compose logs -f timocloud-cord

restart:
	docker compose restart

restart-core:
	docker compose restart timocloud-core

restart-base:
	docker compose restart timocloud-base

restart-cord:
	docker compose restart timocloud-cord

status:
	docker compose ps

shell-core:
	docker compose exec timocloud-core /bin/bash

shell-base:
	docker compose exec timocloud-base /bin/bash

shell-cord:
	docker compose exec timocloud-cord /bin/bash

clean:
	docker compose down -v
	docker system prune -f

clean-all:
	docker compose down -v --rmi all
	docker system prune -a -f