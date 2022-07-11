import React, { useCallback, useEffect, useRef, useState } from 'react';
import { useParams } from 'react-router-dom';
import { useChannel } from '../hooks';
import { Direction, Game, GameStatus } from '../types';
import { badToast } from '../utils';
import GameWorld from './game-world';
import GameoverCountdown from './gameover-countdown';
import HP from './artifacts/hp';
import throttle from 'lodash/throttle';
import ChatRoom from './chatroom';
import GamestartCountdown from './gamestart-countdown';

interface IGameView {
  status: GameStatus;
  onFinishingStart: () => void;
  onGameEnd: () => void;
}
type Role = 'observer' | 'player';

function GameView(props: IGameView) {
  const [game, setGame] = useState<Game>();
  const [userId, setUserId] = useState();
  const [role, setRole] = useState<Role>('observer');
  const [gameoverInfo, setGameoverInfo] = useState({
    isGameover: false,
    didWin: false,
  });
  const [activateKeyboardControls, setActivateKeyboardControls] =
    useState(false);
  const params = useParams();
  const channel = useChannel(
    'game:' + params.room_name,
    ({ game, user_id, role, players }) => {
      setGame(game);
      setUserId(user_id);
      setRole(role);
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
        setTimeout(props.onGameEnd, 1000);
      });
    }
  );

  const throttledFire = useCallback(
    throttle(() => channel?.push('fire', {}), 700),
    [channel]
  );

  const chatMode = useRef(false);
  const chatInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (!activateKeyboardControls) return;
    document.addEventListener('keydown', (e) => {
      if (role !== 'player') return;
      let direction: Direction | null = null,
        fire: boolean = false;

      const composeMessage = (key: string) => {
        if (key === 'Enter' || key === 'Escape') {
          chatInputRef.current?.blur();
          chatMode.current = false;
        }
      };

      if (chatMode.current) {
        composeMessage(e.key);
      } else {
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
          case 'Enter':
            chatMode.current = true;
            chatInputRef.current?.focus();
            break;
          default:
            break;
        }
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
  }, [role, channel, activateKeyboardControls]);

  useEffect(() => {
    if (props.status === 'already_running') {
      setActivateKeyboardControls(true);
    }
  }, [props.status]);

  return (
    <div
      className="container mx-auto px-2 flex justify-center gap-x-4 focus:outline-none"
      tabIndex={0}
    >
      {/* game world */}
      <div className="relative bg-black">
        {game && <GameWorld game={game} />}
        {props.status === 'booting_up' && (
          <GamestartCountdown
            onCountdownEnd={() => {
              setActivateKeyboardControls(true);
              props.onFinishingStart();
            }}
          />
        )}

        {gameoverInfo.isGameover && (
          <GameoverCountdown
            didWin={gameoverInfo.didWin}
            onCountdownEnd={props.onGameEnd}
          />
        )}
      </div>
      {/* sidebar */}
      <aside className="flex flex-col gap-y-4 min-w-[300px] max-w-[300px] items-stretch">
        {/* hp */}
        <section className="flex flex-col font-press-start text-[0.65rem]">
          {game?.tanks.map((tank) => {
            return (
              <HP
                key={tank.player.user.id}
                tank={tank}
                mine={userId === tank.player.user.id}
              />
            );
          })}
        </section>
        {/* instructions */}
        <section className="font-press-start text-[0.65rem] px-2">
          <h5 className="text-center mb-2">Instructions</h5>
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
          <p className="mt-2 leading-5">
            FIRE WISELY, <br />
            Tank needs <span className="font-semibold">700ms</span> of cool down
            between each firing.
          </p>
        </section>
        <section className="grow h-1">
          {params.room_name && (
            <ChatRoom
              roomname={params.room_name}
              width="100%"
              height="100%"
              prompt="Press Enter/ESC to toggle message"
              inputRef={chatInputRef}
            />
          )}
        </section>
      </aside>
    </div>
  );
}

export default GameView;
