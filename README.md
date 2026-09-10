# BookExpert — экспертная система оценки и выбора книг

Курсовой проект по дисциплине «Методики разработки современных WEB-приложений».
Ruby on Rails 8 + PostgreSQL. Оценка книг непрерывным ползунком 1–100, кастомная сессионная
авторизация на `bcrypt`, локализация ru/en, асинхронная рабочая область на Fetch API + JSON REST API,
экспорт оценок в CSV.

## Требования

- Ruby 3.3.x
- Rails 8.0.x
- PostgreSQL 14+
- Node.js **не нужен** (используются import maps и Propshaft)

## Развёртывание с нуля

```bash
# 1. Создать каркас приложения Rails 8 с PostgreSQL
rails new book_expert --database=postgresql --skip-test
cd book_expert

# 2. Скопировать поверх каркаса файлы из этого репозитория
#    (Gemfile, config/, db/, app/, README.md). Файлы с теми же именами — заменить.

# 3. Установить гемы
bundle install

# 4. Указать доступ к PostgreSQL (по умолчанию postgres/postgres на localhost:5432)
export DB_USERNAME=postgres
export DB_PASSWORD=postgres

# 5. Создать базы, применить миграции и загрузить начальные данные
bin/rails db:create db:migrate db:seed

# 6. Запустить сервер
bin/rails server
```

Приложение доступно на <http://localhost:3000>.
Демо-доступ: `expert@example.com` / `password`.

## Структура

```
app/
  controllers/
    application_controller.rb        # set_locale, current_user, logged_in?, authorize, catch_404
    sessions_controller.rb           # new / create / destroy — ручное управление session[:user_id]
    users_controller.rb              # регистрация
    books_controller.rb              # каркас рабочей области
    profiles_controller.rb           # личный кабинет + экспорт CSV
    api/v1/books_api_controller.rb   # JSON API: GET/POST /api/v1/books
  models/
    user.rb                          # has_secure_password
    genre.rb
    book.rb
    evaluation.rb                    # rating 1..100, uniqueness, Evaluation.to_csv
  views/
    layouts/application.html.erb
    sessions/new.html.erb
    users/new.html.erb
    books/index.html.erb             # ползунок-хлястик
    profiles/show.html.erb
  javascript/
    application.js
    books_evaluation.js              # Vanilla JS, Fetch API
  assets/stylesheets/application.css
config/
  routes.rb                          # scope "(:locale)", namespace :api / :v1
  importmap.rb
  database.yml
  initializers/locale.rb
  locales/ru.yml, en.yml
db/
  migrate/                           # users, genres, books, evaluations
  seeds.rb                           # 3 жанра, 10 книг, демо-пользователь
report/
  report.tex                         # пояснительная записка (LaTeX, ГОСТ)
```

## API

| Метод | URL                          | Назначение                                   |
|-------|------------------------------|----------------------------------------------|
| GET   | `/api/v1/books?genre_id=1`   | Первая неоценённая книга жанра для текущего пользователя |
| POST  | `/api/v1/books`              | Сохранить оценку `{book_id, rating, comment}` |

Оба метода требуют активной сессии (cookie); без неё возвращается `401 {"error": "..."}`.
Для запросов из Postman необходимо предварительно выполнить вход через форму `/login`
и передавать cookie сессии, а для POST — заголовок `X-CSRF-Token` со значением из
`<meta name="csrf-token">` страницы.

## Сборка отчёта

```bash
cd report
pdflatex report.tex
pdflatex report.tex   # второй проход — для оглавления и ссылок
```
