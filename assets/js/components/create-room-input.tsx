import { Channel } from 'phoenix';
import React, { KeyboardEvent, ReactElement, useState } from 'react';
import { useDebounce } from '../hooks';
import { RoomLobbyView } from '../types';
import { useRoom } from '../hooks';

interface ICreateRoomInputProps {
  channel?: Channel;
}

function CreateRoomInput(props: ICreateRoomInputProps) {
  const { channel } = props;
  const [term, setTerm] = useState('');
  const [room, setRoom] = useState<RoomLobbyView | null>();

  useDebounce(
    () => {
      const termSanitized = term.trim();
      if (!termSanitized) return;

      channel
        ?.push('search', { term: termSanitized })
        .receive('ok', (room) => setRoom(room))
        .receive('error', (error) => {
          if (error.reason === 'not found') {
            setRoom(null);
          }
        });
    },
    500,
    [term]
  );

  const { createRoom, joinRoom, observeRoom } = useRoom(channel);

  let buttons: ReactElement[] = [];
  const btnCreate = (
    <button
      key="create"
      className="btn grow-0 text-blue-500 border-blue-500 hover:bg-blue-500 hover:text-white"
      onClick={() => createRoom(term.trim())}
    >
      Create
    </button>
  );
  const btnJoin = (
    <button
      key="join"
      className="btn grow-0 text-green-600 border-green-600 hover:bg-green-600 hover:text-white"
      onClick={() => joinRoom(term.trim())}
    >
      Join
    </button>
  );
  const btnObserve = (
    <button
      key="observe"
      className="btn grow-0 text-cyan-500 border-cyan-500 hover:bg-cyan-500 hover:text-white"
      onClick={() => observeRoom(term.trim())}
    >
      Observe
    </button>
  );
  if (term.trim()) {
    if (!room) {
      buttons.push(btnCreate);
    } else {
      if (room.status === 'open') {
        buttons.push(btnJoin);
      }
      buttons.push(btnObserve);
    }
  }

  const onKeyDown = (ev: KeyboardEvent) => {
    const termSanitized = term.trim();
    if (!termSanitized) return;
    if (ev.key !== 'Enter') return;
    if (!room) createRoom(termSanitized);
    else if (room.status === 'open') joinRoom(termSanitized);
    else observeRoom(termSanitized);
  };

  return (
    <div className="flex btn-group">
      <input
        type="text"
        className="grow"
        placeholder="Search or Create A Room"
        aria-label="Search or Create A Room"
        value={term}
        onChange={(e) => setTerm(e.currentTarget.value)}
        onKeyDown={onKeyDown}
      />
      {buttons}
    </div>
  );
}

export default CreateRoomInput;
