import { Channel } from "phoenix";
import { useEffect, useState } from "react";
import socket from "../user_socket";

export type Callback = ((data: any) => void) | null;
export function useChannel(topic: string, successCallback?: Callback, errorCallback?: Callback) {
  const [channel, setChannel] = useState<Channel>();

  useEffect(() => {
    const channel = socket.channel(topic);
    channel
      .join()
      .receive('ok', (data) => successCallback && successCallback(data))
      .receive('error', (resp) => errorCallback ? errorCallback(resp) : console.error('Unable to join', resp));
      
    setChannel(channel);

    return () => {
      channel.leave();
    }
  }, []);

  return channel;
}
