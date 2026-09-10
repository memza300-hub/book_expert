# Serializer for the JSON API (active_model_serializers).
# Localized attributes are resolved through the model methods,
# so the API answers in the language of the current request.
class BookSerializer < ActiveModel::Serializer
  attributes :id, :genre_id, :genre, :title, :author, :year, :description,
             :image_url, :average_rating, :evaluations_count

  def genre
    object.genre.name
  end

  def title
    object.title
  end

  def author
    object.author
  end

  def description
    object.description
  end

  def evaluations_count
    object.evaluations.size
  end
end
