import React from 'react';
import { Brick } from '../../types';
import { Rect, Line, Group } from 'react-konva';

interface IBrickProps {
  brick: Brick;
  unit: number;
}
function Brick({ brick, unit }: IBrickProps) {
  const x = brick.x * unit,
    y = brick.y * unit,
    w = brick.width * unit,
    h = brick.height * unit;
  const strokeWidth = 2;

  return (
    <Group>
      <Rect x={x} y={y} width={w} height={h} fill={'red'} />
      <Line
        points={[x + (w * 3) / 4, y, x + (w * 3) / 4, y + h / 2]}
        stroke="black"
        strokeWidth={strokeWidth}
      />
      <Line
        points={[x + (w * 1) / 3, y + h / 2, x + (w * 1) / 3, y + h]}
        stroke="black"
        strokeWidth={strokeWidth}
      />
      <Line
        points={[x, y + h / 2, x + w, y + h / 2]}
        stroke="black"
        strokeWidth={strokeWidth}
      />
      <Line
        points={[x, y, x + w, y]}
        stroke="black"
        strokeWidth={strokeWidth}
      />
    </Group>
  );
}

export default Brick;
