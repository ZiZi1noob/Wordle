import readline from "readline";
import { readSettings } from "../utils/readSetting.js";

class NormalWordleGame {
  constructor(settings, debugMode = false) {
    this.settings = {
      words: settings.words.map((word) => word.toUpperCase()),
      maxRounds: settings.maxRounds,
      caseSensitive: settings.caseSensitive || false,
    };
    this.debugMode = debugMode;
    this.resetGame();
  }

  resetGame() {
    this.answer =
      this.settings.words[
        Math.floor(Math.random() * this.settings.words.length)
      ].toUpperCase();

    if (this.debugMode) {
      console.log("[DEBUG] System Word List:", this.settings.words);
      console.log("[DEBUG] Chosen Answer:", this.answer);
    }

    this.guesses = [];
    this.currentRound = 0;
    this.isGameOver = false;
    this.isWon = false;
  }

  submitGuess(guess) {
    console.log(guess);
    guess = this.settings.caseSensitive ? guess : guess.toUpperCase();

    if (this.isGameOver) {
      return {
        success: false,
        message: "Game is already over",
        data: {
          isGameOver: true,
          isWon: this.isWon,
          answer: this.answer,
        },
      };
    }

    if (guess.length !== 5) {
      return {
        success: false,
        message: "Guess must be 5 letters long",
        data: null,
      };
    }

    if (!this.settings.words.includes(guess)) {
      return {
        success: false,
        message: "Word not in dictionary",
        data: null,
        // {
        //   suggestions: this.getSimilarWords(guess),
        // },
      };
    }

    // Process valid guess
    const result = this.evaluateGuess(guess);
    this.guesses.push(result);
    this.currentRound++;

    const response = {
      success: true,
      message: "Guess submitted successfully",
      data: {
        guessResult: result,
        currentRound: this.currentRound,
        remainingRounds: this.settings.maxRounds - this.currentRound,
        isGameOver: false,
        isWon: false,
      },
    };

    if (guess === this.answer) {
      this.isGameOver = true;
      this.isWon = true;
      response.data.isGameOver = true;
      response.data.isWon = true;
      response.data.answer = this.answer;
      response.message = "Congratulations! You guessed the word!";
    } else if (this.currentRound >= this.settings.maxRounds) {
      this.isGameOver = true;
      response.data.isGameOver = true;
      response.data.answer = this.answer;
      response.message = "Game over! You've used all your attempts";
    }

    return response;
  }

  // getSimilarWords(guess) {
  //   return this.settings.words
  //     .filter((word) => word[0] === guess[0])
  //     .slice(0, 5);
  // }

  evaluateGuess(guess) {
    const answerLetters = this.answer.split("");
    const guessLetters = guess.split("");
    const result = [];
    const answerLetterCounts = {};

    for (let i = 0; i < 5; i++) {
      if (guessLetters[i] !== answerLetters[i]) {
        answerLetterCounts[answerLetters[i]] =
          (answerLetterCounts[answerLetters[i]] || 0) + 1;
      }
    }

    for (let i = 0; i < 5; i++) {
      const letter = guessLetters[i];
      let status;

      if (letter === answerLetters[i]) {
        status = "correct";
      } else if (answerLetterCounts[letter] > 0) {
        status = "present";
        answerLetterCounts[letter]--;
      } else {
        status = "absent";
      }

      result.push({
        letter,
        status,
        position: i,
      });
    }

    return result;
  }

  getGameState() {
    return {
      answer: this.answer,
      currentRound: this.currentRound,
      maxRounds: this.settings.maxRounds,
      guesses: this.guesses,
      isGameOver: this.isGameOver,
      isWon: this.isWon,
      remainingRounds: this.settings.maxRounds - this.currentRound,
    };
  }
}

function normalWordleTesting() {
  console.log("====== WORDLE CONSOLE TEST ======");
  let settings;
  let game;

  // Initialize settings
  try {
    settings = readSettings("../setting.json");
    console.log("Reading setting file successfully");
  } catch (error) {
    console.error("Fatal error reading settings:", error.message);
    process.exit(1);
  }

  // Initialize game
  try {
    game = new NormalWordleGame(settings, true); // true enables debug mode
    console.log("Game initialized successfully");
  } catch (error) {
    console.error("Fatal error initializing game:", error.message);
    process.exit(1);
  }

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  console.log(`Guess the 5-letter word (${game.settings.maxRounds} attempts)`);
  console.log("Legend: O = Hit, ? = Present, _ = Miss");
  console.log("Type your guess and press Enter:");

  function playTurn() {
    rl.question(`Attempt ${game.currentRound + 1}: `, (input) => {
      try {
        const guess = input.trim().toUpperCase();
        const result = game.submitGuess(guess);

        // Display results
        console.log(
          "Your guess: ",
          result.data.guessResult.map((r) => r.letter).join(" ")
        );
        console.log(
          "Feedback:   ",
          result.data.guessResult
            .map((r) => {
              switch (r.status) {
                case "hit":
                  return "O";
                case "present":
                  return "?";
                default:
                  return "_";
              }
            })
            .join(" ")
        );

        // Check game state
        const state = game.getGameState();
        if (state.isGameOver) {
          if (state.isWon) {
            console.log(
              `\n✅ Correct! You won in ${state.currentRound} tries!`
            );
          } else {
            console.log(`\n❌ Game over! The word was: ${state.answer}`);
          }
          rl.close();
          return;
        }

        console.log(`Remaining attempts: ${state.remainingRounds}`);
        playTurn(); // Continue to next turn
      } catch (error) {
        console.error(`⚠️ ${error.message}`);
        playTurn(); // Let them try again
      }
    });
  }

  playTurn(); // Start the first turn
}
export { NormalWordleGame, normalWordleTesting };
