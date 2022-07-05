import React from 'react';
import { Channel } from 'phoenix';
import { RoomLobbyView, RoomStatus } from '../types';
import { useGame } from '../hooks';

interface IRoomCard {
  room: RoomLobbyView;
  channel?: Channel;
}

function RoomCard(props: IRoomCard) {
  const {
    room: { name, status },
    channel,
  } = props;
  let statusBorderColor: string = '';
  let statusBgColor: string = '';
  let bg: string = '';
  switch (status) {
    case 'open':
      bg = '#9bc6f6';
      statusBorderColor = '#5ba5fa';
      statusBgColor = '#cae0f8';
      break;

    case 'full':
      bg = '#ffe383';
      statusBorderColor = '#fbe38d';
      statusBgColor = '#f8f1d3';
      break;

    case 'in_game':
      bg = '#adecb7';
      statusBorderColor = '#80e08e';
      statusBgColor = '#bbebc1';
      break;

    default:
      break;
  }

  const { joinGame, observeGame } = useGame(channel);

  const JoinButton = () => {
    return (
      <button
        className="btn btn-solid bg-green-600 hover:bg-green-700 px-0 w-32"
        onClick={() => joinGame(name)}
      >
        Join
      </button>
    );
  };

  const ObserveButton = () => {
    return (
      <button className="btn btn-solid bg-cyan-500 hover:bg-cyan-700 px-0 w-32" onClick={() => observeGame(name)}>
        Observe
      </button>
    );
  };

  return (
    <article
      className={'relative rounded-lg m-5 p-4 flex flex-col gap-y-2 items-center'}
      style={{ backgroundColor: bg }}
    >
      <div
        className={`absolute -translate-y-[85%] rounded-lg border border-solid font-medium text-gray-600 text-xl text-center py-1 w-32`}
        style={{
          borderColor: statusBorderColor,
          backgroundColor: statusBgColor,
        }}
      >
        {status}
      </div>
      <header className="font-semibold text-2xl mt-2">{name}</header>
      {status == 'open' && <JoinButton />}
      <ObserveButton />
    </article>
  );
}

export default RoomCard;
