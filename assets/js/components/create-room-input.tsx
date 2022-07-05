import { Channel } from 'phoenix';
import React, {
  KeyboardEvent,
  ReactElement,
  useState,
} from 'react';
import { useDebounce } from '../hooks';
import { RoomLobbyView } from '../types';
import { useGame } from '../hooks/useGame';

interface ICreateRoomInputProps {
  channel?: Channel;
}

function CreateRoomInput(props: ICreateRoomInputProps) {
  const { channel } = props;
  const [term, setTerm] = useState('');
  const [room, setRoom] = useState<RoomLobbyView | null>();

  useDebounce(
    () => {
      if (!term) return;

      channel
        ?.push('search', { term })
        .receive('ok', (room) => console.log(room))
        .receive('error', (msg) => {
          if (msg === 'not_found') {
            setRoom(null);
          }
        });
    },
    700,
    [term]
  );

  const { createGame, joinGame, observeGame } = useGame(channel);

  let buttons: ReactElement[] = [];
  const btnCreate = (
    <button
      key="create"
      className="btn grow-0 text-blue-500 border-blue-500 hover:bg-blue-500 hover:text-white"
      onClick={() => createGame(term)}
    >
      Create
    </button>
  );
  const btnJoin = (
    <button
      key="join"
      className="btn grow-0 text-green-600 border-green-600 hover:bg-green-600 hover:text-white"
      onClick={() => joinGame(term)}
    >
      Join
    </button>
  );
  const btnObserve = (
    <button
      key="observe"
      className="btn grow-0 text-cyan-500 border-cyan-500 hover:bg-cyan-500 hover:text-white"
      onClick={() => observeGame(term)}
    >
      Observe
    </button>
  );
  if (term) {
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
    if (!term) return;
    if (ev.key !== 'Enter') return;
    if (!room) createGame(term);
    else if (room.status === 'open') joinGame(term);
    else observeGame(term);
  };

  return (
    <div className="flex btn-group">
      <input
        type="text"
        className="grow"
        placeholder="Search or Create A Room"
        aria-label="Search or Create A Room"
        value={term}
        onChange={(e) => setTerm(e.currentTarget.value.trim())}
        onKeyDown={onKeyDown}
      />
      {buttons}
    </div>
  );
}

export default CreateRoomInput;
