1. ✅ Auth Page
2. ✅ Home Page Layout
3. ✅ Setup frontend react (TS)
4. ✅ Room CRUD & Listing (Server)
  1. ✅ Operations to `Room`:
    1. Create Room with given name, and make current user the host
    2. Join A Room with given name 
    3. Leave a room with given name, scratch room if no players left in the room
  2. ✅ Storage: 
      Store rooms mapping %{"name" => %Room{}} via Agent server (room_store.ex)
      able to List all rooms 
5. ✅ Public API for GameServer
6. ✅ Room Channel
  1. ✅ storing user_id in assigns during socket connection
  2. ✅ handle incoming client events 
7. ✅ Lobby Channel
8. ✅ Game Channel
9. Front End
  3. ✅ set up react, react-dom, react-router, react-router-dom
  5. ✅ Browser Endpoint for /room/<name>
    3.  Simply forwards to PageController:index, react-router will recognize the path and render the room/game view
10. ✅ Lobby Page
11. Room View
  6.  ✅ set up channel messages
  7.  ✅ layouts (observer, player)
  8.  ✅ join action
  9.  ✅ ready action
  10. ✅ leave action
  11. ✅ start game action
12. ✅ Make GameServer notify clients on crash/terminate
13. ✅ DynamicSupervisor to start GameServer Processes
14. ✅ GameWorld
  12. ✅ Set up react-konva and @types
  13. ✅ GameoverCountdown
  14. ✅ GameView
  15. ✅ channel setup 
    1. ✅ on/2 
    2. ✅ push/2
  16. ✅ render
15. Bugs: 
  1. ✅ duplicate logs for single game_tick 
  2. ✅ change of host in frontend is broken
    1. ✅ new host doesnt get highlight 
    2. ✅ rejoin will incur duplicate sprites
    3. ✅ new host won't see start game option 
    4. ✅ send toast notice to new host 
  3. ✅ Review all handle_out calls
  4. ✅ create room will delete rooms for lobby user
  5. ✅ leave room will remove all rooms to lobby user
16. ✅ Fire missile 
17. ✅ grayscale dead hps 
18. ✅ Chat Function
19. ✅ Press ESC in create-room-input to delete term
21. ✅ Users Online, Phoenix Presence
  1.  ✅ layout
  2.  ✅ data tooltip
22. ✅ Style user profile page 
23. ✅ tooltip for navbar items
24. ✅ favicon
25. ✅ change logo tank
26. ✅ Organize Docs

## Release With Docker

27. ✅ Docker Release
  1. ✅ Preparation
    1. ✅ `mix phx.gen.release --docker` to generate Dockerfile
    2. ✅ optional release config in mix.exs `project/0`
    3. ✅ create a RPC release task/script to delete a ChatStore entry while app is running
  2. ✅ Build The Image
    1. ✅ Edit build stage to install `nodejs` and `npm`, and run `npm install`
  3. ✅ docker-compose.yml
    Required ENV:
      -  PHX_HOST
      -  DATABASE_URL
      -  SECRET_KEY_BASE (generate with `mix phx.gen.secret`)
29. ✅ Docker Deployment
    1. execute `/app/bin/migrate` to initiate db migration

## Manual Release Process

1.  `mix deps.get --only prod`
2.  `MIX_ENV=prod mix compile`
3.  `MIX_ENV=prod mix assets.deploy`
4.  `mix phx.gen.release`
5.  `MIX_ENV=prod mix release`


# Feature Extractions

- ✅ Custom Hooks Library
- ✅ Tailwind Plugins
- ✅ Component Library
- ✅ Gutenberg Multi-block setup 
- STAR Analysis

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
- Component Library


CSS: 
- Custom Tailwind Plugins for creating dynamic components

Docker
