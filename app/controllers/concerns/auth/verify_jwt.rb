# frozen_string_literal: true

module Auth
  module VerifyJwt
    extend self

    JWKS_CACHE_KEY = "auth/jwks-json"

    def call(token)
      JWT.decode(
        token,
        nil,
        true, # Verify the signature of this token
        algorithms: ["RS256"],
        jwks: fetch_jwks
      )
    end

    private

    def jwk_loader
      lambda do |options|
        jwks(force: options[:invalidate]) || {}
      end
    end

    def fetch_jwks
      response = HTTP.get(ENV.fetch("JWKS_URI", nil))
      response.parse if response.code == 200
    end

    def jwks(force: false)
      Rails.cache.fetch(JWKS_CACHE_KEY, force: force, skip_nil: true) do
        fetch_jwks
      end&.deep_symbolize_keys
    end
  end
end
