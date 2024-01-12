# frozen_string_literal: true

class Todo < ApplicationRecord
  validates :title, presence: true

  after_create do |todo|
    ::Directory.client.set_object(
      object_type: "resource", object_id: todo.id.to_s, display_name: todo.title
    )
    ::Directory.client.set_relation(
      subject_type: "user",
      subject_id: todo.owner_id,
      object_type: "resource",
      object_id: todo.id.to_s,
      relation: "owner"
    )
  end

  after_destroy do |todo|
    ::Directory.client.delete_object(
      object_type: "resource", object_id: todo.id.to_s, with_relations: true
    )
  end

  def as_json(_options = {})
    {
      ID: id,
      Title: title,
      Completed: completed,
      OwnerID: owner_id
    }
  end
end
