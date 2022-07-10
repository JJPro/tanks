import React, { ReactElement, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useChannel, useRoom } from '../hooks';
import { GameStatus, Player, Room } from '../types';
import { badToast } from '../utils';
import ChatRoom from './chatroom';
import PlayerCard from './player-card';

interface IRoomView {
  onGameStart: (status: GameStatus) => void;
}

type Role = 'observer' | 'host' | 'player';

function RoomView(props: IRoomView) {
  const [room, setRoom] = useState<Room>();
  const [userId, setUserId] = useState();
  const [hostId, setHostId] = useState();
  const [role, setRole] = useState<Role>('observer');
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
        props.onGameStart('already_running');
      }
    },
    ({ reason }) => {
      if (reason == 'not found') {
        badToast(<p>Room doesn't exist!</p>);
        navigate('/');
      }
    },
    (channel) => {
      channel.on('gamestart', () => {
        props.onGameStart('booting_up');
      });

      channel.on('room_change', ({ room, host_id, role_change }) => {
        setRoom(room);
        setHostId(host_id);
        if (role_change) {
          setRole(role_change);
          if (role_change === 'host') {
            badToast(<p>You are now the new host</p>);
          }
        }
      });

      channel.on('kickedout', ({ room, 'me?': isMe }) => {
        setRoom(room);
        if (isMe) {
          navigate('/');
          badToast(<p>You were kicked out by host.</p>);
        }
      });

      // notify observer to redirect back to lobby, since all players have left the room
      channel.on('close_room', () => {
        badToast(
          <>
            <p>Room closed.</p>
          </>
        );

        setTimeout(() => navigate('/'), 200);
      });
    }
  );

  const { joinRoom, leaveRoom, toggleReady, startGame } = useRoom(channel);

  const onKickout = (player: Player) => {
    channel?.push('kickout', { player_uid: player.user.id });
  };

  const currentPlayer = room?.players.find((p) => p.user.id === userId);
  const controls: ReactElement[] = [];
  if (role === 'host' || role === 'player') {
    let readyTailwinds = '';
    if (currentPlayer?.['ready?']) {
      readyTailwinds = 'btn-outline-red';
    } else {
      readyTailwinds = 'btn-outline-green';
    }
    const readyButton = (
      <button
        key="ready"
        className={`btn px-5 py-2 ${readyTailwinds}`}
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
        className="btn btn-cyan px-5 py-2"
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
        className="btn btn-green px-5 py-2"
        onClick={() => joinRoom(room?.name)}
      >
        Join
      </button>
    );
    controls.push(joinButton);
  }

  const leaveButton = (
    <button
      key="leave"
      className="btn btn-outline-amber px-5 py-2"
      onClick={leaveRoom}
    >
      Leave
    </button>
  );
  controls.push(leaveButton);

  return (
    <div className="flex justify-evenly gap-x-6">
      <div className="">
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
      </div>
      {params.room_name && (
        <ChatRoom roomname={params.room_name} width="15rem" height="500px" />
      )}
    </div>
  );
}

export default RoomView;
