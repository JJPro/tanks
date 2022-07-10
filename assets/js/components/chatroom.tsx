import throttle from 'lodash/throttle';
import React, { useCallback, useRef, useState } from 'react';
import { useChannel } from '../hooks';

interface IChatRoomProps {
  roomname: string;
  width: string;
  height: string;
  prompt?: string;
  inputRef?: React.RefObject<HTMLInputElement>;
}

interface IChatMessage {
  sender: string;
  message: string;
}

interface ITypingPrompt {
  isTyping: boolean;
  who: string;
}

function ChatRoom(props: IChatRoomProps) {
  const [messages, setMessages] = useState<IChatMessage[]>([]);
  const [typingPrompt, setTypingPrompt] = useState<ITypingPrompt>({
    isTyping: false,
    who: '',
  });
  const ulRef = useRef<HTMLUListElement>(null);
  const promptTimerRef = useRef<number>();
  const scrollNewMsgToView = () => {
    const lastMessage = ulRef.current?.querySelector('li:last-of-type');
    lastMessage?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };
  const channel = useChannel(
    'chat:' + props.roomname,
    ({ history }) => {
      setMessages(history);
      setTimeout(scrollNewMsgToView);
    },
    null,
    (channel) => {
      channel.on('message', (packet) => {
        setMessages((messages) => [...messages, packet]);
        setTimeout(scrollNewMsgToView);
      });

      channel.on('typing_prompt', ({ name }) => {
        setTypingPrompt({ isTyping: true, who: name });
        if (promptTimerRef.current) {
          clearTimeout(promptTimerRef.current);
        }
        promptTimerRef.current = setTimeout(
          () => setTypingPrompt({ isTyping: false, who: '' }),
          2000
        );
      });
    }
  );

  const throttledTypingIndicator = useCallback(
    throttle(() => channel?.push('typing_prompt', {}), 1000),
    [channel]
  );

  const sendMessage = (e: React.KeyboardEvent<HTMLInputElement>) => {
    const message = (e.target as HTMLInputElement).value;
    if (!message) return;
    if (e.key === 'Enter') {
      channel?.push('send', { message });
      (e.target as HTMLInputElement).value = '';
    } else if (e.key === 'Escape') {
      (e.target as HTMLInputElement).value = '';
    } else {
      throttledTypingIndicator();
    }
  };
  return (
    <div
      className="shadow flex flex-col border rounded-sm"
      style={{ width: props.width, height: props.height }}
    >
      <header className="p-2 font-semibold text-center text-lg border-b">
        Chat Room
      </header>
      {/* messages */}
      <div className="grow relative overflow-hidden">
        <ul
          className="h-full bg-[#f9f9f9] flex flex-col text-left overflow-y-scroll w-full pb-[30%]"
          ref={ulRef}
        >
          {messages.map((packet, index) => (
            <li
              key={index}
              className="animate-headShake px-5 py-1.5 border-b border-solid border-[#e9e9e9] text-[#555] w-full break-words"
            >
              <strong className="text-[#575ed8]">{packet.sender}:</strong>{' '}
              {packet.message}
            </li>
          ))}
        </ul>
        {/* whoistyping prompt */}
        <div className="absolute bottom-0 bg-[#f9f9f9]/60 w-[calc(100%-.6rem)] grow-0 text-xs text-slate-500 px-4 backdrop-blur-[2px] transition-['height']">
          {typingPrompt.isTyping && (
            <p className="animate-pulse">{typingPrompt.who} is typing...</p>
          )}
        </div>
      </div>
      {/* input */}
      <input
        type="text"
        className="grow-0 px-5 py-2 text-sm rounded-none border-0 border-t border-solid border-t-slate-100"
        placeholder={props.prompt || 'Press Enter to send'}
        onKeyDown={sendMessage}
        ref={props.inputRef}
      />
    </div>
  );
}

export default ChatRoom;
