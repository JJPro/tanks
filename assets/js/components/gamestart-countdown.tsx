import React, { KeyboardEvent } from 'react';
import { useCountdown } from '../hooks';

interface IGamestartCountdown {
  onCountdownEnd: CallableFunction;
}

function GamestartCountdown(props: IGamestartCountdown) {
  const countdown = useCountdown(5, props.onCountdownEnd);

  const blockKeyboardEvents = (e: KeyboardEvent) => {
    e.preventDefault();
    e.stopPropagation();
  };

  return (
    <div
      className="absolute top-0 left-0 w-full h-full bg-opacity-25 bg-black flex items-center justify-center"
      onKeyDown={blockKeyboardEvents}
    >
      <div className="animate-bounce2 text-violet-500 text-8xl flex items-center justify-center p-2 font-press-start">
        {countdown}
      </div>
    </div>
  );
}

export default GamestartCountdown;
