defmodule Tanks.Gaming.Game do
  @moduledoc """
  Functions to create and transfer a game state
  """

  alias Tanks.Gaming.Components.{Missile, Tank, Steel, Brick, Player}

  @moves %{
    up: {0, -1},
    down: {0, 1},
    left: {-1, 0},
    right: {1, 0}
  }

  @type game :: %{
          canvas: %{width: non_neg_integer(), height: non_neg_integer()},
          tanks: [Tank.t()],
          missiles: [Missile.t()],
          bricks: [Brick.t()],
          steels: [Steel.t()],
          destroyed_tanks: [Tank.t()]
        }
  @type direction :: :up | :down | :left | :right

  @doc """
  Creates a new game structure
  """
  @spec game([Player.t()]) :: game()
  def game(players) do
    map = Tanks.Gaming.Components.Map.get_a_map()

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
      destroyed_tanks: []
    }
  end

  @doc """
  Generates client view of game state, which will later be sent to client as json
  """
  @spec client_view(game()) :: game()
  def client_view(game), do: game

  @doc """
  Move given player's tank one step forward in specified direction, only when the move is valid
  """
  @spec move(game(), integer(), direction()) :: game()
  def move(game, player_id, direction) do
    tanks =
      game.tanks
      |> Enum.map(fn t ->
        if t.player.user.id == player_id and legal_move?(direction, t, game) do
          {dx, dy} = @moves[direction]

          changeset = %{
            orientation: direction,
            x: t.x + dx,
            y: t.y + dy
          }

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
  @spec fire(game(), integer()) :: game()
  def fire(game, player_id) do
    tank = Enum.find(game.tanks, &(&1.player.user.id == player_id))

    missile = %Missile{
      direction: tank.orientation
    }

    changeset =
      case tank.orientation do
        :up -> %{x: tank.x + tank.width / 2, y: tank.y}
        :down -> %{x: tank.x + tank.width / 2, y: tank.y + tank.height}
        :left -> %{x: tank.x, y: tank.y + tank.height / 2}
        :right -> %{x: tank.x + tank.width, y: tank.y + tank.height / 2}
      end

    missile = missile |> struct!(changeset)

    %{game | missiles: [missile | game.missiles]}
  end

  @doc """
  Step to the next state of the game, absent of player operations.
  """
  @spec step(game()) :: game()
  def step(game) do
    game
    |> update_location_of_missiles
    |> handle_missile_hits_missiles
    |> handle_missile_hits_objects
  end

  defp legal_move?(direction, tank, game) do
    {dx, dy} = @moves[direction]
    {xp, yp} = {tank.x + dx, tank.y + dy}

    # check bounds
    with true <- xp >= 0 and xp < game.canvas.width,
         true <- yp >= 0 and yp < game.canvas.height,
         # check collision with bricks
         false <-
           Enum.any?(
             game.bricks,
             &(&1.x - xp < tank.width and &1.x - xp >= 0 and
                 &1.y - yp < tank.height and &1.y - yp >= 0)
           ),
         # check collision with steels
         false <-
           Enum.any?(
             game.steels,
             &(&1.x - xp < tank.width and &1.x - xp >= 0 and
                 &1.y - yp < tank.height and &1.y - yp >= 0)
           ),
         # check collision with other tanks
         false <-
           game.tanks
           |> List.delete(tank)
           |> Enum.any?(
             &(&1.x - xp >= -tank.width / 2 and &1.x - xp <= tank.width / 2 and
                 &1.y - yp >= -tank.height / 2 and &1.y - yp <= tank.height / 2)
           ) do
      true
    else
      _ -> false
    end
  end

  # Two situations:
  # - removes missiles that are out of bounds
  # - move missile one step forward in its direction
  @spec update_location_of_missiles(game()) :: game()
  defp update_location_of_missiles(game) do
    missiles =
      for missile <- game.missiles, not missile_out_of_view?(missile, game) do
        {dx, dy} = @moves[missile.direction]

        changeset = %{
          x: missile.x + dx * missile.speed,
          y: missile.y + dy * missile.speed
        }

        struct!(missile, changeset)
      end

    %{game | missiles: missiles}
  end

  @spec missile_out_of_view?(Missile.t(), game()) :: boolean()
  defp missile_out_of_view?(missile, game) do
    missile.x > game.canvas.width or missile.x + missile.width < 0 or
      missile.y > game.canvas.height or missile.y + missile.height < 0
  end

  # Removes missiles that collide with each another
  @spec handle_missile_hits_missiles(game()) :: game()
  defp handle_missile_hits_missiles(game) do
    missiles =
      for missile <- game.missiles,
          Enum.count(game.missiles, &hit?(missile, &1)) == 1 do
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
  #     - add to game.destroyed_tanks_last_frame
  @spec handle_missile_hits_objects(game()) :: game()
  defp handle_missile_hits_objects(game) do
    Enum.reduce(game.missiles, game, fn missile, game ->
      with new_bricks = Enum.reject(game.bricks, &hit?(missile, &1)),
           :no_hit <-
             if(game.bricks == new_bricks, do: :no_hit, else: {:hit_a_brick, new_bricks}),
           :no_hit <-
             unless(
               Enum.any?(game.steels, &hit?(missile, &1)),
               do: :no_hit,
               else: :hit_a_steel
             ),
           new_tanks =
             Enum.map(game.tanks, fn tank ->
               if hit?(missile, tank), do: %{tank | hp: tank.hp - 1}, else: tank
             end),
           :no_hit <- if(game.tanks == new_tanks, do: :no_hit, else: {:hit_a_tank, new_tanks}) do
        game
      else
        {:hit_a_brick, new_bricks} ->
          changeset = %{
            missiles: List.delete(game.missiles, missile),
            bricks: new_bricks
          }

          struct!(game, changeset)

        :hit_a_steel ->
          changeset = %{
            missiles: List.delete(game.missiles, missile)
          }

          struct!(game, changeset)

        {:hit_a_tank, new_tanks} ->
          # - remove missile,
          # - update tanks list
          #   - if tank hp drops to 0
          #     - remove tank from list
          #     - add tank to game.destroyed_tanks_last_frame
          changeset = %{
            missiles: List.delete(game.missiles, missile)
          }

          tank_to_destroy = Enum.find(new_tanks, &(&1.hp == 0))

          unless is_nil(tank_to_destroy) do
            struct!(game, changeset)
          else
            # remove tank & add to game.destroyed_tanks_last_frame
            changeset =
              changeset
              |> Map.put(:tanks, List.delete(new_tanks, tank_to_destroy))
              |> Map.put(:destroyed_tanks_last_frame, [
                tank_to_destroy | game.destroyed_tanks_last_frame
              ])

            struct!(game, changeset)
          end
      end
    end)
  end

  # Determine if missile hits given object
  @spec hit?(Missile.t(), Missile.t() | Tank.t() | Brick.t() | Steel.t()) :: boolean()
  defp hit?(missile, object)

  defp hit?(m1, %Missile{} = m2) do
    m1.x == m2.x and m1.y == m2.y and m1.direction != m2.direction
  end

  defp hit?(missile, %Tank{} = tank) do
    # TODO
    true
  end

  defp hit?(missile, obj) when is_struct(obj, Brick) or is_struct(obj, Steel) do
    # TODO
    true
  end
end
