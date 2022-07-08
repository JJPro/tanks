import React from 'react';
import { Tank } from '../../types';

interface IHPProps {
  tank: Tank;
  mine: boolean;
}

function HP({ tank, mine }: IHPProps) {
  const extra = {
    forMyself: 'bg-white rounded-lg shadow-md my-2',
    dead: 'grayscale',
  };
  return (
    <div className={`flex gap-x-2 p-4 ${mine && extra.forMyself} ${tank.hp <= 0 && extra.dead}`}>
      <img
        src={tank.player.sprite}
        alt={`${tank.player.user.name}'s tank`}
        className="w-8 h-8"
      />
      <div className="flex flex-col justify-between grow">
        <div className="font-semibold text-indigo-700 uppercase pl-1">
          {tank.player.user.name}
        </div>
        <div className="w-full h-4 bg-gray-400 rounded-lg overflow-clip">
          <div
            className="h-full text-center text-xs text-indigo-700 bg-green-500 rounded-r-none"
            style={{ width: `${(tank.hp / 4) * 100}%` }}
          ></div>
        </div>
      </div>
    </div>
  );
}

export default HP;
