# frozen_string_literal: true

class Todo < ApplicationRecord
  validates :title, presence: true

  def as_json(_options = {})
    {
      ID: id,
      Title: title,
      Completed: completed,
      OwnerID: owner_id
    }
  end
end
