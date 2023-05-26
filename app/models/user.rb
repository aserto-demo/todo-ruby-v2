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
      relation = client.get_relation(
        Aserto::Directory::Reader::V2::GetRelationRequest.new(param:
          Aserto::Directory::Common::V2::RelationIdentifier.new(
            subject: Aserto::Directory::Common::V2::ObjectIdentifier.new(
              type: "user"
            ),
            relation: Aserto::Directory::Common::V2::RelationTypeIdentifier.new(
              name: "identifier",
              object_type: "identity"
            ),
            object: Aserto::Directory::Common::V2::ObjectIdentifier.new(
              type: "identity",
              key: sub
            )
          )),
        headers
      )
      request = Aserto::Directory::Reader::V2::GetObjectRequest.new(param: relation.results[0].subject)
      resp = client.get_object(request, headers)
      result = resp.result
      fields = result.properties.fields
      User.new(
        key: result.key,
        display_name: result.display_name,
        email: fields["email"]["string_value"],
        picture: fields["picture"]["string_value"]
      )
    rescue GRPC::BadStatus, StandardError => e
      Rails.logger.error(e)
    end

    def find_by_key(key)
      request = Aserto::Directory::Reader::V2::GetObjectRequest.new(
        param: Aserto::Directory::Common::V2::ObjectIdentifier.new(
          type: "user",
          key: key
        )
      )
      resp = client.get_object(request, headers)
      result = resp.result
      fields = result.properties.fields
      User.new(
        key: result.key,
        display_name: result.display_name,
        email: fields["email"]["string_value"],
        picture: fields["picture"]["string_value"]
      )
    rescue GRPC::BadStatus, StandardError => e
      Rails.logger.error(e)
    end

    private

    def headers
      api_key = ENV.fetch("ASERTO_DIRECTORY_API_KEY", nil)
      tenant_id = ENV.fetch("ASERTO_TENANT_ID", nil)
      {
        metadata: {}.tap do |h|
          h["authorization"] = "basic #{api_key}" if api_key && api_key != ""
          h["aserto-tenant-id"] = tenant_id if tenant_id && tenant_id != ""
        end
      }
    end

    def client
      @client ||= Aserto::Directory::Reader::V2::Reader::Stub.new(
        ENV.fetch("ASERTO_DIRECTORY_SERVICE_URL"),
        load_certs
      )
    end

    def load_certs
      cert_path = ENV.fetch("ASERTO_DIRECTORY_GRPC_CERT_PATH", nil)
      return GRPC::Core::ChannelCredentials.new unless cert_path

      GRPC::Core::ChannelCredentials.new(File.read(cert_path))
    end
  end
end
