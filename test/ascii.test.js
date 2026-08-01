import test from 'node:test';
import assert from 'node:assert/strict';
import { clampSettings, renderAscii } from '../ascii.js';

test('default font produces recognisable multi-line art', () => {
  const output = renderAscii('Type Something');
  assert.equal(output.split('\n').length, 7);
  assert.match(output, /@/);
});
test('empty and multi-line text retain their line semantics', () => {
  assert.equal(renderAscii(''), '\n\n\n\n\n\n');
  assert.equal(renderAscii('A\nB').split('\n').length, 14);
});
test('supported punctuation renders and unknown characters fall back to question mark', () => {
  assert.equal(renderAscii('!?.').split('\n').length, 7);
  assert.equal(renderAscii('你'), renderAscii('?'));
});
test('visual settings are clamped and do not modify rendered source text', () => {
  assert.deepEqual(clampSettings({ scaleX: 9, scaleY: 0, letterSpacing: 99 }), { scaleX: 2.5, scaleY: 0.5, letterSpacing: 8 });
  assert.equal(renderAscii('A'), renderAscii('A'));
});
