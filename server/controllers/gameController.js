import fs from "fs/promises";
import path, { dirname } from "path";
import { UserModel } from "../models/userModel.js";
import { hashUsername } from "../utils/crypto.js";
import { fileURLToPath } from "url";
import { readSettings } from "../utils/readSetting.js";
import { NormalWordleGame } from "../games/normalWordle.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const USER_DATA_DIR = path.join(__dirname, "../data");

// Read game settings from file
const settingsPath = path.join(__dirname, "../setting.json");
let settings;
try {
  settings = await readSettings(settingsPath);
} catch (err) {
  console.error("Error reading settings:", err);
}

export const createNewGame = async (req, res) => {
  try {
    const { name, gameId } = req.params;

    // 1. Construct user file path
    const userFilePath = path.join(USER_DATA_DIR, `${hashUsername(name)}.json`);

    // 2. Read and parse user data
    let userData;
    try {
      const fileContent = await fs.readFile(userFilePath, "utf-8");
      userData = UserModel.fromJSON(JSON.parse(fileContent));
    } catch (err) {
      if (err.code === "ENOENT") {
        return res.status(404).json({ error: "User not found" });
      }
      throw err;
    }

    // 4. Initialize game with settings (debug mode false in production)
    const wordleGame = new NormalWordleGame(settings, false);
    const initialGameState = wordleGame.getGameState();

    // 5. Create new game structure matching UserModel
    const newGame = {
      gameId,
      answer: initialGameState.answer, // Will be null since game isn't over
      currentRound: initialGameState.currentRound,
      maxRounds: initialGameState.maxRounds,
      isGameOver: initialGameState.isGameOver,
      guesses: initialGameState.guesses,
      createdAt: new Date().toISOString(),
      lastUpdated: new Date().toISOString(),
      settings: {
        // Store relevant settings with the game
        wordLength: settings.words[0]?.length,
        maxRounds: settings.maxRounds,
        caseSensitive: settings.caseSensitive || false,
      },
    };

    // 6. Update user model
    userData.gameState.currentGame = newGame;
    // userData.gameState.history.unshift(newGame);
    userData.updateLastModified();

    // 7. Save updated user data
    await fs.writeFile(
      userFilePath,
      JSON.stringify(userData.toJSON(), null, 2)
    );

    // 8. Return response
    res.status(201).json({
      success: true,
      code: 201,
      message: "Creating new game done!",
      data: {
        gameId,
        currentRound: newGame.currentRound,
        maxRounds: newGame.maxRounds,
        guesses: newGame.guesses,
        answer: newGame.answer,
        isGameOver: newGame.isGameOver,
        createdAt: newGame.createdAt,
        lastUpdated: newGame.createdAt,
        settings: {
          wordLength: newGame.settings.wordLength,
          maxRounds: newGame.settings.maxRounds,
          caseSensitive: newGame.settings.caseSensitive,
        },
      },
    });
  } catch (error) {
    console.error("Error creating new game:", error);
    res.status(500).json({
      error: "Internal server error",
      details:
        process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

export const submitGuess = async (req, res) => {
  try {
    const { name, gameId } = req.params;
    const { guess } = req.body;

    // Validate guess exists
    if (!guess) {
      return res.status(400).json({ error: "Guess is required" });
    }

    // 2. Get user data
    const userFilePath = path.join(USER_DATA_DIR, `${hashUsername(name)}.json`);
    let userData;
    try {
      const fileContent = await fs.readFile(userFilePath, "utf-8");
      userData = UserModel.fromJSON(JSON.parse(fileContent));
    } catch (err) {
      if (err.code === "ENOENT") {
        return res.status(404).json({ message: "User not found" });
      }
      throw err;
    }

    // 3. Verify game exists and is active
    if (
      !userData.gameState?.currentGame ||
      userData.gameState.currentGame.gameId !== gameId
    ) {
      return res.status(404).json({ message: "Game not found or not active" });
    }

    // 4. Get game settings and restore state
    const currentGame = userData.gameState.currentGame;
    const wordleGame = new NormalWordleGame(settings, false);

    // Restore game state
    wordleGame.answer = currentGame.answer;
    wordleGame.guesses = currentGame.guesses || [];
    wordleGame.currentRound = currentGame.currentRound || 0;
    wordleGame.isGameOver = currentGame.isGameOver || false;
    wordleGame.isWon = currentGame.isWon || false;

    // 5. Submit the guess
    const result = wordleGame.submitGuess(guess);

    if (!result.success) {
      return res.status(202).json({
        success: false,
        code: 202,
        message: result.message,
        data: null,
      });
    }

    // 6. Update user data
    const gameState = wordleGame.getGameState();
    userData.gameState.currentGame = {
      ...currentGame,
      currentRound: gameState.currentRound,
      guesses: gameState.guesses,
      lastUpdated: new Date().toISOString(),
      isWon: gameState.isWon,
      isGameOver: gameState.isGameOver,
      answer: gameState.answer,
    };

    // 7. If game over, move to history
    let responseData = userData.gameState.currentGame;
    if (gameState.isGameOver) {
      // Create simplified history entry
      const historyEntry = {
        gameId: userData.gameState.currentGame.gameId,
        answer:
          userData.gameState.currentGame.targetWord ||
          userData.gameState.currentGame.answer,
        guesses: userData.gameState.currentGame.guesses.map((guessStep) =>
          guessStep.map((letterData) => letterData["letter"]).join("")
        ),
        isWon: gameState.isWon,
        createdAt: userData.gameState.currentGame.createdAt,
        completedAt: new Date().toISOString(),
        timeUsed: calculateTimeUsed(userData.gameState.currentGame.createdAt),
      };
      console.log(`historyEntry:  ${JSON.stringify(historyEntry)}`);
      // Update history
      userData.gameState.history = [
        historyEntry,
        ...(userData.gameState.history || []),
      ];

      // Update stats
      userData.stats = updateStats(
        userData.stats,
        gameState.isWon,
        calculateTimeUsed(historyEntry.createdAt)
      );
      // Only null the currentGame AFTER we've prepared our response
      userData.gameState.currentGame = null;
      console.log(`userData:  ${JSON.stringify(userData)}`);
    }

    // 8. Save updated data
    await fs.writeFile(
      userFilePath,
      JSON.stringify(userData.toJSON(), null, 2)
    );

    // 9. Return response
    res.status(200).json({
      success: true,
      code: 200,
      message: result.message,
      data: responseData,
    });
  } catch (error) {
    console.error("Error submitting guess:", error);
    res.status(500).json({
      code: 500,
      error: "Internal server error",
      details:
        process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};
// Helper function to update stats
function updateStats(currentStats, isWon, timeUsed) {
  const stats = currentStats || {
    gamesPlayed: 0,
    gamesWon: 0,
    winPercentage: 0,
    currentStreak: 0,
    maxStreak: 0,
    guessDistribution: [0, 0, 0, 0, 0, 0],
    averageTime: 0,
  };

  const newGamesPlayed = stats.gamesPlayed + 1;
  const newGamesWon = isWon ? stats.gamesWon + 1 : stats.gamesWon;
  const newStreak = isWon ? stats.currentStreak + 1 : 0;

  return {
    ...stats,
    gamesPlayed: newGamesPlayed,
    gamesWon: newGamesWon,
    winPercentage: (newGamesWon / newGamesPlayed) * 100,
    currentStreak: newStreak,
    maxStreak: Math.max(newStreak, stats.maxStreak),
    averageTime:
      (stats.averageTime * stats.gamesPlayed + timeUsed) / newGamesPlayed,
    guessDistribution: isWon
      ? updateGuessDistribution(stats.guessDistribution, stats.gamesPlayed)
      : stats.guessDistribution,
  };
}

function updateGuessDistribution(distribution, guessCount) {
  const newDist = [...distribution];
  if (guessCount >= 1 && guessCount <= 6) {
    newDist[guessCount - 1]++;
  }
  return newDist;
}

function calculateTimeUsed(createdAt) {
  return (new Date() - new Date(createdAt)) / 1000; // in seconds
}
