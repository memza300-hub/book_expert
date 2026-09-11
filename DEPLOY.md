# Развёртывание BookExpert через Docker

## 1. Первая заливка в GitHub (на своём компьютере)

```bash
cd book_expert
git init
git add .
git commit -m "BookExpert: Rails 8 app with tests and Docker setup"
git branch -M main
git remote add origin https://github.com/<USERNAME>/book_expert.git
git push -u origin main
```

Перед `git add` убедиться, что `.gitignore` содержит строки (добавить, если нет):

```
/.env
/.env.*
!/.env.example
/config/master.key
/config/credentials/*.key
/log/*
/tmp/*
/storage/*
```

После push на GitHub во вкладке **Actions** автоматически запустится workflow `CI`
(`.github/workflows/ci.yml`): поднимет PostgreSQL и выполнит `bin/rails test`.

## 2. Подготовка сервера (Ubuntu, один раз)

```bash
sudo apt update && sudo apt install -y ca-certificates curl git
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER      # перелогиниться после этого
```

## 3. Первый запуск на сервере

```bash
git clone https://github.com/<USERNAME>/book_expert.git
cd book_expert
cp .env.example .env
nano .env        # DB_PASSWORD, SECRET_KEY_BASE (см. ниже), RAILS_FORCE_SSL
```

Сгенерировать `SECRET_KEY_BASE`:

```bash
docker compose build web
docker compose run --rm --no-deps -e SECRET_KEY_BASE=tmp web ./bin/rails secret
```

Запуск:

```bash
SEED_ON_START=true docker compose up -d --build
docker compose logs -f test      # видно прогон тестов
docker compose logs -f web       # затем старт Puma
```

Порядок контейнеров задан в `docker-compose.yml`:
`db` (PostgreSQL, healthcheck) → `test` (`bin/rails test` в базе `book_expert_test`) → `web`
(стартует только если `test` завершился с кодом 0). Если хоть один тест упал — `web` не поднимется,
а в `docker compose ps` контейнер `test` будет со статусом `exited (1)`.

Приложение слушает `127.0.0.1:3000`. Наружу его отдаёт Nginx (конфиг из инструкции по развёртыванию
без Docker — блок `server` с `proxy_pass http://127.0.0.1:3000` — подходит без изменений).
При наличии домена и certbot поставить в `.env` `RAILS_FORCE_SSL=true`.

## 4. Обновление после изменений в коде

```bash
cd book_expert
git pull
docker compose up -d --build     # пересборка образа, прогон тестов, перезапуск web
```

## 5. Полезное

```bash
docker compose ps                          # состояние контейнеров
docker compose run --rm test               # прогнать тесты вручную
docker compose exec web ./bin/rails console
docker compose down                        # остановить (данные БД сохраняются в volume pgdata)
```
