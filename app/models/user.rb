# frozen_string_literal: true

class User
  include ActiveModel::Serializers::JSON

  attr_accessor :id, :display_name, :email, :picture

  def initialize(hash)
    hash.each { |key, value| public_send("#{key}=", value) }
  end

  def as_json(_options = {})
    {
      id: id,
      display_name: display_name,
      email: email,
      picture: picture
    }
  end

  class << self
    def find_by_identity(sub)
      relation = client.get_relation(
        subject_type: "user",
        subject_id: nil,
        relation: "identifier",
        object_type: "identity",
        object_id: sub
      )

      raise StandardError, "No relations found for identity: #{sub}" if relation&.result.nil?

      user = client.get_object(
        object_type: relation.result.subject_type,
        object_id: relation.result.subject_id
      ).result
      fields = user.properties.to_h

      User.new(
        id: user.id,
        display_name: user.display_name,
        email: fields["email"],
        picture: fields["picture"]
      )
    rescue GRPC::BadStatus, StandardError => e
      Rails.logger.error(e)
      raise StandardError, e.message
    end

    def find_by_key(key)
      user = client.get_object(object_type: "user", object_id: key).result
      fields = user.properties.to_h

      User.new(
        id: user.id,
        display_name: user.display_name,
        email: fields["email"],
        picture: fields["picture"]
      )
    rescue GRPC::BadStatus, StandardError => e
      Rails.logger.error(e)
      raise StandardError, e.message
    end

    def insert_todo(todo)
      client.set_object(object_type: "resource", object_id: todo.ID, display_name: todo.Title, properties: {})
      client.set_relation(subject_id: todo.OwnerID, subject_type: "user", object_id: todo.ID, object_type: "resource",
                          relation: "owner")
    rescue GRPC::BadStatus, StandardError => e
      Rails.logger.error(e)
      raise StandardError, e.message
    end

    def delete_todo(todo_id)
      client.delete_object(object_type: "resource", object_id: todo_id, with_relations: true)
    rescue GRPC::BadStatus, StandardError => e
      Rails.logger.error(e)
      raise StandardError, e.message
    end

    private

    def client
      @client ||= Aserto::Directory::V3::Client.new(
        url: ENV.fetch("ASERTO_DIRECTORY_SERVICE_URL"),
        api_key: "basic #{ENV.fetch('ASERTO_DIRECTORY_API_KEY', nil)}",
        tenant_id: ENV.fetch("ASERTO_TENANT_ID", ""),
        cert_path: ENV.fetch("ASERTO_DIRECTORY_GRPC_CERT_PATH", nil)
      )
    end
  end
end
