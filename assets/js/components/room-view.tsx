import React, { ReactElement, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useChannel, useGame } from '../hooks';
import { Player, Room } from '../types';
import { badToast } from '../utils';
import GamestartCountdown from './gamestart-countdown';
import PlayerCard from './player-card';

interface IRoomView {
  onGameStart: () => void;
}

type Role = 'observer' | 'host' | 'player';

function RoomView(props: IRoomView) {
  const [room, setRoom] = useState<Room>();
  const [userId, setUserId] = useState();
  const [hostId, setHostId] = useState();
  const [role, setRole] = useState<Role>('observer');
  const [showCountdown, setShowCountdown] = useState(false);
  const navigate = useNavigate();
  const params = useParams();

  const channel = useChannel(
    'room:' + params.room_name,
    ({ room, host_id, user_id, role }) => {
      setRoom(room);
      setHostId(host_id);
      setUserId(user_id);
      setRole(role);

      if (room.status == 'in_game') {
        props.onGameStart();
      }
    },
    ({ reason }) => {
      if (reason == 'not found') {
        badToast(<p>Room doesn't exist!</p>);
        navigate('/');
      }
    }
  );
  const { joinGame, leaveGame, toggleReady, startGame } = useGame(channel);

  channel?.on('gamestart', () => {
    setShowCountdown(true);
  });

  channel?.on('room_change', ({ room }) => {
    setRoom(room);
  });

  channel?.on('kickedout', ({ room, 'me?': isMe }) => {
    setRoom(room);
    if (isMe) {
      navigate('/');
      badToast(<p>You were kicked out by host.</p>);
    }
  });

  // notify observer to redirect back to lobby, since all players have left the room
  channel?.on('close_room', () => {
    badToast(
      <>
        <p>Room has been closed.</p>
        <p>Redirecting you back to Lobby</p>
      </>
    );

    setTimeout(() => navigate('/'), 5000);
  });

  const onKickout = (player: Player) => {
    channel?.push('kickout', { player_uid: player.user.id });
  };

  const onCountdownEnd = () => {
    setShowCountdown(false);
    props.onGameStart();
  };

  const currentPlayer = room?.players.find((p) => p.user.id === userId);
  const controls: ReactElement[] = [];
  if (role === 'host' || role === 'player') {
    let readyTailwinds = '';
    if (currentPlayer?.['ready?']) {
      readyTailwinds = 'text-red-600 border-red-600 hover:bg-red-600';
    } else {
      readyTailwinds = 'text-green-600 border-green-600 hover:bg-green-600';
    }
    const readyButton = (
      <button
        key="ready"
        className={`btn btn-outline px-5 py-2 ${readyTailwinds}`}
        onClick={toggleReady}
      >
        {currentPlayer?.['ready?'] ? 'Cancel' : 'Ready'}
      </button>
    );
    controls.push(readyButton);
  }

  if (role === 'host') {
    const startButton = (
      <button
        key="start"
        className="btn btn-solid px-5 py-2 bg-cyan-500 hover:bg-cyan-600"
        onClick={startGame}
      >
        Start
      </button>
    );
    controls.push(startButton);
  }

  if (role === 'observer') {
    const joinButton = (
      <button
        key="join"
        className="btn btn-solid px-5 py-2 bg-green-500 hover:bg-green-600"
        onClick={() => joinGame(room?.name)}
      >
        Join
      </button>
    );
    controls.push(joinButton);
  }

  const leaveButton = (
    <button
      key="leave"
      className="btn btn-outline px-5 py-2 text-amber-400 border-amber-400 hover:bg-amber-400"
      onClick={leaveGame}
    >
      Leave
    </button>
  );
  controls.push(leaveButton);

  return (
    <>
      {showCountdown && <GamestartCountdown onCountdownEnd={onCountdownEnd} />}
      <div className="flex flex-wrap items-stretch justify-center gap-4">
        {room?.players.map((player) => (
          <PlayerCard
            key={player.user.id}
            player={player}
            hostId={hostId}
            userId={userId}
            onKickout={onKickout}
          />
        ))}
      </div>
      {/* Room Controls */}
      <div className="flex items-center justify-center flex-wrap gap-4 mt-4">
        {controls}
      </div>
    </>
  );
}

export default RoomView;
