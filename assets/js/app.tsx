// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html';
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Lobby from './pages/lobby';
import Room from './pages/room';
import { Toaster } from 'react-hot-toast';

const appDiv = document.getElementById('app') as HTMLElement;
if (appDiv) {
  const root = ReactDOM.createRoot(appDiv);
  root.render(
    <>
      <Toaster
        toastOptions={{
          style: {
            borderRadius: '10px',
            background: '#333',
            color: '#fff',
          },
        }}
      />
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Lobby />} />
          <Route path="/room/:room_name" element={<Room />} />
        </Routes>
      </BrowserRouter>
    </>
  );
}
