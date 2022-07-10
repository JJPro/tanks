import React, { useState } from 'react';
import { useParams } from 'react-router-dom';
import GameView from '../components/game-view';
import RoomView from '../components/room-view';
import { Room } from '../types';

function Room() {
  const [gameOn, setGameOn] = useState(false);
  const params = useParams();

  return (
    <div className="container mx-auto">
      <h1 className="text-gray-900 font-medium text-lg text-center mb-2 font-press-start">
        ROOM: {params.room_name}
      </h1>
      {gameOn ? (
        <GameView onGameEnd={() => setGameOn(false)} />
      ) : (
        <RoomView onGameStart={() => setGameOn(true)} />
      )}
    </div>
  );
}

export default Room;
