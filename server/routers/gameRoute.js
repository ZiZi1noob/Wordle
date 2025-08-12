import express from "express";
const router = express.Router();

// Import controller methods
import { createNewGame, submitGuess } from "../controllers/gameController.js";

// Game management routes
router.post("/create-game/:name/:gameId", createNewGame);
router.post("/:name/:gameId/submit-guess", submitGuess);
// Export the router
export { router };
