/**
 * This module is purely for rendering.
 * Keyboard Events and channel messaging are handled in GameView module
 */
import React from 'react';
import { Game } from '../types';
import { Stage, Layer } from 'react-konva';
import Tank from './artifacts/tank';
import Brick from './artifacts/brick';
import Steel from './artifacts/steel';
import Missile from './artifacts/missile';

interface IGameWorldProps {
  game: Game;
}

function GameWorld({ game }: IGameWorldProps) {
  const unit = 24;
  const styles = {
    stage: {
      border: `${unit}px solid green`,
      width: (game.canvas.width + 2) * unit,
      height: (game.canvas.height + 2) * unit,
    },
  };
  return (
    <Stage
      width={game.canvas.width * unit}
      height={game.canvas.height * unit}
      style={styles.stage}
    >
      <Layer>
        {game.tanks
          .filter((t) => t.hp > 0)
          .map((t) => (
            <Tank key={t.player.user.id} tank={t} unit={unit} />
          ))}
        {game.bricks.map((b) => (
          <Brick key={`(${b.x}, ${b.y})`} brick={b} unit={unit} />
        ))}
        {game.steels.map((s) => (
          <Steel key={`(${s.x}, ${s.y})`} steel={s} unit={unit} />
        ))}
        {game.missiles.map((m, i) => (
          <Missile key={i} missile={m} unit={unit} />
        ))}
      </Layer>
    </Stage>
  );
}

export default GameWorld;
