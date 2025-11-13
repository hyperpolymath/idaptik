# IDApTIK Quick Start

## 🚀 Get Running in 3 Steps

### 1. Build the Engine
```bash
./build-wasm.sh
```

### 2. Start Frontend
```bash
cd frontend
npm install
npm run res:build
npm run dev
```

### 3. Start Backend (in another terminal)
```bash
cd backend
mix phx.server
```

## 🎮 Play!
Open http://localhost:3000

## ⌨️ Controls
- **WASD** / **Arrows** = Move
- **Shift** = Sprint
- **Ctrl** = Crouch  
- **Z** = Prone

## 📁 Key Files

### Want to change game mechanics?
→ `engine/src/stealth/detection.rs`

### Want to change visuals?
→ `frontend/src/Renderer.res`

### Want to change networking?
→ `frontend/src/Network.res`

### Want to spawn more enemies?
→ `frontend/src/Game.res` (line ~40)

## 🐛 Troubleshooting

**Can't see anything?**
```bash
./build-wasm.sh  # Rebuild engine
cd frontend && npm run res:build  # Rebuild ReScript
```

**Network not connecting?**
- Check backend is running on port 4000
- Check Network.res endpoint URL

**Build errors?**
```bash
cd frontend
npm run res:clean
npm install
npm run res:build
```

## 🔧 Full Stack with Podman

```bash
podman-compose up
```

Everything starts automatically:
- Backend → localhost:4000
- Frontend → localhost:3000
- Database → localhost:5432

## 📦 What You Have

✅ **Rust Game Engine**
- Stealth mechanics (vision, sound, cover)
- Physics simulation
- Detection system
- WASM compiled

✅ **ReScript Frontend**
- Canvas rendering
- Input handling
- Network client
- Game loop

✅ **Elixir Integration**
- Phoenix Channel ready
- Multiplayer events defined
- State sync structure

## 🎯 Next Steps

1. **Test single-player** - Move around, test stealth
2. **Add guards** - Modify `Game.res` spawn code
3. **Connect multiplayer** - Hook up your Elixir backend
4. **Add features** - Check `DEVELOPMENT.md` for ideas

## 💡 Pro Tips

- Open browser DevTools console - game object is accessible
- Detection bar appears above player when spotted
- Stay in shadows and crouch for maximum stealth
- Guards have vision cones (red transparent areas)

---

**Stack:** Rust → WASM → ReScript → Canvas + Phoenix Channels → Elixir

Ready to build! 🎮
