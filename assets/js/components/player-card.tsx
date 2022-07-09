import React from 'react';
import { Player } from '../types';

interface IPlayerCard {
  player: Player;
  hostId?: number;
  userId?: number;
  onKickout: (player: Player) => void;
}

function PlayerCard(props: IPlayerCard) {
  const { player, hostId, userId, onKickout } = props;
  const btnKickout = (
    <button
      className="btn btn-outline-red px-3 py-1 font-normal"
      onClick={() => onKickout(player)}
    >
      kickout
    </button>
  );

  const amIHost = hostId === userId;
  const isMyOwnCard = player.user.id === userId;
  const extraStyles = {
    forHostCard: {
      boxShadow: '0 0 15px 5px #5fff45, 0 0 4px 1px #5fff45 inset',
      border: 'none',
    },
    forReadiedPlayer: {
      backgroundImage: "url('/images/ready.png')",
    },
  };

  return (
    <article className="flex flex-col items-center p-3 gap-y-4">
      <div
        className="rounded-lg p-2 border border-gray-300 box-shadow flex flex-col items-center grow"
        style={player.user.id === hostId ? extraStyles.forHostCard : {}}
      >
        <header className="font-medium">
          {player.user.id === userId ? 'You' : player.user.name}
        </header>
        <div
          className="w-24 h-24 bg-no-repeat bg-center bg-contain"
          style={player['ready?'] ? extraStyles.forReadiedPlayer : {}}
        ></div>
        {amIHost && !isMyOwnCard && btnKickout}
      </div>
      <div
        className="w-12 h-12 bg-no-repeat bg-center bg-contain"
        style={{ backgroundImage: `url(${player.sprite})` }}
      ></div>
    </article>
  );
}

export default PlayerCard;
