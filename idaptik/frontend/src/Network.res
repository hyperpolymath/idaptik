// Phoenix Channel connection for multiplayer

type socket
type channel
type push

type connectionState =
  | Disconnected
  | Connecting
  | Connected
  | Error(string)

type message = {
  event: string,
  payload: JSON.t,
}

// Phoenix.js bindings
@module("phoenix") @new
external createSocket: (~endpoint: string, ~params: 'params) => socket = "Socket"

@send external connect: socket => unit = "connect"
@send external disconnect: socket => unit = "disconnect"

@send
external channel: (socket, ~topic: string, ~params: 'params) => channel = "channel"

@send external join: channel => push = "join"
@send external leave: channel => push = "leave"

@send
external channelOn: (channel, ~event: string, ~callback: message => unit) => int = "on"

@send external channelOff: (channel, ~event: string) => unit = "off"

@send
external pushMessage: (channel, ~event: string, ~payload: 'payload) => push = "push"

@send
external onReceive: (push, ~status: string, ~callback: 'response => unit) => push = "receive"

// Network manager
type t = {
  socket: socket,
  channel: option<channel>,
  mutable state: connectionState,
  mutable playerId: option<int>,
  mutable roomId: option<string>,
}

let create = (~endpoint: string, ~onStateChange: connectionState => unit): t => {
  let socket = createSocket(~endpoint, ~params={"client": "rescript"})
  
  let network = {
    socket,
    channel: None,
    state: Disconnected,
    playerId: None,
    roomId: None,
  }
  
  // Connect socket
  socket->connect()
  network.state = Connecting
  onStateChange(Connecting)
  
  network
}

let joinRoom = (
  network: t,
  ~roomId: string,
  ~playerId: int,
  ~onMessage: message => unit,
): unit => {
  network.roomId = Some(roomId)
  network.playerId = Some(playerId)
  
  let chan = network.socket->channel(~topic=`room:${roomId}`, ~params={"player_id": playerId})
  
  // Set up event handlers
  chan->channelOn(
    ~event="state_update",
    ~callback=msg => {
      Console.log2("State update:", msg)
      onMessage(msg)
    },
  )
  
  chan->channelOn(
    ~event="player_joined",
    ~callback=msg => {
      Console.log2("Player joined:", msg)
      onMessage(msg)
    },
  )
  
  chan->channelOn(
    ~event="player_left",
    ~callback=msg => {
      Console.log2("Player left:", msg)
      onMessage(msg)
    },
  )
  
  // Join the channel
  let joinPush = chan->join()
  
  joinPush
  ->onReceive(~status="ok", ~callback=response => {
    Console.log2("Joined room successfully:", response)
    network.state = Connected
    network.channel = Some(chan)
  })
  ->onReceive(~status="error", ~callback=response => {
    Console.log2("Failed to join room:", response)
    network.state = Error("Failed to join room")
  })
  ->ignore
}

let sendInput = (network: t, ~input: WasmEngine.position): unit => {
  switch network.channel {
  | Some(chan) =>
    chan
    ->pushMessage(
      ~event="player_input",
      ~payload={
        "move_x": input.x,
        "move_y": input.y,
        "timestamp": Date.now(),
      },
    )
    ->ignore
  | None => Console.warn("Cannot send input: not connected to channel")
  }
}

let sendStateUpdate = (network: t, ~state: string): unit => {
  switch network.channel {
  | Some(chan) =>
    chan->pushMessage(~event="state_sync", ~payload={"state": state})->ignore
  | None => ()
  }
}

let leaveRoom = (network: t): unit => {
  switch network.channel {
  | Some(chan) => {
      chan->leave()->ignore
      network.channel = None
      network.roomId = None
    }
  | None => ()
  }
}

let disconnect = (network: t): unit => {
  leaveRoom(network)
  network.socket->disconnect()
  network.state = Disconnected
}
