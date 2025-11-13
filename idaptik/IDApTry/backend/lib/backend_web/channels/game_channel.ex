defmodule BackendWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> _room_id, %{"role" => role}, socket) do
    {:ok, %{role: role}, assign(socket, :role, role)}
  end

  def handle_in("player_move", %{"x" => x, "y" => y}, socket) do
    broadcast_from!(socket, "player_moved", %{
      role: socket.assigns.role,
      x: x,
      y: y
    })
    {:reply, :ok, socket}
  end

  def handle_in("toggle_door", _params, socket) do
    if socket.assigns.role == "hacker" do
      broadcast!(socket, "door_toggled", %{})
      {:reply, :ok, socket}
    else
      {:reply, {:error, %{reason: "Only hacker can toggle"}}, socket}
    end
  end

  def handle_in("game_won", _params, socket) do
    broadcast!(socket, "game_won", %{role: socket.assigns.role})
    {:reply, :ok, socket}
  end
end
