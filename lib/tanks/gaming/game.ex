defmodule Tanks.Gaming.Game do
  @moduledoc """
  # Create and manage game state
  """

  alias Tanks.Gaming.Artifacts.{Missile, Tank, Steel, Brick, Player}
  alias Tanks.Gaming.SquareDimension

  @moves %{
    up: {0, -1},
    down: {0, 1},
    left: {-1, 0},
    right: {1, 0}
  }

  @type t :: %{
          canvas: %{width: non_neg_integer(), height: non_neg_integer()},
          tanks: [Tank.t()],
          missiles: [Missile.t()],
          bricks: [Brick.t()],
          steels: [Steel.t()],
          # WARN remove if unused
          dead_tanks: [Tank.t()]
        }
  @type direction :: :up | :down | :left | :right
  @typep object :: Brick.t() | Missile.t() | Steel.t() | Tank.t()

  @doc """
  Creates a new game structure
  """
  @spec new([Player.t()]) :: t()
  def new(players) do
    map = Tanks.Gaming.Artifacts.Map.get_a_map()

    tanks =
      [
        %Tank{x: 0, y: 0, orientation: :down, player: Enum.at(players, 0)},
        %Tank{x: map.width - 2, y: map.height - 2, orientation: :up, player: Enum.at(players, 1)},
        %Tank{x: 0, y: map.height - 2, orientation: :right, player: Enum.at(players, 2)},
        %Tank{x: map.width - 2, y: 0, orientation: :left, player: Enum.at(players, 3)}
      ]
      |> Enum.take(length(players))

    %{
      canvas: %{width: map.width, height: map.height},
      tanks: tanks,
      missiles: [],
      bricks: map.bricks,
      steels: map.steels,
      dead_tanks: []
    }
  end

  @doc """
  Move given player's tank one step forward in specified direction, only when the move is valid
  """
  @spec move(t(), integer(), direction()) :: t()
  def move(game, player_uid, direction) do
    tanks =
      game.tanks
      |> Enum.map(fn t ->
        if t.player.user.id == player_uid do
          changeset =
            if legal_move?(game, t, direction) do
              {dx, dy} = @moves[direction]

              %{
                orientation: direction,
                x: t.x + dx,
                y: t.y + dy
              }
            else
              %{
                orientation: direction
              }
            end

          struct!(t, changeset)
        else
          t
        end
      end)

    %{game | tanks: tanks}
  end

  @doc """
  Player fires a shot.

  Player's tank emits a missile, add the missile to game
  """
  @spec fire(t(), integer()) :: t()
  def fire(game, player_uid) do
    tank = Enum.find(game.tanks, &(&1.player.user.id == player_uid))

    opts =
      case tank.orientation do
        :up -> %{x: tank.x + tank.width / 2, y: tank.y}
        :down -> %{x: tank.x + tank.width / 2, y: tank.y + tank.height}
        :left -> %{x: tank.x, y: tank.y + tank.height / 2}
        :right -> %{x: tank.x + tank.width, y: tank.y + tank.height / 2}
      end
      |> Map.put(:direction, tank.orientation)

    missile = struct!(Missile, opts)

    %{game | missiles: [missile | game.missiles]}
  end

  @doc """
  Step to the next state of the game, absent of player operations.
  """
  @spec step(t()) :: t()
  def step(game) do
    game
    |> update_location_of_missiles
    |> handle_missile_hits_missiles
    |> handle_missile_hits_objects
  end

  @spec gameover?(t()) :: boolean()
  def gameover?(game) do
    length(game.tanks) <= 1
  end

  @spec winner(t()) :: Player.t() | nil
  def winner(game) do
    if gameover?(game) do
      hd(game.tanks).player
    else
      nil
    end
  end

  defp legal_move?(game, tank, direction) do
    {dx, dy} = @moves[direction]
    tankp = %{tank | x: tank.x + dx, y: tank.y + dy}

    with true <- within_bounds?(tankp, game),
         true <- not Enum.any?(game.bricks, &collide?(&1, tankp)),
         true <- not Enum.any?(game.steels, &collide?(&1, tankp)),
         true <- not Enum.any?(List.delete(game.tanks, tank), &collide?(&1, tankp)) do
      true
    end
  end

  # Updates location of missiles in the game
  # - removes missiles that are out of bounds
  # - move missile one step forward in its direction
  @spec update_location_of_missiles(t()) :: t()
  defp update_location_of_missiles(game) do
    missiles =
      for missile <- game.missiles, within_bounds?(missile, game) do
        {dx, dy} = @moves[missile.direction]

        changeset = %{
          x: missile.x + dx * missile.speed,
          y: missile.y + dy * missile.speed
        }

        struct!(missile, changeset)
      end

    %{game | missiles: missiles}
  end

  # Determine whether a game artifact is in bounds of scene
  @spec within_bounds?(object(), t()) :: boolean()
  defp within_bounds?(object, game) do
    object.x >= 0 and object.x + object.width <= game.canvas.width and
      object.y >= 0 and object.y + object.height <= game.canvas.height
  end

  # Removes missiles that collide with each another
  @spec handle_missile_hits_missiles(t()) :: t()
  defp handle_missile_hits_missiles(game) do
    missiles =
      for missile <- game.missiles,
          Enum.count(game.missiles, &missile_hit?(missile, &1)) == 1 do
        missile
      end

    %{game | missiles: missiles}
  end

  # - missile with bricks
  #   - remove missile
  #   - remove bricks
  # - missile with steels
  #   - remove missile
  # - missile with tanks
  #   - remove missile
  #   - decrease tank hp
  #     - remove tank if hp is 0
  #     - add to game.dead_tanks
  @spec handle_missile_hits_objects(t()) :: t()
  defp handle_missile_hits_objects(game) do
    Enum.reduce(game.missiles, game, fn missile, game ->
      with brick = Enum.find(game.bricks, &missile_hit?(missile, &1)),
           :no_hit <- unless(brick, do: :no_hit, else: {:hit_a_brick, brick}),
           steel = Enum.find(game.steels, &missile_hit?(missile, &1)),
           :no_hit <- unless(steel, do: :no_hit, else: {:hit_a_steel, steel}),
           tank = Enum.find(game.tanks, &missile_hit?(missile, &1)),
           :no_hit <- unless(tank, do: :no_hit, else: {:hit_a_tank, tank}) do
        game
      else
        {:hit_a_brick, brick} ->
          changeset = %{
            missiles: List.delete(game.missiles, missile),
            bricks: List.delete(game.bricks, brick)
          }

          struct!(game, changeset)

        {:hit_a_steel, _} ->
          changeset = %{
            missiles: List.delete(game.missiles, missile)
          }

          struct!(game, changeset)

        {:hit_a_tank, tank} ->
          # - remove missile,
          # - update tank hp
          #   - if tank hp drops to 0
          #     - remove tank from list
          #     - add tank to game.dead_tanks
          changeset = %{
            missiles: List.delete(game.missiles, missile)
          }

          tankp = %{tank | hp: tank.hp - 1}

          changeset =
            if tankp.hp > 0 do
              changeset
              |> Map.put(
                :tanks,
                Enum.map(game.tanks, &if(tankp.player == &1.player, do: tankp, else: &1))
              )
            else
              changeset
              |> Map.put(:tanks, List.delete(game.tanks, tank))
              |> Map.put(:dead_tanks, [tankp | game.dead_tanks])
            end

          struct!(game, changeset)
      end
    end)
  end

  # Determine if missile hits given object
  @spec missile_hit?(Missile.t(), Missile.t() | Tank.t() | Brick.t() | Steel.t()) :: boolean()
  defp missile_hit?(missile, object)

  defp missile_hit?(m1, %Missile{} = m2) do
    m1.x == m2.x and m1.y == m2.y and m1.direction != m2.direction
  end

  defp missile_hit?(missile, obj)
       when is_struct(obj, Tank)
       when is_struct(obj, Brick)
       when is_struct(obj, Steel) do
    collide?(missile, obj)
  end

  # Tells if an object collides into another
  @spec collide?(SquareDimension.t(), SquareDimension.t()) :: boolean()
  defp collide?(o1, o2) do
    {x1, y1, r1} = SquareDimension.dimension(o1)
    {x2, y2, r2} = SquareDimension.dimension(o2)
    (:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2)) < :math.pow(r1 + r2, 2)
  end
end
