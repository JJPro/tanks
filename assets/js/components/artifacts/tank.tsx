import React, { useEffect, useState } from 'react';
import { Image } from 'react-konva';
import { Direction, Tank } from '../../types';

interface ITankProps {
  tank: Tank;
  unit: number;
}

interface GameWorldTank {
  sprite: any;
  x: number;
  y: number;
  w: number;
  h: number;
  orientation: Direction;
}

function Tank({ tank, unit }: ITankProps) {
  const [sprite, setSprite] = useState<HTMLImageElement>();

  useEffect(() => {
    const sprite = new window.Image();
    sprite.src = tank.player.sprite;
    sprite.onload = () => setSprite(sprite);
  }, []);

  let x = tank.x * unit,
    y = tank.y * unit,
    w = tank.width * unit,
    h = tank.height * unit;
  let rotation = 0;
  switch (tank.orientation) {
    case 'up':
      rotation = 0;
      break;
    case 'right':
      rotation = 90;
      x += w;
      break;
    case 'down':
      rotation = 180;
      x += w;
      y += h;
      break;
    case 'left':
      rotation = -90;
      y += h;
      break;
  }
  return (
    <Image
      image={sprite}
      width={w}
      height={h}
      x={x}
      y={y}
      rotation={rotation}
    />
  );
}

export default Tank;
