import express from "express";
const router = express.Router();

// Import controller methods
import { getUserInfo } from "../controllers/userController.js";

// User management routes
router.get("/get-info/:name", getUserInfo);

// Export the router
export { router };
