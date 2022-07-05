declare global {
  interface Window {
    userToken: string;
  }
}

export function requireAuth() {
  if (!window.userToken) {
    window.location.href = "/auth/login";
    return;
  }
}