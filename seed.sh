#!/bin/sh
# Однократная загрузка начальных данных (жанры, книги, пользователи) в продакшн-БД.
docker compose exec app ./bin/rails db:seed
