# Design

RoomStore holds reference %Room{}
%Room{} holds references to: 
  - name
  - players 
  - game :: pid() | nil, the GameServer process
GameServer holds the game state
Note: GameServer doesn't need to be named in this design 

## GameServer Design

GameServers are hosted by DynamicSupervisor, there's no need to restart when crashing, because restarting won't reserve previous game state. 
But do broadcast to game channels upon crashing, so the frontend can notify players/observers and redirect them back to room.

### GameServerSupervisor
We use a dynamic supervisor to store room_name => gameserver pid mapping

## RoomChannel Design 

### Player and Observer Action

channel join: 
  Both players and observers are able to join the channel 
  - fetch the room OR creates one and save to store if nonexistent
  - broadcast room_change event to lobby if the room is newly created
  - reply room to client

### Player Only Actions

join:
  update room in store 
  broadcast room_change event to current room
  broadcast room_change event to lobby iff room status change
  :noreply on success
  :reply with error if fail

leave:
  update room in store 
  if still players left in room: 
    - broadcast room_change event to current room
    - broadcast room_change event to lobby iff room status change
  if no players left in room: 
    - delele the room
    - broadcast close_room event to current room and lobby
  :noreply (change will be informed by various broadcasts above)

kickout: 
  update room in store 
  broadcast room_change event to current room
  broadcast room_change event to lobby iff room status change
  :noreply (change will be informed by room_change broadcast above)

toggle_ready: 
  update room in store
  broadcast room_change event to current room
  :noreply (change will be informed by room_change broadcast above)

start: 
  update room in store
  on success: 
    broadcast room_change event to current room
    broadcast room_change event to lobby
    :noreply (change will be informed by room_change broadcast above)
  on error: 
    :reply with error 

## GameChannel Design

on channel join: 
  The game server process is already started by Room.start(), and game updates are broadcasted to us automatically by the game server. So there's not much to do here, except handling crash of game server.

  {:ok, client_view, socket} | {:error, "terminated"}

### Room View

For obsevers, hide 


# All Broadcasting Events 

| stage               | event       | pubsub topics         | payload                                 |
| ------------------- | ----------- | --------------------- | --------------------------------------- |
|                     |
| **During Game**     |             |                       |                                         |
| gamestart           | gamestart   | room:room_name        | -                                       |
| the loop            | game_tick   | game:room_name        | %{game: game}                           |
| gameover            | gameover    | game:room_name        | %{game: game}                           |
| gameover            | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
| crash               | gamecrash   | game:room_name        | -                                       |
|                     |
| **Updating Room**   |             |                       |                                         |
| create room         | new_room    | lobby                 | %{room: Room.lobby_view}                |
| player join         | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
| player leave        | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
| player kicked out   | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
| player toggle ready | room_change | room:room_name        | %{room: room}                           |
| host starts game    | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
| all players leave   | close_room  | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
| kickout             | kickedout   | room:room_name        | %{room: room, player_uid}               |


# Techniques 

Elixir
- composition 
- custom Protocols & @derive (get origin of game artifacts)
- module attributes
- meta/macro programming 
- comprehensions 
- Agent, GenServer, Channel, Presence
- DynamicSupervisor to supervise game processes
- PubSub
- lookup_and_update/2
- Phoenix Presence to track users online
React: 
- SPA
- Custom Hooks, extracting logics for joining channels
- React Portal

# References: 

- [Typescript - WebDev Simplified](https://www.youtube.com/watch?v=jBmrduvKl5w)
- [Typescript - Traversy Media](https://www.youtube.com/watch?v=BCg4U1FzODs)
- [Typescript Course in ReactJS](https://www.youtube.com/watch?v=1jMJDbq7ZX4)
- [React Router 6 and Typescript](https://www.youtube.com/watch?v=2aumoR0-jmQ)
- [Phoenix JS Docs](https://hexdocs.pm/phoenix/js/)
- [Tanks Game Image Reference](https://www.google.com/search?q=tanks+game+gameover&tbm=isch&ved=2ahUKEwjJ-6aq7eX4AhWKrnIEHcokB5UQ2-cCegQIABAA&oq=tanks+game+gameover&gs_lcp=CgNpbWcQAzoECCMQJzoECAAQQzoFCAAQgAQ6BggAEB4QBzoICAAQHhAIEAdQ0glYuhJgqxNoAHAAeACAAT6IAYEFkgECMTKYAQCgAQGqAQtnd3Mtd2l6LWltZ8ABAQ&sclient=img&ei=cVXGYon_OIrdytMPysmcqAk#imgrc=0mrL2K0plSogsM)