import { useEffect, useState } from "react";

export function useCountdown(seconds: number, onCountdownEnd: CallableFunction) {
  const [countdown, setCountdown] = useState(seconds);

  useEffect(() => {
    if (countdown > 0) {
      setTimeout(() => setCountdown(countdown - 1), 1000)
    } else {
      onCountdownEnd();
    }
  }, [countdown]);

  return countdown;
}
