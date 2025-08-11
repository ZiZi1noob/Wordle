import { normalWordleTesting } from "./normalWordle.js";

// Get command line arguments
const args = process.argv.slice(2);
const debugMode = args.includes("--debug") || args.includes("-d");

if (debugMode) {
  normalWordleTesting();
}
