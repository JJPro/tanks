import React from 'react';
import { Rect } from 'react-konva';
import { Missile } from '../../types';

interface IMissileProps {
  missile: Missile;
  unit: number;
}

function Missile({ missile, unit }: IMissileProps) {
  let x = missile.x * unit,
    y = missile.y * unit,
    w = missile.width * unit,
    h = missile.height * unit;
  if (missile.direction == 'left' || missile.direction == 'right') {
    [h, w] = [w, h];
  }
  return (
    <Rect x={x - w / 2} y={y - h / 2} width={w} height={h} fill={'white'} />
  );
}

export default Missile;
