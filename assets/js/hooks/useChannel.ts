import { Channel } from "phoenix";
import { useEffect, useState } from "react";
import socket from "../user_socket";

export function useChannel(topic: string, successCallback: (data: any) => void) {
  const [channel, setChannel] = useState<Channel>();

  useEffect(() => {
    const channel = socket.channel(topic);
    channel
      .join()
      .receive('ok', (data) => successCallback(data))
      .receive('error', (resp) => console.error('Unable to join', resp));
    setChannel(channel);
  }, []);

  return { channel };
}
