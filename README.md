# README

Set up the following environment variables:

### ENV
```
ASERTO_AUTHORIZER_SERVICE_URL=localhost:8282
ASERTO_POLICY_ROOT="todoApp"
JWKS_URI=https://citadel.demo.aserto.com/dex/keys
ASERTO_DIRECTORY_SERVICE_URL=localhost:9292
ASERTO_AUTHORIZER_CERT_PATH=$HOME/.config/topaz/certs/grpc-ca.crt
ASERTO_DIRECTORY_GRPC_CERT_PATH=$HOME/.config/topaz/certs/grpc-ca.crt
```

Install the dependencies and run the DB migration:

```
bundle install
rails db:migrate

```
Start the server:

```
rails s
```

The server will start on `http://localhost:3001`.
