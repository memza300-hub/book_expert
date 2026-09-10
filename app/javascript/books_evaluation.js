// Expert workspace: asynchronous book evaluation via Fetch API + JSON REST API.
//
// 1. The user picks a genre in <select id="genre-select">.
// 2. The script requests GET /api/v1/books?genre_id=N and renders the first unrated book.
// 3. The HTML5 range input (1..100) works like an Instagram poll sticker:
//    a floating bubble follows the thumb and shows the current value + emoji.
// 4. On submit the script POSTs { book_id, rating, comment } as JSON,
//    fades the card out and requests the next unrated book.

const EMOJI_SCALE = [
  { max: 10, emoji: "\u{1F616}" },
  { max: 25, emoji: "\u{1F615}" },
  { max: 40, emoji: "\u{1F610}" },
  { max: 55, emoji: "\u{1F642}" },
  { max: 70, emoji: "\u{1F60A}" },
  { max: 85, emoji: "\u{1F60D}" },
  { max: 100, emoji: "\u{1F929}" }
];

function emojiFor(value) {
  const match = EMOJI_SCALE.find((step) => value <= step.max);
  return match ? match.emoji : "\u{1F642}";
}

function csrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute("content") : "";
}

function formatTemplate(template, values) {
  return template.replace(/%\{(\w+)\}/g, (_, key) => (values[key] !== undefined ? values[key] : ""));
}

class EvaluationWorkspace {
  constructor(root) {
    this.root = root;
    this.apiUrl = root.dataset.apiUrl;
    this.locale = root.dataset.locale || "ru";
    this.texts = {
      loading: root.dataset.textLoading,
      doneTitle: root.dataset.textDoneTitle,
      doneText: root.dataset.textDoneText,
      pickGenre: root.dataset.textPickGenre,
      progress: root.dataset.textProgress,
      errorNetwork: root.dataset.textErrorNetwork,
      errorSave: root.dataset.textErrorSave,
      submit: root.dataset.textSubmit,
      submitting: root.dataset.textSubmitting,
      noAverage: root.dataset.textNoAverage
    };

    this.genreSelect = root.querySelector("#genre-select");
    this.progress = root.querySelector("#progress");
    this.statusMessage = root.querySelector("#status-message");
    this.card = root.querySelector("#book-card");
    this.donePanel = root.querySelector("#done-panel");
    this.form = root.querySelector("#evaluation-form");
    this.range = root.querySelector("#rating-range");
    this.bubble = root.querySelector("#rating-bubble");
    this.valueLabel = root.querySelector("#rating-value");
    this.emojiLabel = root.querySelector("#rating-emoji");
    this.comment = root.querySelector("#comment");
    this.errors = root.querySelector("#form-errors");
    this.submitButton = root.querySelector("#submit-button");

    this.fields = {
      id: root.querySelector("#book-id"),
      image: root.querySelector("#book-image"),
      genre: root.querySelector("#book-genre"),
      title: root.querySelector("#book-title"),
      author: root.querySelector("#book-author"),
      year: root.querySelector("#book-year"),
      description: root.querySelector("#book-description"),
      average: root.querySelector("#book-average"),
      count: root.querySelector("#book-count")
    };

    this.currentGenreId = null;
    this.isSubmitting = false;

    this.bindEvents();
    this.updateSlider();
  }

  // ---------- Event wiring ----------

  bindEvents() {
    this.genreSelect.addEventListener("change", () => {
      this.currentGenreId = this.genreSelect.value;
      this.hideErrors();

      if (!this.currentGenreId) {
        this.showStatus(this.texts.pickGenre);
        this.hideCard();
        this.hideDone();
        this.progress.textContent = "";
        return;
      }

      this.loadNextBook();
    });

    this.range.addEventListener("input", () => this.updateSlider());

    this.form.addEventListener("submit", (event) => {
      event.preventDefault();
      this.submitEvaluation();
    });

    this.fields.image.addEventListener("error", () => {
      this.fields.image.src = this.placeholderCover();
    });
  }

  // ---------- Slider (Instagram-style sticker) ----------

  updateSlider() {
    const value = Number(this.range.value);
    const min = Number(this.range.min);
    const max = Number(this.range.max);
    const percent = ((value - min) / (max - min)) * 100;

    this.valueLabel.textContent = value;
    this.emojiLabel.textContent = emojiFor(value);
    this.range.setAttribute("aria-valuenow", String(value));

    // Fill the track up to the thumb and move the bubble with the thumb.
    // The thumb is 28px wide, so the bubble is corrected by half its width.
    this.range.style.setProperty("--fill", `${percent}%`);
    this.bubble.style.left = `calc(${percent}% + (${14 - percent * 0.28}px))`;

    const hue = Math.round((value / 100) * 120); // 0 = red, 120 = green
    this.bubble.style.setProperty("--bubble-color", `hsl(${hue} 80% 45%)`);
    this.range.style.setProperty("--fill-color", `hsl(${hue} 80% 45%)`);
  }

  resetForm() {
    this.range.value = 50;
    this.comment.value = "";
    this.updateSlider();
    this.hideErrors();
  }

  // ---------- API calls ----------

  async loadNextBook() {
    this.showStatus(this.texts.loading);
    this.hideDone();
    this.card.classList.add("is-loading");

    try {
      const url = `${this.apiUrl}?genre_id=${encodeURIComponent(this.currentGenreId)}&locale=${this.locale}`;
      const response = await fetch(url, {
        method: "GET",
        headers: { "Accept": "application/json" },
        credentials: "same-origin"
      });

      if (!response.ok) {
        const body = await this.safeJson(response);
        this.showStatus(body.error || `HTTP ${response.status}`);
        this.hideCard();
        return;
      }

      const data = await response.json();
      this.renderProgress(data.rated, data.total);

      if (data.done || !data.book) {
        this.hideCard();
        this.showDone();
        this.hideStatus();
        return;
      }

      this.renderBook(data.book);
    } catch (error) {
      console.error("[BookExpert] loadNextBook failed:", error);
      this.showStatus(this.texts.errorNetwork);
      this.hideCard();
    } finally {
      this.card.classList.remove("is-loading");
    }
  }

  async submitEvaluation() {
    if (this.isSubmitting) return;

    this.isSubmitting = true;
    this.hideErrors();
    this.setSubmitting(true);

    const payload = {
      book_id: Number(this.fields.id.value),
      rating: Number(this.range.value),
      comment: this.comment.value.trim()
    };

    try {
      const response = await fetch(`${this.apiUrl}?locale=${this.locale}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken()
        },
        credentials: "same-origin",
        body: JSON.stringify(payload)
      });

      const body = await this.safeJson(response);

      if (!response.ok) {
        const messages = body.errors || [body.error || `HTTP ${response.status}`];
        this.showErrors(messages);
        return;
      }

      await this.fadeOutCard();
      this.resetForm();
      await this.loadNextBook();
    } catch (error) {
      console.error("[BookExpert] submitEvaluation failed:", error);
      this.showErrors([this.texts.errorNetwork]);
    } finally {
      this.setSubmitting(false);
      this.isSubmitting = false;
    }
  }

  async safeJson(response) {
    try {
      return await response.json();
    } catch (_error) {
      return {};
    }
  }

  // ---------- Rendering ----------

  renderBook(book) {
    this.fields.id.value = book.id;
    this.fields.genre.textContent = book.genre;
    this.fields.title.textContent = book.title;
    this.fields.author.textContent = book.author;
    this.fields.year.textContent = book.year || "\u2014";
    this.fields.description.textContent = book.description;
    this.fields.average.textContent =
      book.average_rating === null ? this.texts.noAverage : Number(book.average_rating).toFixed(1);
    this.fields.count.textContent = book.evaluations_count;
    this.fields.image.alt = book.title;
    this.fields.image.src = book.image_url || this.placeholderCover();

    this.hideStatus();
    this.hideDone();
    this.showCard();
  }

  renderProgress(rated, total) {
    this.progress.textContent = formatTemplate(this.texts.progress, { rated, total });
  }

  placeholderCover() {
    const svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="600">' +
      '<rect width="100%" height="100%" fill="#e9e4d8"/>' +
      '<text x="50%" y="50%" font-size="120" text-anchor="middle" dominant-baseline="middle">\u{1F4D6}</text>' +
      "</svg>";
    return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svg)}`;
  }

  showCard() {
    this.card.hidden = false;
    this.card.classList.remove("is-leaving");
    // Force a reflow so the enter animation restarts for every new book
    void this.card.offsetWidth;
    this.card.classList.add("is-entering");
    this.card.addEventListener("animationend", () => this.card.classList.remove("is-entering"), { once: true });
  }

  hideCard() {
    this.card.hidden = true;
    this.card.classList.remove("is-entering", "is-leaving");
  }

  fadeOutCard() {
    return new Promise((resolve) => {
      this.card.classList.add("is-leaving");
      const finish = () => {
        this.card.classList.remove("is-leaving");
        resolve();
      };
      this.card.addEventListener("animationend", finish, { once: true });
      // Fallback in case animations are disabled in the browser
      setTimeout(finish, 450);
    });
  }

  showDone() {
    this.donePanel.querySelector("#done-title").textContent = this.texts.doneTitle;
    this.donePanel.querySelector("#done-text").textContent = this.texts.doneText;
    this.donePanel.hidden = false;
  }

  hideDone() {
    this.donePanel.hidden = true;
  }

  showStatus(text) {
    this.statusMessage.textContent = text;
    this.statusMessage.hidden = false;
  }

  hideStatus() {
    this.statusMessage.hidden = true;
  }

  showErrors(messages) {
    this.errors.innerHTML = "";
    const header = document.createElement("p");
    header.textContent = this.texts.errorSave;
    this.errors.appendChild(header);

    const list = document.createElement("ul");
    messages.forEach((message) => {
      const item = document.createElement("li");
      item.textContent = message;
      list.appendChild(item);
    });
    this.errors.appendChild(list);
    this.errors.hidden = false;
  }

  hideErrors() {
    this.errors.hidden = true;
    this.errors.innerHTML = "";
  }

  setSubmitting(state) {
    this.submitButton.disabled = state;
    this.submitButton.textContent = state ? this.texts.submitting : this.texts.submit;
  }
}

// Initialise once per page render. Turbo Drive replaces <body> on navigation,
// so we listen to turbo:load as well as DOMContentLoaded.
function initWorkspace() {
  const root = document.getElementById("evaluation-workspace");
  if (!root || root.dataset.initialized === "true") return;

  root.dataset.initialized = "true";
  new EvaluationWorkspace(root);
}

document.addEventListener("DOMContentLoaded", initWorkspace);
document.addEventListener("turbo:load", initWorkspace);
