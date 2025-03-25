# frozen_string_literal: true

class Directory
  class << self
    def client
      @client ||= Aserto::Directory::V3::Client.new(
        url: ENV.fetch("ASERTO_DIRECTORY_SERVICE_URL"),
        api_key: "basic #{ENV.fetch('ASERTO_DIRECTORY_API_KEY', nil)}",
        tenant_id: ENV.fetch("ASERTO_TENANT_ID", ""),
        cert_path: ENV.fetch("ASERTO_DIRECTORY_GRPC_CA_CERT_PATH", ENV.fetch("ASERTO_GRPC_CA_CERT_PATH", nil))
      )
    end

    def legacy?
      return @legacy if defined?(@legacy)

      @legacy = begin
        @client.get_relation(
          object_type: "identity",
          object_id: "todoDemoIdentity",
          subject_type: "user",
          subject_id: "todoDemoUser",
          relation: "identifier"
        )
        true
      rescue GRPC::InvalidArgument
        # There is no identity#identifier relation. We're using new style identities.
        false
      rescue GRPC::NotFound
        # The relation doesn't exist but the types are valid. The model uses legacy
        # identities.
        true
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end
    end
  end
end
