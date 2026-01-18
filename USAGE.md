# Termux Server - Usage Guide

## Quick Start

### Installation
```bash
# Clone the repository
pkg install git
git clone https://github.com/vppnoel/Termux_server_install.git
cd Termux_server_install

# Run the automated setup
bash setup.sh
```

The setup script will:
1. Update all Termux packages
2. Install Node.js, Git, and tmux
3. Configure Termux storage access
4. Create a complete Node.js server project at `~/termux-server/`
5. Install npm dependencies
6. Launch two tmux sessions

### Project Structure

After setup, your server will be located at `~/termux-server/`:

```
~/termux-server/
├── src/
│   ├── app.js                          # Express application configuration
│   ├── server.js                       # Server entry point
│   ├── routes/
│   │   ├── health.routes.js           # Health check endpoints
│   │   └── items.routes.js            # Items CRUD endpoints  
│   └── controllers/
│       └── items.controller.js        # Items business logic
├── logs/                               # Log files directory
├── node_modules/                       # Dependencies (auto-installed)
├── package.json                        # npm configuration
├── .gitignore                         # Git ignore rules
└── README.md                          # Project documentation
```

## tmux Sessions

The setup creates two parallel tmux sessions:

### Session 1: `server`
- **Purpose**: Runs the Node.js API server
- **Attach**: `tmux attach -t server`
- **Function**: Handles all HTTP requests and serves the API

### Session 2: `monitor`
- **Purpose**: Server monitoring and maintenance
- **Attach**: `tmux attach -t monitor`
- **Function**: Provides a console for running commands, checking logs, and testing the API

## tmux Commands

### Basic Navigation
- **Detach from session**: `Ctrl+b` then `d`
- **Switch to next session**: `Ctrl+b` then `)`
- **Switch to previous session**: `Ctrl+b` then `(`
- **List all sessions**: `tmux ls`

### Session Management
```bash
# Attach to a specific session
tmux attach -t server
tmux attach -t monitor

# Kill a session
tmux kill-session -t server
tmux kill-session -t monitor

# Kill all sessions
tmux kill-server
```

### Window Management (within a session)
- **Create new window**: `Ctrl+b` then `c`
- **Next window**: `Ctrl+b` then `n`
- **Previous window**: `Ctrl+b` then `p`
- **List windows**: `Ctrl+b` then `w`

## API Endpoints

The server runs on port 3000 and provides the following REST API endpoints:

### Root
```bash
GET /
# Returns API information and available endpoints
curl http://localhost:3000/
```

### Health Check
```bash
GET /api/health
# Returns server health status, uptime, and memory usage
curl http://localhost:3000/api/health
```

### Items Endpoints
```bash
# Get all items
GET /api/items
curl http://localhost:3000/api/items

# Create a new item
POST /api/items
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"My Item","description":"Item description"}'

# Get a specific item by ID
GET /api/items/:id
curl http://localhost:3000/api/items/1
```

## Common Tasks

### Restart the Server
1. Attach to server session: `tmux attach -t server`
2. Stop the server: `Ctrl+C`
3. Start the server: `npm start`
4. Detach: `Ctrl+b` then `d`

### View Server Logs
```bash
# From the monitor session or any terminal
cd ~/termux-server
# View real-time logs (if logging to file is set up)
tail -f logs/server.log
```

### Check Server Status
```bash
# Quick health check
curl http://localhost:3000/api/health

# Check if server is running
ps aux | grep "node src/server.js"

# Check port usage
netstat -tulpn | grep 3000
# Or
lsof -i :3000
```

### Update Dependencies
```bash
cd ~/termux-server
npm update
```

### Re-run Setup
The setup script is idempotent - you can safely re-run it:
```bash
cd ~/Termux_server_install
bash setup.sh
```

## Troubleshooting

### Port Already in Use
```bash
# Find what's using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or change the port by setting PORT environment variable
PORT=3001 npm start
```

### Server Not Starting
1. Check for syntax errors:
   ```bash
   cd ~/termux-server
   node --check src/server.js
   ```

2. Check dependencies:
   ```bash
   npm install
   ```

3. View error messages in the server tmux session:
   ```bash
   tmux attach -t server
   ```

### tmux Session Not Found
If sessions are lost or killed:
```bash
cd ~/termux-server
# Start server manually
npm start

# Or re-run the setup script
cd ~/Termux_server_install
bash setup.sh
```

### Storage Access Issues
If storage access is denied:
```bash
termux-setup-storage
# Grant permission when prompted
```

## Tips

1. **Keep Server Running**: tmux sessions persist even when you close Termux, so your server keeps running

2. **Multiple Servers**: You can run multiple servers on different ports by changing the PORT environment variable

3. **Custom Commands**: Add your own npm scripts to package.json for common tasks

4. **Error Handling**: The server includes graceful shutdown handlers for SIGTERM and SIGINT

5. **Development**: Use the monitor session to test API endpoints while the server runs in the background

## Security Notes

- The server runs on localhost (127.0.0.1) by default
- To access from other devices, you'll need to bind to 0.0.0.0 and configure firewall rules
- Never commit sensitive data or API keys to version control
- Use environment variables for configuration

## Further Customization

Edit the source files in `~/termux-server/src/` to:
- Add new routes and endpoints
- Implement database connections
- Add authentication and authorization
- Customize error handling
- Add more middleware

Remember to restart the server after making changes!
