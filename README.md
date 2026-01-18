# Termux Server Setup

This repository provides both automated and manual setup instructions for setting up a Node.js server on Termux.

## Prerequisites
- Ensure that you have Termux installed on your Android device.
- A stable internet connection.

## Quick Start (Automated Setup) ⚡

The easiest way to set up the server is using the automated setup script:

1. **Clone This Repository**
   ```bash
   pkg install git
   git clone https://github.com/vppnoel/Termux_server_install.git
   cd Termux_server_install
   ```

2. **Run the Automated Setup Script**
   ```bash
   bash setup.sh
   ```

The script will automatically:
- Update Termux packages
- Install Node.js, Git, and tmux
- Set up Termux storage access
- Create the complete project structure
- Generate all server files with proper code
- Install npm dependencies
- Launch two tmux sessions:
  - **server**: Running the Node.js API server
  - **monitor**: Console for monitoring and maintenance

### Using tmux Sessions

After setup, the server will be running in the background. You can access:

- **Attach to server session**: `tmux attach -t server`
- **Attach to monitor session**: `tmux attach -t monitor`
- **List all sessions**: `tmux ls`
- **Detach from session**: Press `Ctrl+b` then `d`
- **Switch between sessions**: Press `Ctrl+b` then `(` or `)`

### Testing the Server

```bash
# Health check
curl http://localhost:3000/api/health

# Get all items
curl http://localhost:3000/api/items

# Create a new item
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"My Item","description":"Test item"}'
```

## Manual Setup Instructions

If you prefer manual setup or want to understand each step, follow these instructions:

1. **Update Termux Packages**  
   Before starting, make sure all installed packages are up-to-date:
   ```bash
   pkg update && pkg upgrade
   ```

2. **Install Required Packages**  
   Next, install the necessary packages for the server:
   ```bash
   pkg install nodejs git tmux
   ```

3. **Clone Your Server Repository**  
   Navigate to your desired directory and clone your server repository:
   ```bash
   git clone https://github.com/vppnoel/Termux_server_install.git
   ```

4. **Navigate to the Repository Directory**  
   ```bash
   cd Termux_server_install
   ```

5. **Run the Automated Setup**  
   ```bash
   bash setup.sh
   ```

## Project Structure

After running the automated setup, the following structure will be created at `~/termux-server/`:

```
termux-server/
├── src/
│   ├── app.js                          # Express application setup
│   ├── server.js                       # Server entry point
│   ├── routes/
│   │   ├── health.routes.js           # Health check endpoints
│   │   └── items.routes.js            # Items CRUD endpoints
│   └── controllers/
│       └── items.controller.js        # Items business logic
├── logs/                               # Server logs directory
├── package.json                        # npm configuration
└── README.md                           # Project documentation
```

## API Endpoints

The server provides the following REST API endpoints:

- `GET /` - API information and available endpoints
- `GET /api/health` - Health check with system stats
- `GET /api/items` - Get all items
- `POST /api/items` - Create a new item
- `GET /api/items/:id` - Get a specific item by ID

## Additional Notes
- The server runs on port 3000 by default
- All setup is idempotent - you can safely re-run the setup script
- For long-term running, the script uses tmux for session management
- Make sure to configure your firewall rules if you're using ports other than the default

## Troubleshooting

**Server not starting?**
- Check if port 3000 is already in use: `lsof -i :3000` or `netstat -tulpn | grep 3000`
- View server logs in the server tmux session: `tmux attach -t server`

**tmux sessions not visible?**
- List all sessions: `tmux ls`
- Kill old sessions: `tmux kill-session -t server`

**Need to restart the server?**
1. Attach to server session: `tmux attach -t server`
2. Press `Ctrl+C` to stop the server
3. Run `npm start` to restart

## Conclusion
You have successfully set up a Node.js server on Termux! The automated script handles all the complexity, and tmux keeps your server running in the background.