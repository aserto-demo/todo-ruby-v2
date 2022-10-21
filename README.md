# README

Set up the following environment variables:

### ENV
```
ASERTO_AUTHORIZER_API_KEY
ASERTO_TENANT_ID
ASERTO_AUTHORIZER_SERVICE_URL
ASERTO_POLICY_ID
ASERTO_POLICY_ROOT
JWKS_URI
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
