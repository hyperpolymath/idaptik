# Example Elixir Integration for IDApTIK Rust Core

## Port Supervisor Module

```elixir
defmodule IDApTIK.RustCore.Supervisor do
  @moduledoc """
  Manages a Rust core process via Port communication.
  Each player gets their own isolated Rust process with appropriate camera view.
  """
  
  use GenServer
  require Logger

  defstruct [:port, :role, :player_id, :buffer]

  @rust_binary Path.join([:code.priv_dir(:idaptik), "bin", "idaptik-core"])

  ## Public API

  @doc "Start a Rust core process for a player"
  def start_link(opts) do
    role = Keyword.fetch!(opts, :role)  # :hacker or :infiltrator
    player_id = Keyword.fetch!(opts, :player_id)
    GenServer.start_link(__MODULE__, {role, player_id}, name: via_tuple(player_id))
  end

  @doc "Send full game state update to Rust"
  def send_state_update(player_id, entities) do
    message = %{
      msg_type: :state_update,
      data: entities
    }
    GenServer.cast(via_tuple(player_id), {:send, message})
  end

  @doc "Notify Rust of entity spawn"
  def notify_entity_spawned(player_id, entity) do
    message = %{
      msg_type: :entity_spawned,
      data: entity
    }
    GenServer.cast(via_tuple(player_id), {:send, message})
  end

  @doc "Notify Rust of entity removal"
  def notify_entity_removed(player_id, entity_id) do
    message = %{
      msg_type: :entity_removed,
      data: entity_id
    }
    GenServer.cast(via_tuple(player_id), {:send, message})
  end

  ## GenServer Callbacks

  @impl true
  def init({role, player_id}) do
    Process.flag(:trap_exit, true)

    port = Port.open({:spawn_executable, @rust_binary}, [
      :binary,
      :exit_status,
      {:args, ["--role", to_string(role), "--player-id", to_string(player_id)]},
      {:line, 8192},
      {:env, [
        {'RUST_LOG', 'info'},
        {'RUST_BACKTRACE', '1'}
      ]}
    ])

    Logger.info("Started Rust core for player #{player_id} as #{role}")

    {:ok, %__MODULE__{
      port: port,
      role: role,
      player_id: player_id,
      buffer: ""
    }}
  end

  @impl true
  def handle_cast({:send, message}, state) do
    json = Jason.encode!(message)
    Port.command(state.port, json <> "\n")
    {:noreply, state}
  end

  @impl true
  def handle_info({port, {:data, {:line, line}}}, %{port: port} = state) do
    case Jason.decode(line) do
      {:ok, %{"msg_type" => "player_input", "player_id" => pid, "data" => data}} ->
        # Forward input to game logic
        IDApTIK.GameLogic.handle_player_input(pid, data)

      {:ok, %{"msg_type" => "player_action", "player_id" => pid, "data" => data}} ->
        # Forward action to game logic
        IDApTIK.GameLogic.handle_player_action(pid, data)

      {:error, reason} ->
        Logger.warning("Failed to decode message from Rust: #{inspect(reason)}")

      _ ->
        :ok
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    Logger.error("Rust core exited with status #{status} for player #{state.player_id}")
    {:stop, {:port_exit, status}, state}
  end

  @impl true
  def handle_info({:EXIT, port, reason}, %{port: port} = state) do
    Logger.error("Rust core crashed: #{inspect(reason)} for player #{state.player_id}")
    {:stop, {:port_crashed, reason}, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("Terminating Rust core for player #{state.player_id}: #{inspect(reason)}")
    if state.port, do: Port.close(state.port)
    :ok
  end

  ## Private Helpers

  defp via_tuple(player_id) do
    {:via, Registry, {IDApTIK.RustCore.Registry, player_id}}
  end
end
```

## Game Logic Module (Example)

```elixir
defmodule IDApTIK.GameLogic do
  @moduledoc """
  Central game logic that coordinates between players and Rust cores.
  """

  use GenServer
  require Logger

  defstruct [:entities, :players]

  ## Public API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc "Player joins the game"
  def player_join(player_id, role) do
    GenServer.call(__MODULE__, {:player_join, player_id, role})
  end

  @doc "Handle player input from Rust core"
  def handle_player_input(player_id, input_data) do
    GenServer.cast(__MODULE__, {:player_input, player_id, input_data})
  end

  @doc "Handle player action from Rust core"
  def handle_player_action(player_id, action_data) do
    GenServer.cast(__MODULE__, {:player_action, player_id, action_data})
  end

  ## GenServer Callbacks

  @impl true
  def init(_) do
    # Schedule periodic state broadcast
    schedule_state_update()

    {:ok, %__MODULE__{
      entities: [],
      players: %{}
    }}
  end

  @impl true
  def handle_call({:player_join, player_id, role}, _from, state) do
    # Start Rust core for this player
    {:ok, _pid} = IDApTIK.RustCore.Supervisor.start_link(
      role: role,
      player_id: player_id
    )

    # Add player entity
    player_entity = %{
      id: player_id,
      entity_type: role,
      position: spawn_position(role),
      velocity: %{x: 0.0, y: 0.0},
      visible_to_hacker: true,
      visible_to_infiltrator: true
    }

    new_entities = [player_entity | state.entities]
    new_players = Map.put(state.players, player_id, %{role: role})

    # Broadcast to all players
    broadcast_state_update(new_entities, new_players)

    {:reply, :ok, %{state | entities: new_entities, players: new_players}}
  end

  @impl true
  def handle_cast({:player_input, player_id, %{"movement" => movement}}, state) do
    # Update player velocity based on input
    new_entities = Enum.map(state.entities, fn entity ->
      if entity.id == player_id do
        %{entity | 
          velocity: %{
            x: movement["x"] * 100.0,  # Movement speed
            y: movement["y"] * 100.0
          }
        }
      else
        entity
      end
    end)

    {:noreply, %{state | entities: new_entities}}
  end

  @impl true
  def handle_cast({:player_action, player_id, %{"action" => "interact"}}, state) do
    # Find player position
    player = Enum.find(state.entities, &(&1.id == player_id))
    
    if player do
      # Find nearby interactable entities (doors, etc.)
      nearby = Enum.filter(state.entities, fn entity ->
        entity.entity_type == :door and
        distance(player.position, entity.position) < 50.0
      end)

      # Toggle door state
      Enum.each(nearby, fn door ->
        Logger.info("Player #{player_id} interacted with door #{door.id}")
        # TODO: Toggle door state
      end)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:state_update, state) do
    # Update physics (move entities based on velocity)
    dt = 0.033  # ~30 Hz update rate
    
    new_entities = Enum.map(state.entities, fn entity ->
      %{entity |
        position: %{
          x: entity.position.x + entity.velocity.x * dt,
          y: entity.position.y + entity.velocity.y * dt
        }
      }
    end)

    # Broadcast to all Rust cores
    broadcast_state_update(new_entities, state.players)

    # Schedule next update
    schedule_state_update()

    {:noreply, %{state | entities: new_entities}}
  end

  ## Private Helpers

  defp schedule_state_update do
    Process.send_after(self(), :state_update, 33)  # ~30 Hz
  end

  defp broadcast_state_update(entities, players) do
    Enum.each(players, fn {player_id, _player_info} ->
      IDApTIK.RustCore.Supervisor.send_state_update(player_id, entities)
    end)
  end

  defp spawn_position(:hacker), do: %{x: 500.0, y: 300.0}
  defp spawn_position(:infiltrator), do: %{x: 100.0, y: 200.0}

  defp distance(pos1, pos2) do
    dx = pos1.x - pos2.x
    dy = pos1.y - pos2.y
    :math.sqrt(dx * dx + dy * dy)
  end
end
```

## Application Supervisor

```elixir
defmodule IDApTIK.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Registry for Rust core processes
      {Registry, keys: :unique, name: IDApTIK.RustCore.Registry},
      
      # Game logic
      IDApTIK.GameLogic,
      
      # Phoenix endpoint
      IDApTIKWeb.Endpoint,
    ]

    opts = [strategy: :one_for_one, name: IDApTIK.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Usage

```elixir
# Player 1 joins as Hacker
IDApTIK.GameLogic.player_join(1, :hacker)

# Player 2 joins as Infiltrator
IDApTIK.GameLogic.player_join(2, :infiltrator)

# Rust cores are now running:
# - Player 1 sees top-down view
# - Player 2 sees side-scrolling view
# - Game state syncs at 30 Hz
# - Input flows: Rust → Elixir → Physics → Rust
```
