import React, { useState } from 'react';
import ChatRoom from '../components/chatroom';
import CreateRoomInput from '../components/create-room-input';
import RoomCard from '../components/room-card';
import { useChannel } from '../hooks';
import { RoomLobbyView } from '../types';

function Lobby() {
  const [rooms, setRooms] = useState<RoomLobbyView[]>([]);
  const channel = useChannel(
    'lobby',
    ({ rooms }) => setRooms(rooms),
    null,
    (channel) => {
      channel?.on('new_room', ({ room }) => {
        setRooms((rooms) => [room, ...rooms]);
      });

      channel?.on('room_change', ({ room: newRoom }) => {
        setRooms((rooms) =>
          rooms.map((room) => (room.name === newRoom.name ? newRoom : room))
        );
      });

      channel?.on('close_room', ({ room: closeRoom }) => {
        setRooms((rooms) =>
          rooms.filter((room) => room.name !== closeRoom.name)
        );
      });
    }
  );

  return (
    <>
      <section id="banner-image"></section>
      <div className="flex gap-x-6 container py-6">
        <div className="grow">
          <section className="pb-4">
            <CreateRoomInput channel={channel} />
          </section>
          <div className="divider-text mx-8">
            <span className="bg-white p-1 font-bold text-gray-500">OR</span>
          </div>
          <section className="mx-auto my-6">
            <h2 className="font-semibold text-xl text-gray-600 text-center">
              Join Others
            </h2>
            <div className="flex flex-wrap items-stretch justify-center">
              {rooms.map((room) => (
                <RoomCard key={room.name} room={room} channel={channel} />
              ))}
            </div>
          </section>
        </div>
        <ChatRoom roomname="lobby" width="15rem" height="500px" />
      </div>
    </>
  );
}

export default Lobby;
