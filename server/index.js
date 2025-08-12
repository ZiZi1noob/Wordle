import http from "http";
import dotenv from "dotenv";

import app from "./http-server.js";

// Initialize environment variables
dotenv.config({ path: "../client/.env" });

const PORT = process.env.PORT;
const HOST = process.env.HOST;
const HTTP_PORTOCOL = process.env.HTTP_PORTOCOL;
const NODE_ENV = process.env.NODE_ENV;

// Display important environment configuration
console.log("\n=== Environment Configuration ===");
console.log(`Server URL: ${HTTP_PORTOCOL}://${HOST}:${PORT}`);
console.log(`Node Environment: ${NODE_ENV}`);

console.log(
  "================================================================\n"
);

// Create HTTP server
const server = http.createServer(app);

// Start the server
try {
  server.listen(PORT, HOST, () => {
    console.log(`✅ Server running at ${HTTP_PORTOCOL}://${HOST}:${PORT}`);
    console.log(
      "================================================================\n\n"
    );
  });
} catch (err) {
  console.error("❌ Start Server Error:", err.message);
  process.exit(1); // Exit if DB connection fails
}

// Handle uncaught exceptions
process.on("uncaughtException", (err) => {
  console.error("Uncaught Exception:", err);
});

// Handle unhandled promise rejections
process.on("unhandledRejection", (err) => {
  console.error("Unhandled Rejection:", err);
});
