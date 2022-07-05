export interface Room {
  name: string;
  players: Player[];
  game?: string; // TODO might be wrong 
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
