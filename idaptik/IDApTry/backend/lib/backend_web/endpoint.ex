defmodule BackendWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :backend

  socket "/socket", BackendWeb.UserSocket,
    websocket: true,
    longpoll: false

  plug Plug.RequestId
  plug Plug.Logger
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason

  plug BackendWeb.Router
end
