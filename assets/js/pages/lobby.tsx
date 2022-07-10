import { Presence } from 'phoenix';
import React, { useState } from 'react';
import ChatRoom from '../components/chatroom';
import CreateRoomInput from '../components/create-room-input';
import RoomCard from '../components/room-card';
import { useChannel } from '../hooks';
import { RoomLobbyView } from '../types';
import { colorHex } from '../utils';

interface IOnlineUser {
  user_id: number;
  user_name: string;
  online_at: string;
}

function Lobby() {
  const [rooms, setRooms] = useState<RoomLobbyView[]>([]);
  const [usersOnline, setUsersOnline] = useState<IOnlineUser[]>([]);
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

      const presence = new Presence(channel);
      presence.onSync(() => {
        const users: IOnlineUser[] = [];
        presence.list((user_id, { metas: [first, ..._rest] }) => {
          users.push(first as IOnlineUser);
        });
        setUsersOnline(users);
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
      {/* Online Users */}
      <section>
        <ul className="flex justify-center -space-x-2 fixed bottom-20 left-0 w-full">
          {usersOnline.map((u) => (
            <li
              key={u.user_id}
              className="inline-block h-10 w-10 rounded-full object-cover ring-2 ring-white"
              aria-label={u.user_name}
              data-balloon-pos="up"
              style={{ backgroundColor: colorHex(u.user_id) }}
            ></li>
          ))}
        </ul>
      </section>
    </>
  );
}

export default Lobby;
