import React, { useCallback, useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { useChannel } from '../hooks';
import { Direction, Game, Player } from '../types';
import { badToast } from '../utils';
import GameWorld from './game-world';
import GameoverCountdown from './gameover-countdown';
import HP from './artifacts/hp';
import throttle from 'lodash/throttle';

interface IGameView {
  onGameEnd: () => void;
}
type Role = 'observer' | 'player';

function GameView(props: IGameView) {
  const [game, setGame] = useState<Game>();
  const [userId, setUserId] = useState();
  const [role, setRole] = useState<Role>('observer');
  const [players, setPlayers] = useState<Player[]>();
  const [gameoverInfo, setGameoverInfo] = useState({
    isGameover: false,
    didWin: false,
  });
  const params = useParams();
  const channel = useChannel(
    'game:' + params.room_name,
    ({ game, user_id, role, players }) => {
      setGame(game);
      setUserId(user_id);
      setRole(role);
      setPlayers(players);
    },
    ({ reason }) => {
      if (reason === 'terminated') {
        props.onGameEnd();
      } else {
        badToast(<p>{reason}</p>);
      }
    },
    (channel) => {
      channel.on('game_tick', ({ game }) => {
        setGame(game);
      });
      channel.on('gameover', ({ game, 'win?': didWin }) => {
        setGame(game);
        setGameoverInfo({ isGameover: true, didWin });
      });
      channel.on('gamecrash', () => {
        badToast(<p>Oops! The Game Process Crashed</p>);
      });
    }
  );

  const throttledFire = useCallback(
    throttle(() => channel?.push('fire', {}), 700),
    [channel]
  );

  useEffect(() => {
    document.addEventListener('keydown', (e) => {
      if (role !== 'player') return;
      let direction: Direction | null = null,
        fire: boolean = false;
      switch (e.key) {
        case 'w':
        case 'ArrowUp':
          direction = 'up';
          break;
        case 's':
        case 'ArrowDown':
          direction = 'down';
          break;
        case 'a':
        case 'ArrowLeft':
          direction = 'left';
          break;
        case 'd':
        case 'ArrowRight':
          direction = 'right';
          break;
        case ' ':
        case 'Shift':
          fire = true;
          break;
        default:
          break;
      }

      if (direction) {
        e.preventDefault();
        channel?.push('move', { direction });
      }
      if (fire) {
        e.preventDefault();
        throttledFire();
      }
    });
  }, [role, channel]);

  return (
    <div
      className="container mx-auto px-2 flex justify-center gap-x-4 focus:outline-none"
      tabIndex={0}
    >
      {/* game world */}
      <div className="relative bg-black">
        {game && <GameWorld game={game} />}

        {gameoverInfo.isGameover && (
          <GameoverCountdown
            didWin={gameoverInfo.didWin}
            onCountdownEnd={props.onGameEnd}
          />
        )}
      </div>
      {/* sidebar */}
      <aside className="flex flex-col min-w-[300px] max-w-[300px]">
        {/* hp */}
        <section className="flex flex-col font-press-start text-[0.65rem]">
          {players?.map((p) => {
            const tank = game?.tanks.find(
              (t) => t.player.user.id === p.user.id
            );
            return (
              tank && (
                <HP key={p.user.id} tank={tank} mine={userId === p.user.id} />
              )
            );
          })}
        </section>
        {/* instructions */}
        <section className="font-press-start text-[0.68rem] px-2">
          <h5 className="text-center my-2">Instructions</h5>
          <table className="text-left leading-5">
            <tbody>
              <tr>
                <th>MOVE: </th>
                {/* <td>↑,↓,⬅,➡ OR WASD</td> */}
                <td>⬆️ ⬇️ ⬅️ ➡️ OR WASD</td>
              </tr>
              <tr>
                <th>FIRE: </th>
                <td>SPACE OR SHIFT</td>
              </tr>
            </tbody>
          </table>
          <p className="mt-4 leading-5">
            Fire wisely, <br />
            tank needs to cool down for{' '}
            <span className="font-semibold">700ms</span> after each firing.
          </p>
        </section>
      </aside>
    </div>
  );
}

export default GameView;