# frozen_string_literal: true

require "aserto/rails"

Aserto.configure do |config|
  config.policy_name = ENV.fetch("ASERTO_POLICY_INSTANCE_NAME", nil)
  config.instance_label = ENV.fetch("ASERTO_POLICY_INSTANCE_LABEL", nil)
  config.tenant_id = ENV.fetch("ASERTO_TENANT_ID", nil)
  config.authorizer_api_key = ENV.fetch("ASERTO_AUTHORIZER_API_KEY", nil)
  config.policy_root = ENV.fetch("ASERTO_POLICY_ROOT", nil)
  config.service_url = ENV.fetch("ASERTO_AUTHORIZER_SERVICE_URL")
  config.cert_path = ENV.fetch("ASERTO_AUTHORIZER_GRPC_CA_CERT_PATH", ENV.fetch("ASERTO_GRPC_CA_CERT_PATH", nil))
  config.decision = "allowed"
  config.logger = Rails.logger
  config.identity_mapping = {
    type: :sub,
    from: :sub
  }
end
