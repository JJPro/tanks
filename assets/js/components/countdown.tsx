import React, { KeyboardEvent, useEffect, useState } from 'react';

interface ICountdown {
  onCountdownEnd: CallableFunction;
}

function Countdown(props: ICountdown) {
  const [countdown, setCountdown] = useState(5);

  useEffect(() => {
    if (countdown > 0) {
      setTimeout(() => setCountdown(countdown -1), 1000)
    } else {
      props.onCountdownEnd();
    }
  }, [countdown])

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

export default Countdown;