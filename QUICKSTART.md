# Quick Start Guide

## One-Command Setup

```bash
bash setup.sh
```

That's it! The script will handle everything automatically.

## What Happens During Setup

The setup script will perform the following steps:

### 1. Package Management (1-2 minutes)
- Update all Termux packages
- Install Node.js (if not already installed)
- Install Git (if not already installed)
- Install tmux for session management

### 2. Storage Setup
- Configure Termux storage access
- Request permission prompt (grant access when asked)

### 3. Project Creation (< 30 seconds)
- Create `~/termux-server/` directory
- Generate complete Node.js server structure
- Write all server code automatically
- Initialize npm project

### 4. Dependency Installation (1-2 minutes)
- Install Express.js framework
- Set up all required npm packages

### 5. Launch Server (instant)
- Start tmux session "server" with the API running
- Start tmux session "monitor" for maintenance
- Server will be running on port 3000

## Expected Output

You'll see colored output showing progress:
- 🔵 **[INFO]** - Current step being executed
- 🟢 **[SUCCESS]** - Step completed successfully
- 🟡 **[WARNING]** - Non-critical issues (safe to continue)
- 🔴 **[ERROR]** - Critical errors (setup will stop)

## After Setup Completes

The script will display:
- ✅ Setup completion message
- 📍 Project location: `~/termux-server/`
- 🔧 tmux session names: `server` and `monitor`
- 📖 Quick reference commands
- ❓ Prompt to attach to monitor session

## Accessing Your Server

### Option 1: Attach to Monitor Session
```bash
tmux attach -t monitor
```

### Option 2: Attach to Server Session
```bash
tmux attach -t server
```

### Option 3: Test from Current Terminal
```bash
curl http://localhost:3000/api/health
```

## Testing the API

```bash
# Health check
curl http://localhost:3000/api/health

# Get all items
curl http://localhost:3000/api/items

# Create a new item
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"My First Item","description":"Created from Termux!"}'

# Get specific item
curl http://localhost:3000/api/items/1
```

## tmux Quick Reference

- **Detach**: `Ctrl+b` then `d` (server keeps running in background)
- **Switch sessions**: `Ctrl+b` then `(` or `)`
- **List sessions**: `tmux ls`
- **Reattach**: `tmux attach -t server`

## Troubleshooting

### Setup Failed?
Just re-run the script - it's idempotent (safe to run multiple times):
```bash
bash setup.sh
```

### Server Not Responding?
Check if it's running:
```bash
tmux attach -t server
```

### Need Help?
See the comprehensive guide:
```bash
cat USAGE.md
```

## Next Steps

1. ✅ Test the API endpoints
2. ✅ Explore the generated code in `~/termux-server/src/`
3. ✅ Customize routes and controllers to fit your needs
4. ✅ Read USAGE.md for advanced features

## Important Notes

- The server runs in the background using tmux
- tmux sessions persist even when you close Termux
- You can safely close Termux - the server keeps running
- To stop the server: attach to server session and press `Ctrl+C`
- Re-run setup.sh anytime to reset/reinstall everything

---

**Ready to start?** Just run:
```bash
bash setup.sh
```
