import test from 'node:test';
import assert from 'node:assert/strict';
import { listFonts, renderText } from '../server.js';

test('full local FIGlet library includes Graffiti and Standard', () => {
  assert.ok(listFonts().length > 100);
  assert.ok(listFonts().includes('Graffiti'));
  assert.ok(listFonts().includes('Standard'));
});
test('renderer uses requested FIGlet font and safely falls back', () => {
  assert.match(renderText('Hi', 'Graffiti'), /___/);
  assert.equal(renderText('Hi', 'not-a-font'), renderText('Hi', 'Graffiti'));
});

test('wide 3D output is kept on one generated line group', () => {
  const lines = renderText('Type Something', '3D-ASCII').trimEnd().split('\n');
  assert.ok(lines.every((line) => line.trim() !== ''));
  assert.equal(lines.length, 8);
});
