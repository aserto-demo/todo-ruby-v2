# frozen_string_literal: true

class User
  include ActiveModel::Serializers::JSON

  attr_accessor :key, :display_name, :email, :picture

  def initialize(hash)
    hash.each { |key, value| public_send("#{key}=", value) }
  end

  def as_json(_options = {})
    {
      key: key,
      display_name: display_name,
      email: email,
      picture: picture
    }
  end

  class << self
    def find_by_identity(sub)
      relation = client.relation(
        subject: {
          type: "user"
        },
        relation: {
          name: "identifier",
          object_type: "identity"
        },
        object: {
          type: "identity",
          key: sub
        }
      )

      raise StandardError, "No relations found for identity: #{sub}" if !relation || relation.length == 0

      subject = relation[0].subject
      user = client.object(key: subject.key, type: subject.type)
      fields = user.properties.fields

      User.new(
        key: user.key,
        display_name: user.display_name,
        email: fields["email"]["string_value"],
        picture: fields["picture"]["string_value"]
      )
    rescue GRPC::BadStatus, StandardError => e
      Rails.logger.error(e)
      raise StandardError, e.message
    end

    def find_by_key(key)
      user = client.object(type: "user", key: key)
      fields = user.properties.fields

      User.new(
        key: user.key,
        display_name: user.display_name,
        email: fields["email"]["string_value"],
        picture: fields["picture"]["string_value"]
      )
    rescue GRPC::BadStatus, StandardError => e
      Rails.logger.error(e)
      raise StandardError, e.message
    end

    private

    def client
      @client ||= Aserto::Directory::Client.new(
        url: ENV.fetch("ASERTO_DIRECTORY_SERVICE_URL"),
        api_key: "basic #{ENV.fetch('ASERTO_DIRECTORY_API_KEY', nil)}",
        tenant_id: ENV.fetch("ASERTO_TENANT_ID", ""),
        cert_path: ENV.fetch("ASERTO_DIRECTORY_GRPC_CERT_PATH", nil)
      )
    end
  end
end
