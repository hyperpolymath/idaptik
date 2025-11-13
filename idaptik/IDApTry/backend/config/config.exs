import Config

config :backend, BackendWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [formats: [json: BackendWeb.ErrorJSON]],
  pubsub_server: Backend.PubSub

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
