import React from 'react';
import { Channel } from "phoenix";
import toast from "react-hot-toast";
import { useNavigate } from "react-router-dom";
import { badToast, requireAuth } from "../utils";

export function useGame(channel?: Channel) {
  const navigate = useNavigate();

  const createGame = (room_name: string) => {
    requireAuth();

    channel
      ?.push('create_room', { room_name })
      .receive('ok', () => navigate(`/room/${room_name}`))
      .receive('error', () => toast.error('Game exists, pick another name'))
      .receive('timeout', () => toast.error('Network Error. Try again later.'));
  }

  const joinGame = (room_name?: string) => {
    requireAuth();

    channel
      ?.push('join', { room_name })
      .receive('ok', () => navigate(`/room/${room_name}`));
  }

  const observeGame = (room_name: string) => {
    requireAuth();

    navigate(`/room/${room_name}`);
  }

  const leaveGame = () => {
    requireAuth();

    channel?.push('leave', {});
    navigate('/');
  }

  const toggleReady = () => {
    requireAuth();

    channel?.push('toggle_ready', {});
  }

  const startGame = () => {
    requireAuth();

    channel?.push('start', {})
      .receive('error', (error) => {
        badToast(<p>{error.reason}</p>);
      });
  }

  return { createGame, joinGame, observeGame, leaveGame, toggleReady, startGame };
}
