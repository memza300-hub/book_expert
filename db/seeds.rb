# Начальные данные приложения BookExpert.
# Запуск: bin/rails db:seed (или bin/rails db:setup для создания БД, миграций и сидов сразу).
#
# Загрузка идемпотентна: существующие записи удаляются и создаются заново,
# поэтому файл можно запускать повторно без дублирования данных.

puts "==> Очищаю таблицы..."
Evaluation.delete_all
Book.delete_all
Genre.delete_all
User.delete_all

# Сброс последовательностей PostgreSQL (гем activerecord-reset-pk-sequence),
# чтобы идентификаторы после повторной загрузки снова начинались с 1
User.reset_pk_sequence
Genre.reset_pk_sequence
Book.reset_pk_sequence
Evaluation.reset_pk_sequence

puts "==> Создаю жанры..."
classics = Genre.create!(
  name_ru: "Русская классика",
  name_en: "Russian classics"
)

scifi = Genre.create!(
  name_ru: "Научная фантастика",
  name_en: "Science fiction"
)

programming = Genre.create!(
  name_ru: "Книги о программировании",
  name_en: "Books on programming"
)

puts "==> Создаю книги..."
Book.create!([
  # ---------- Русская классика ----------
  {
    genre: classics,
    title_ru: "Преступление и наказание",
    title_en: "Crime and Punishment",
    author_ru: "Фёдор Достоевский",
    author_en: "Fyodor Dostoevsky",
    year: 1866,
    description_ru: "Бывший студент Родион Раскольников убивает старуху-процентщицу, чтобы проверить свою теорию о «право имеющих», и на протяжении романа проходит путь от гордыни и оправдания к мучительному раскаянию. Психологический роман о совести, вине и цене идеи.",
    description_en: "Former student Rodion Raskolnikov kills an old pawnbroker to test his theory of extraordinary men and spends the novel travelling from pride and self-justification to agonising repentance. A psychological novel about conscience, guilt and the price of an idea.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780140449136-L.jpg"
  },
  {
    genre: classics,
    title_ru: "Мастер и Маргарита",
    title_en: "The Master and Margarita",
    author_ru: "Михаил Булгаков",
    author_en: "Mikhail Bulgakov",
    year: 1967,
    description_ru: "В Москву 1930-х годов прибывает Воланд со своей свитой, и город погружается в череду мистических происшествий. Параллельно разворачивается история Мастера, написавшего роман о Понтии Пилате, и Маргариты, готовой на всё ради его спасения. Сатира, мистика и история любви в одной книге.",
    description_en: "Woland and his retinue arrive in 1930s Moscow and the city plunges into a series of supernatural events. In parallel unfolds the story of the Master, who wrote a novel about Pontius Pilate, and Margarita, ready to do anything to save him. Satire, mysticism and a love story in one book.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780141180144-L.jpg"
  },
  {
    genre: classics,
    title_ru: "Война и мир",
    title_en: "War and Peace",
    author_ru: "Лев Толстой",
    author_en: "Leo Tolstoy",
    year: 1869,
    description_ru: "Роман-эпопея о судьбах нескольких дворянских семей на фоне войн с Наполеоном 1805–1812 годов. Пьер Безухов, Андрей Болконский и Наташа Ростова ищут смысл жизни, любовь и своё место в истории, а автор размышляет о природе власти, свободы и народного духа.",
    description_en: "An epic novel about several noble families set against the Napoleonic wars of 1805-1812. Pierre Bezukhov, Andrei Bolkonsky and Natasha Rostova search for the meaning of life, love and their place in history, while the author reflects on the nature of power, freedom and the spirit of the people.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780140447934-L.jpg"
  },
  {
    genre: classics,
    title_ru: "Герой нашего времени",
    title_en: "A Hero of Our Time",
    author_ru: "Михаил Лермонтов",
    author_en: "Mikhail Lermontov",
    year: 1840,
    description_ru: "Первый психологический роман русской литературы. Пять новелл, рассказанных разными голосами, складываются в портрет Григория Печорина — умного, разочарованного и разрушительного для всех, кто оказывается рядом. Кавказ, дуэли, любовь и скука «лишнего человека».",
    description_en: "The first psychological novel in Russian literature. Five stories told by different narrators form a portrait of Grigory Pechorin: clever, disillusioned and destructive to everyone around him. The Caucasus, duels, love and the boredom of the superfluous man.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780140447958-L.jpg"
  },

  # ---------- Научная фантастика ----------
  {
    genre: scifi,
    title_ru: "Дюна",
    title_en: "Dune",
    author_ru: "Фрэнк Герберт",
    author_en: "Frank Herbert",
    year: 1965,
    description_ru: "Пустынная планета Арракис — единственный источник пряности, самого ценного вещества во Вселенной. Юный Пол Атрейдес теряет дом и семью в результате заговора и находит убежище среди фрименов, чтобы стать лидером, которого предсказывали пророчества. Политика, экология и религия в масштабе галактики.",
    description_en: "The desert planet Arrakis is the only source of the spice, the most valuable substance in the universe. Young Paul Atreides loses his home and family to a conspiracy and finds refuge among the Fremen to become the leader foretold by prophecy. Politics, ecology and religion on a galactic scale.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780441172719-L.jpg"
  },
  {
    genre: scifi,
    title_ru: "Пикник на обочине",
    title_en: "Roadside Picnic",
    author_ru: "Аркадий и Борис Стругацкие",
    author_en: "Arkady and Boris Strugatsky",
    year: 1972,
    description_ru: "После кратковременного визита инопланетян на Земле остались Зоны — территории, полные смертельных аномалий и загадочных артефактов. Сталкер Рэдрик Шухарт рискует жизнью, вынося из Зоны находки, и мечтает добраться до Золотого Шара, исполняющего желания. Повесть, породившая целую культуру.",
    description_en: "After a brief alien visit, Earth is left with the Zones: areas full of deadly anomalies and mysterious artefacts. Stalker Redrick Schuhart risks his life smuggling finds out of the Zone and dreams of reaching the Golden Sphere that grants wishes. The novel that spawned an entire culture.",
    image_url: "https://covers.openlibrary.org/b/isbn/9781613743416-L.jpg"
  },
  {
    genre: scifi,
    title_ru: "1984",
    title_en: "Nineteen Eighty-Four",
    author_ru: "Джордж Оруэлл",
    author_en: "George Orwell",
    year: 1949,
    description_ru: "В тоталитарной Океании Уинстон Смит работает в Министерстве правды, переписывая историю, и тайно ненавидит Партию и Большого Брата. Запретная любовь и попытка сопротивления приводят его в комнату 101. Антиутопия о языке, памяти и власти, подарившая миру понятия «новояз» и «двоемыслие».",
    description_en: "In totalitarian Oceania Winston Smith works at the Ministry of Truth rewriting history and secretly hates the Party and Big Brother. A forbidden love and an attempt at resistance lead him to Room 101. A dystopia about language, memory and power that gave the world the words Newspeak and doublethink.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg"
  },

  # ---------- Книги о программировании ----------
  {
    genre: programming,
    title_ru: "Чистый код",
    title_en: "Clean Code",
    author_ru: "Роберт Мартин",
    author_en: "Robert C. Martin",
    year: 2008,
    description_ru: "Сборник принципов и практик написания кода, который легко читать, поддерживать и изменять: осмысленные имена, маленькие функции, отсутствие дублирования, аккуратная обработка ошибок и тесты. Книга, с которой начинается разговор о профессионализме программиста.",
    description_en: "A collection of principles and practices for writing code that is easy to read, maintain and change: meaningful names, small functions, no duplication, careful error handling and tests. The book that starts the conversation about professionalism in programming.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg"
  },
  {
    genre: programming,
    title_ru: "Совершенный код",
    title_en: "Code Complete",
    author_ru: "Стив Макконнелл",
    author_en: "Steve McConnell",
    year: 2004,
    description_ru: "Энциклопедия конструирования программ: от проектирования классов и подпрограмм до отладки, рефакторинга и оптимизации. Макконнелл опирается на исследования и цифры, а не на вкусовщину, поэтому книга остаётся актуальной спустя двадцать лет.",
    description_en: "An encyclopaedia of software construction: from designing classes and routines to debugging, refactoring and optimisation. McConnell relies on research and numbers rather than taste, which is why the book remains relevant twenty years later.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780735619678-L.jpg"
  },
  {
    genre: programming,
    title_ru: "Программист-прагматик",
    title_en: "The Pragmatic Programmer",
    author_ru: "Эндрю Хант, Дэвид Томас",
    author_en: "Andrew Hunt, David Thomas",
    year: 1999,
    description_ru: "Книга о ремесле программиста: как думать о задачах, как не повторяться (DRY), как автоматизировать рутину и отвечать за свой код. Написана в форме коротких советов с историями из практики и до сих пор считается одной из лучших книг для роста от джуниора к сеньору.",
    description_en: "A book about the craft of programming: how to think about problems, how not to repeat yourself (DRY), how to automate routine and take responsibility for your code. Written as short tips with stories from practice, it is still considered one of the best books for growing from junior to senior.",
    image_url: "https://covers.openlibrary.org/b/isbn/9780135957059-L.jpg"
  }
])

puts "==> Создаю демонстрационного пользователя..."
demo = User.create!(
  email: "expert@example.com",
  password: "password",
  password_confirmation: "password"
)

puts "==> Добавляю несколько демонстрационных оценок..."
Evaluation.create!([
  {
    user: demo,
    book: Book.find_by!(title_en: "The Master and Margarita"),
    rating: 96,
    comment: "Перечитывал трижды, и каждый раз находил новые смыслы. Идеальный баланс сатиры и лирики."
  },
  {
    user: demo,
    book: Book.find_by!(title_en: "Dune"),
    rating: 88,
    comment: "Медленное начало, но мир Арракиса затягивает полностью."
  },
  {
    user: demo,
    book: Book.find_by!(title_en: "Clean Code"),
    rating: 74,
    comment: "Полезно, хотя часть примеров на Java устарела."
  }
])

puts "==> Готово: #{Genre.count} жанра, #{Book.count} книг, #{User.count} пользователь, #{Evaluation.count} оценки."
puts "    Демо-доступ: expert@example.com / password"
