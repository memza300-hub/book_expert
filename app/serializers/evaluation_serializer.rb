class EvaluationSerializer < ActiveModel::Serializer
  attributes :id, :book_id, :rating, :comment, :created_at
end
