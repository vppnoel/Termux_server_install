#!/data/data/com.termux/files/usr/bin/bash
################################################################################
# Termux Server Automated Setup Script
# 
# This script automates the complete setup of a Node.js server in Termux,
# including:
# - Package installation and updates
# - Directory structure creation
# - Server file generation
# - Dependency installation
# - Dual tmux session launch (server + monitoring)
#
# Usage: bash setup.sh
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Error handler
error_handler() {
    log_error "Script failed at line $1"
    exit 1
}

trap 'error_handler $LINENO' ERR

# Banner
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          Termux Server Automated Setup Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Update Termux packages
log_info "Updating Termux packages..."
if pkg update -y && pkg upgrade -y; then
    log_success "Packages updated successfully"
else
    log_warning "Package update encountered issues (may be safe to continue)"
fi

# Step 2: Install required packages (Node.js, Git, tmux)
log_info "Checking and installing required packages..."

# Check if nodejs is installed
if ! command -v node &> /dev/null; then
    log_info "Installing Node.js..."
    pkg install -y nodejs
    log_success "Node.js installed successfully"
else
    log_success "Node.js is already installed (version: $(node --version))"
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    log_info "Installing Git..."
    pkg install -y git
    log_success "Git installed successfully"
else
    log_success "Git is already installed (version: $(git --version | cut -d' ' -f3))"
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    log_info "Installing tmux..."
    pkg install -y tmux
    log_success "tmux installed successfully"
else
    log_success "tmux is already installed"
fi

# Step 3: Setup Termux storage (if not already set up)
log_info "Setting up Termux storage access..."
if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
    log_success "Storage access configured"
else
    log_success "Storage access already configured"
fi

# Step 4: Create project directory structure
PROJECT_DIR="$HOME/termux-server"
log_info "Creating project directory at $PROJECT_DIR..."

# Create directories if they don't exist
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/src"
mkdir -p "$PROJECT_DIR/src/routes"
mkdir -p "$PROJECT_DIR/src/controllers"
mkdir -p "$PROJECT_DIR/logs"

cd "$PROJECT_DIR"
log_success "Directory structure created"

# Step 5: Initialize npm project (if not already initialized)
if [ ! -f "package.json" ]; then
    log_info "Initializing npm project..."
    npm init -y
    
    # Update package.json with proper scripts
    cat > package.json << 'EOF'
{
  "name": "termux-server",
  "version": "1.0.0",
  "description": "Node.js server running on Termux",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "node src/server.js"
  },
  "keywords": ["termux", "server", "nodejs"],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF
    log_success "package.json created"
else
    log_success "package.json already exists"
fi

# Step 6: Install dependencies
log_info "Installing npm dependencies..."
npm install
log_success "Dependencies installed"

# Step 7: Create server files
log_info "Creating server application files..."

# Create src/app.js
cat > src/app.js << 'EOF'
const express = require('express');
const healthRoutes = require('./routes/health.routes');
const itemsRoutes = require('./routes/items.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.path}`);
    next();
});

// Routes
app.use('/api/health', healthRoutes);
app.use('/api/items', itemsRoutes);

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Termux Server API',
        version: '1.0.0',
        endpoints: {
            health: '/api/health',
            items: '/api/items'
        }
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        path: req.path
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err.message);
    res.status(500).json({
        error: 'Internal Server Error',
        message: err.message
    });
});

module.exports = app;
EOF

# Create src/server.js
cat > src/server.js << 'EOF'
const app = require('./app');

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('  Termux Server Started Successfully!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`  Server running on port: ${PORT}`);
    console.log(`  Local URL: http://localhost:${PORT}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('\nAvailable endpoints:');
    console.log(`  - GET  /`);
    console.log(`  - GET  /api/health`);
    console.log(`  - GET  /api/items`);
    console.log(`  - POST /api/items`);
    console.log(`  - GET  /api/items/:id`);
    console.log('\nPress Ctrl+C to stop the server');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('\nSIGTERM received, shutting down gracefully...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('\nSIGINT received, shutting down gracefully...');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});
EOF

# Create src/routes/health.routes.js
cat > src/routes/health.routes.js << 'EOF'
const express = require('express');
const router = express.Router();

// Health check endpoint
router.get('/', (req, res) => {
    const healthData = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        memory: {
            used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + ' MB',
            total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + ' MB'
        },
        environment: process.env.NODE_ENV || 'development'
    };
    
    res.json(healthData);
});

module.exports = router;
EOF

# Create src/routes/items.routes.js
cat > src/routes/items.routes.js << 'EOF'
const express = require('express');
const router = express.Router();
const itemsController = require('../controllers/items.controller');

// Get all items
router.get('/', itemsController.getAllItems);

// Create a new item
router.post('/', itemsController.createItem);

// Get a single item by ID
router.get('/:id', itemsController.getItemById);

module.exports = router;
EOF

# Create src/controllers/items.controller.js
cat > src/controllers/items.controller.js << 'EOF'
// In-memory data store (for demonstration purposes)
let items = [
    { id: 1, name: 'Sample Item 1', description: 'This is a sample item', created: new Date().toISOString() },
    { id: 2, name: 'Sample Item 2', description: 'Another sample item', created: new Date().toISOString() }
];

let nextId = 3;

// Get all items
const getAllItems = (req, res) => {
    res.json({
        success: true,
        count: items.length,
        data: items
    });
};

// Create a new item
const createItem = (req, res) => {
    const { name, description } = req.body;
    
    if (!name) {
        return res.status(400).json({
            success: false,
            error: 'Name is required'
        });
    }
    
    const newItem = {
        id: nextId++,
        name,
        description: description || '',
        created: new Date().toISOString()
    };
    
    items.push(newItem);
    
    res.status(201).json({
        success: true,
        message: 'Item created successfully',
        data: newItem
    });
};

// Get a single item by ID
const getItemById = (req, res) => {
    const id = parseInt(req.params.id);
    const item = items.find(item => item.id === id);
    
    if (!item) {
        return res.status(404).json({
            success: false,
            error: 'Item not found'
        });
    }
    
    res.json({
        success: true,
        data: item
    });
};

module.exports = {
    getAllItems,
    createItem,
    getItemById
};
EOF

log_success "Server application files created"

# Step 8: Create a .gitignore file
if [ ! -f ".gitignore" ]; then
    log_info "Creating .gitignore file..."
    cat > .gitignore << 'EOF'
node_modules/
logs/*.log
*.log
.env
.DS_Store
EOF
    log_success ".gitignore created"
fi

# Step 9: Create README for the project
cat > README.md << 'EOF'
# Termux Server

A Node.js REST API server running on Termux.

## Features

- Express.js web server
- RESTful API endpoints
- Health check monitoring
- Items CRUD operations
- Dual tmux session management

## Endpoints

- `GET /` - API information
- `GET /api/health` - Health check
- `GET /api/items` - Get all items
- `POST /api/items` - Create new item
- `GET /api/items/:id` - Get item by ID

## Usage

The server is managed through tmux sessions:

- **Session 1 (server)**: Running the Node.js server
- **Session 2 (monitor)**: Server monitoring and maintenance

### tmux Commands

- Switch between sessions: `Ctrl+b` then `(`  or `)` 
- Detach from tmux: `Ctrl+b` then `d`
- List sessions: `tmux ls`
- Reattach: `tmux attach -t server` or `tmux attach -t monitor`
- Kill sessions: `tmux kill-session -t server`

## Manual Start

```bash
npm start
```

## Testing the API

```bash
# Health check
curl http://localhost:3000/api/health

# Get all items
curl http://localhost:3000/api/items

# Create an item
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"New Item","description":"Test item"}'

# Get specific item
curl http://localhost:3000/api/items/1
```
EOF

log_success "Project README created"

# Step 10: Launch tmux sessions
log_info "Setting up tmux sessions..."

# Check if tmux server is running and if our sessions already exist
if tmux has-session -t server 2>/dev/null; then
    log_warning "tmux session 'server' already exists. Killing it..."
    tmux kill-session -t server
fi

if tmux has-session -t monitor 2>/dev/null; then
    log_warning "tmux session 'monitor' already exists. Killing it..."
    tmux kill-session -t monitor
fi

# Create server session (detached) and start the server
log_info "Creating server session..."
tmux new-session -d -s server -c "$PROJECT_DIR" "npm start"

# Create monitor session (detached) for monitoring
log_info "Creating monitor session..."
tmux new-session -d -s monitor -c "$PROJECT_DIR"

# Send commands to monitor session to set it up
tmux send-keys -t monitor "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'" C-m
tmux send-keys -t monitor "echo '  Server Monitor & Maintenance Console'" C-m
tmux send-keys -t monitor "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'" C-m
tmux send-keys -t monitor "echo ''" C-m
tmux send-keys -t monitor "echo 'Server running in separate tmux session.'" C-m
tmux send-keys -t monitor "echo ''" C-m
tmux send-keys -t monitor "echo 'Useful commands:'" C-m
tmux send-keys -t monitor "echo '  - View server logs: tail -f $PROJECT_DIR/logs/server.log'" C-m
tmux send-keys -t monitor "echo '  - Check server status: curl http://localhost:3000/api/health'" C-m
tmux send-keys -t monitor "echo '  - Switch to server session: tmux switch-client -t server'" C-m
tmux send-keys -t monitor "echo '  - Or use: Ctrl+b then ( or ) to cycle sessions'" C-m
tmux send-keys -t monitor "echo ''" C-m
tmux send-keys -t monitor "echo 'Quick API test:'" C-m
tmux send-keys -t monitor "echo '  curl http://localhost:3000/api/health'" C-m
tmux send-keys -t monitor "echo ''" C-m

log_success "tmux sessions created and configured"

# Wait a moment for the server to start
sleep 2

# Display completion message
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "Setup completed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Server is running in tmux session 'server'"
echo "Monitor console is available in tmux session 'monitor'"
echo ""
echo "To access the sessions:"
echo "  1. Attach to server session:  tmux attach -t server"
echo "  2. Attach to monitor session: tmux attach -t monitor"
echo ""
echo "Project location: $PROJECT_DIR"
echo ""
echo "To test the server:"
echo "  curl http://localhost:3000/api/health"
echo ""
echo "tmux Quick Reference:"
echo "  - Detach: Ctrl+b then d"
echo "  - Switch sessions: Ctrl+b then ( or )"
echo "  - List sessions: tmux ls"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Offer to attach to the monitor session
read -p "Would you like to attach to the monitor session now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    exec tmux attach -t monitor
fi
