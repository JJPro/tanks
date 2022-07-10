export interface Room {
  name: string;
  players: Player[];
  status: string;
}

export interface Player {
  user: User;
  "ready?": boolean;
  sprite: string;
}

export interface User {
  id: number;
  name: string;
  email: string;
}

export interface RoomLobbyView {
  name: string;
  status: RoomStatus;
}

export type RoomStatus = "open" | "full" | "in_game";
export type GameStatus = "already_running" | "booting_up" | "not_running";

export interface Game {
  canvas: {
    width: number;
    height: number;
  };
  tanks: Tank[];
  missiles: Missile[];
  bricks: Brick[];
  steels: Steel[];
}

export interface Tank {
  x: number;
  y: number;
  width: number;
  height: number;
  hp: number;
  orientation: Direction;
  player: Player
}

export interface Missile {
  x: number;
  y: number;
  width: number;
  height: number;
  direction: Direction;
  speed: number;
}

export interface Brick {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface Steel {
  x: number;
  y: number;
  width: number;
  height: number;
}

export type Direction = 'up' | 'down' | 'left' | 'right';