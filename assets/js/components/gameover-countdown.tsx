import React, { KeyboardEvent } from 'react';
import { useCountdown } from '../hooks';

interface IGameoverCountdown {
  onCountdownEnd: CallableFunction;
  didWin: boolean;
}

function GameoverCountdown(props: IGameoverCountdown) {
  const countdown = useCountdown(5, props.onCountdownEnd);

  let phrase = props.didWin ? (
    <p className="animate-flash">YOU WIN</p>
  ) : (
    'GAME OVER'
  );

  function blockKeyboardEvents(e: KeyboardEvent) {
    e.preventDefault();
    e.stopPropagation();
  }

  return (
    <div
      className="w-full h-full flex flex-col justify-end items-center text-3xl pb-8 gap-y-16 font-press-start"
      onKeyDown={blockKeyboardEvents}
    >
      <div className="text-cyan-500">{phrase}</div>
      <div className="animate-pulse2 text-white">{countdown}</div>
    </div>
  );
}

export default GameoverCountdown;
