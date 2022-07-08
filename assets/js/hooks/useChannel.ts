import { Channel } from "phoenix";
import { useEffect, useState } from "react";
import socket from "../user_socket";

export type Callback = ((data: any) => void) | null;
type ChannelInitFn = (channel: Channel) => void;

/**
 * Sets up and integrate channel 
 * @param topic 
 * @param successCallback 
 * @param errorCallback 
 * @param channelInit For setting up channel message handlers 
 * @returns 
 */
export function useChannel(topic: string, successCallback?: Callback, errorCallback?: Callback, channelInit?: ChannelInitFn) {
  const [channel, setChannel] = useState<Channel>();

  useEffect(() => {
    const channel = socket.channel(topic);
    channel
      .join()
      .receive('ok', (data) => successCallback && successCallback(data))
      .receive('error', (resp) => errorCallback ? errorCallback(resp) : console.error('Unable to join', resp));

    channelInit && channelInit(channel);

    setChannel(channel);

    return () => {
      channel.leave();
    }
  }, []);

  return channel;
}
