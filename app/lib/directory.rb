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
  end
end
