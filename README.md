# Wordle


## Project Structure
```
client/
server/
README.md
```
### Client-Side Architecture
```
client/
├── .env
├── assets/
│ ├── lottie/   # Animation files
├── lib/
│ ├── main.dart # Application entry point
│ ├── models/   # Data models
│ ├── providers/ # State management
│ ├── services/ # Calling API
│ ├── utils/  # Some common widgets/functions
│ ├── widgets/  # UI components
│ │ ├── entryPage.dart # First screen
│ │ ├── gamePage.dart # Main game menu
│ │ └── menuPage.dart # Middle menu page
└──────
```

### Server-Side Architecture
```
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
```

## Installation & Running

### Client Setup
```bash
# 1. Install Flutter SDK
# 2. Clone repository
git clone https://github.com/ZiZi1noob/Wordle.git
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
node index.js
```

## Optimization & Future Plans

1. First-load animation stutters during playback<br>
The stutter occurs because the UI layer constructs animation widgets only upon user interaction (e.g., pressing help button), causing initial rendering delays. A quick mitigation is to preload animation resources during intermediate loading stages—for example, by initializing them in a post-login loading screen.

2. [Lottie](https://pub.dev/packages/lottie) vs. [Rive](https://rive.app/)<br>
Currently using Lottie (simple JSON import, fast setup)；But I believe Rive is better on UX, which supports user interaction on animations.

3. Need to add a how-to-play tutorial<br>
Like me, it was my first time to play this game. I even googled how to play Wordle. So, I would rather than add one game tutorial. Currently, it has one help dialog for showing basic rules. But I think it can be much better.

4. Need to add audio<br>
I never played one game without audio. So a normal product needs background music, button sounds, and victory/failure sounds. Due to time constraints, I started writing this demo on Monday at noon and had to work during the day, so it took me about seven or eight hours to complete this demo.


Anyway, thanks for the chance of learning something new. Hope enjoy.
