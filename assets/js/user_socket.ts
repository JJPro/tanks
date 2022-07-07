import { Socket } from "phoenix"

declare global {
  interface Window {
    userToken: string;
  }
}

const socket = new Socket("/socket", { params: { token: window.userToken } })
socket.connect()

export default socket
