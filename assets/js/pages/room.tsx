import React, { useState } from 'react';
import { useParams } from 'react-router-dom';
import GameView from '../components/game-view';
import RoomView from '../components/room-view';
import { GameStatus, Room } from '../types';

function Room() {
  const [gameStatus, setGameStatus] = useState<GameStatus>('not_running');

  const params = useParams();

  return (
    <div className="container mx-auto">
      <h1 className="text-gray-900 font-medium text-lg text-center mb-2 font-press-start">
        ROOM: {params.room_name}
      </h1>
      {gameStatus === 'not_running' ? (
        <RoomView onGameStart={(status: GameStatus) => setGameStatus(status)} />
      ) : (
        <GameView
          status={gameStatus}
          onFinishingStart={() => setGameStatus('already_running')}
          onGameEnd={() => setGameStatus('not_running')}
        />
      )}
    </div>
  );
}

export default Room;
