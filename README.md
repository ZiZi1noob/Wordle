# Wordle


## Project Structure
client/
server/

### Client-Side Architecture
client/
├── .env
├── assets/
│ ├── lottie/   # Animation files
├── lib/
│ ├── main.dart # Application entry point
│ ├── models/   # Data models
│ ├── providers/ # State management
│ ├── services/ # Calling API
│ ├── utils/  # some common widgets/functions
│ ├── widgets/  # UI components
│ │ ├── entryPage.dart # First screen
│ │ ├── gamePage.dart # Main game menu
│ │ └── menuPage.dart # Middle menu page
└──────

### Server-Side Architecture
server/
├── controllers/
├── data/   # User data
├── games/   # Core game engine
│ ├── gameTesting.js # Running [node gameTesting.js] to test game engine
│ └── normalWordle.js # Normal Wordle game engine
├── models/     # User data structure
├── routes/
│ ├── auth.routes.js # Authentication endpoints
│ └── game.routes.js # Game API endpoints
├── utils/  # Common functions
└── index.js    # Backend entry point
├── setting.json # Game settings
└──────


## Installation & Running

### Client Setup
```bash
# 1. Install Flutter SDK
# 2. Clone repository
git clone https://github.com/your-repo/wordle-clone.git
cd wordle-clone/client

# 3. Install dependencies
flutter pub get

# 4. Run with hot reload
flutter run -d chrome

### Client Setup
cd ../server

# 1. Install Node.js dependencies
npm install

# 2. Start development server
node server.js