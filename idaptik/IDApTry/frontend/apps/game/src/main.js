import * as PIXI from 'pixi.js';
import { Socket } from 'phoenix';

const app = new PIXI.Application({
  width: 1280,
  height: 720,
  backgroundColor: 0x2d2d2d,
});
document.body.appendChild(app.view);

// Get role from URL
const params = new URLSearchParams(window.location.search);
const role = params.get('role') || 'infiltrator';

// Status text
const text = new PIXI.Text(`Role: ${role}\nConnecting...`, {
  fill: 0xffffff,
  fontSize: 20,
});
text.position.set(10, 10);
app.stage.addChild(text);

// Connect to backend
const socket = new Socket('ws://localhost:4000/socket');
socket.connect();

const channel = socket.channel('game:demo', { role });
channel.join()
  .receive('ok', () => {
    text.text = `Role: ${role}\nConnected!`;
    console.log('Connected to game');
  })
  .receive('error', (err) => {
    text.text = `Role: ${role}\nFailed: ${err}`;
  });

// Simple test: Click to send message
app.view.addEventListener('click', () => {
  channel.push('player_move', { x: 100, y: 100 });
  text.text = `Role: ${role}\nSent move!`;
});

// Listen for other player
channel.on('player_moved', (msg) => {
  console.log('Other player moved:', msg);
});
