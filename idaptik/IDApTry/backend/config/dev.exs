import Config

config :backend, BackendWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  debug_errors: true,
  secret_key_base: System.get_env("SECRET_KEY_BASE", "dev_secret_key_base_at_least_64_bytes_long_for_security_purposes_change_in_prod")

config :phoenix, :plug_init_mode, :runtime
