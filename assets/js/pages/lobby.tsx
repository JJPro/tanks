import React, { useState } from 'react';
import CreateRoomInput from '../components/create-room-input';
import RoomCard from '../components/room-card';
import { useChannel } from '../hooks';
import { RoomLobbyView } from '../types';

function Lobby() {
  const [rooms, setRooms] = useState<RoomLobbyView[]>([]);
  const channel = useChannel('lobby', ({rooms}) => setRooms(rooms));

  channel?.on('new_room', ({ room }) => {
    setRooms([room, ...rooms]);
  });

  channel?.on('room_change', ({ room: newRoom }) => {
    const newRooms = rooms.map((room) =>
      room.name === newRoom.name ? newRoom : room
    );
    setRooms(newRooms);
  });

  channel?.on('close_room', ({ room: closeRoom }) => {
    const newRooms = rooms.filter((room) => room.name !== closeRoom.name);
    setRooms(newRooms);
  });

  return (
    <>
      <section id="banner-image"></section>
      <section className="container mx-auto my-6">
        <CreateRoomInput channel={channel} />
      </section>
      <div className="divider container mx-auto">
        <span className="bg-white p-1 font-bold text-gray-500">OR</span>
      </div>
      <section className="container mx-auto my-6">
        <h2 className="font-semibold text-xl text-gray-600 text-center">
          Join Others
        </h2>
        <div className="flex flex-wrap items-stretch justify-center">
          {rooms.map((room) => (
            <RoomCard key={room.name} room={room} channel={channel} />
          ))}
        </div>
      </section>
    </>
  );
}

export default Lobby;
