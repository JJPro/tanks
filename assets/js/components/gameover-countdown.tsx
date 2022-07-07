import React, { KeyboardEvent } from 'react';
import { useCountdown } from '../hooks';

interface IGameoverCountdown {
  onCountdownEnd: CallableFunction;
  didWin: boolean;
}

function GameoverCountdown(props: IGameoverCountdown) {
  const countdown = useCountdown(5, props.onCountdownEnd);

  let phrase = props.didWin ? (
    <p className="animate-flash">YOU WON</p>
  ) : (
    'GAME OVER'
  );

  function blockKeyboardEvents(e: KeyboardEvent) {
    e.preventDefault();
    e.stopPropagation();
  }

  return (
    <div
      className="absolute left-0 top-0 w-full h-full bg-opacity-25 bg-black flex flex-col justify-end items-center text-3xl pb-28 gap-y-10 font-press-start"
      onKeyDown={blockKeyboardEvents}
    >
      <div className="text-cyan-200">{phrase}</div>
      <div className="animate-pulse2 text-white">{countdown}</div>
    </div>
  );
}

export default GameoverCountdown;
