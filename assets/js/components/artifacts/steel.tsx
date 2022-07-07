import React from 'react';
import { Rect, Line, Group } from 'react-konva';
import { Steel } from '../../types';

interface ISteelProps {
  steel: Steel;
  unit: number;
}
export default ({ steel, unit }: ISteelProps) => {
  let x = steel.x * unit,
    y = steel.y * unit,
    w = steel.width * unit,
    h = steel.height * unit;
  let strokeWidth = 1;
  return (
    <Group>
      <Rect
        x={x}
        y={y}
        width={w}
        height={h}
        fill={'#74b2fd'}
        stroke="black"
        strokeWidth={strokeWidth}
      />
      <Line
        points={[x, y, x + w / 4, y + h / 4]}
        stroke="black"
        strokeWidth={strokeWidth}
      />
      <Line
        points={[x + w, y, x + (3 / 4) * w, y + h / 4]}
        stroke="black"
        strokeWidth={strokeWidth}
      />
      <Line
        points={[x + w, y + h, x + (w * 3) / 4, y + (h * 3) / 4]}
        stroke="black"
        strokeWidth={strokeWidth}
      />
      <Line
        points={[x, y + h, x + w / 4, y + (h * 3) / 4]}
        stroke="black"
        strokeWidth={strokeWidth}
      />
      <Rect
        x={x + w / 4}
        y={y + h / 4}
        width={(1 / 2) * w}
        height={(1 / 2) * h}
        fill={'#9ac7fd'}
        stroke="black"
        strokeWidth={strokeWidth}
      />
    </Group>
  );
};
