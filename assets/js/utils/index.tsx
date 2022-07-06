import React, { ReactElement } from 'react';
import toast from 'react-hot-toast';

declare global {
  interface Window {
    userToken: string;
  }
}

export function requireAuth() {
  if (!window.userToken) {
    window.location.href = '/auth/login';
    return;
  }
}

export function badToast(element: ReactElement) {
  toast.custom(() => {
    return (
      <div className="animate-tada bg-white rounded-lg ring-2 ring-red-600 ring-opacity-40 shadow-lg max-w-md w-full flex">
        <div className="p-4 border-r border-gray-200">
          <img
            className="animate-wiggle h-10 w-10"
            src="/images/tank-red.png"
            alt="tank icon"
          />
        </div>

        <div className="text-sm font-medium text-gray-900 p-4">{element}</div>
      </div>
    );
  });
}
