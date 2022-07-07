import React, { KeyboardEvent } from 'react';
import { useCountdown } from '../hooks';

interface IGamestartCountdown {
  onCountdownEnd: CallableFunction;
}

function GamestartCountdown(props: IGamestartCountdown) {
  const countdown = useCountdown(5, props.onCountdownEnd);

  const blockKeyPress = (e: KeyboardEvent) => {
    e.preventDefault();
    e.stopPropagation();
  };

  return (
    <div
      className="fixed top-0 left-0 w-screen h-screen flex items-center justify-center"
      onKeyDown={blockKeyPress}
    >
      <div className="animate-rubberBand w-36 h-36 rounded-full text-violet-500 text-8xl flex items-center justify-center p-2">
        {countdown}
      </div>
    </div>
  );
}

export default GamestartCountdown;