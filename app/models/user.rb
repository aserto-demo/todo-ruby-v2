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
      legacy_identities = ENV.fetch("LEGACY_IDENTITIES", nil)

      relation = case legacy_identities
                 when "true"

                   get_relation(object_type: "identity", subject_type: "user", id: sub)

                 when "false"

                   get_relation(object_type: "user", subject_type: "identity", id: sub)

                 else

                   begin
                     get_relation(object_type: "identity", subject_type: "user", id: sub)
                   rescue GRPC::NotFound
                     get_relation(object_type: "user", subject_type: "identity", id: sub)
                   end
                 end

      raise StandardError, "No relations found for identity: #{sub}" if relation&.result.nil?

      user = ::Directory.client.get_object(
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
      user = ::Directory.client.get_object(object_type: "user", object_id: key).result
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

    def get_relation(object_type:, subject_type:, id:)
      ::Directory.client.get_relation(
        object_type: object_type,
        object_id: object_type == "identity" ? id : nil,
        relation: "identifier",
        subject_type: subject_type,
        subject_id: subject_type == "identity" ? id : nil
      )
    end
  end
end
