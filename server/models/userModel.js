import { hashUsername } from "../utils/crypto.js";

export default class UserModel {
  constructor(username) {
    this.meta = {
      version: "1.0",
      createdAt: new Date().toISOString(),
      lastUpdated: new Date().toISOString(),
    };

    this.user = {
      id: hashUsername(username),
      username,
      preferences: {
        theme: "",
        gameMode: "",
      },
    };

    this.stats = {
      gamesPlayed: 0,
      gamesWon: 0,
      winPercentage: 0,
      currentStreak: 0,
      maxStreak: 0,
      guessDistribution: [0, 0, 0, 0, 0, 0],
      averageTime: 0,
    };

    this.gameState = {
      currentGame: {}, // Will contain active game data from backend
      history: [], // Will contain completed games from backend
    };
  }

  // Simple method to update last modified timestamp
  updateLastModified() {
    this.meta.lastUpdated = new Date().toISOString();
  }

  // Parses backend response into the model
  static fromJSON(jsonData) {
    const model = new UserModel(jsonData.user.username);

    // Preserve all backend-provided data exactly
    model.meta = jsonData.meta || model.meta;
    model.user = jsonData.user || model.user;
    model.stats = jsonData.stats || model.stats;
    model.gameState = jsonData.gameState || model.gameState;

    return model;
  }

  // Converts model to JSON for API requests
  toJSON() {
    return {
      meta: this.meta,
      user: this.user,
      stats: this.stats,
      gameState: this.gameState,
    };
  }
}

export { UserModel };
