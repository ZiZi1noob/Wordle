import fs from "fs/promises";
import path, { dirname } from "path";
import { UserModel } from "../models/userModel.js";
import { hashUsername } from "../utils/crypto.js";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const USER_DATA_DIR = path.join(__dirname, "../data");

// Ensure data directory exists
(async () => {
  try {
    await fs.mkdir(USER_DATA_DIR, { recursive: true });
    console.log("User data directory ready");
  } catch (err) {
    console.error("Could not create users directory:", err);
    process.exit(1); // Critical failure - exit process
  }
})();

export const getUserInfo = async (req, res) => {
  const { name } = req.params;

  // Validate input
  if (!name || name.length < 3) {
    return res.status(202).json({
      success: false,
      code: 202,
      message: "Username must be at least 3 characters",
    });
  }

  const userFile = path.join(USER_DATA_DIR, `${hashUsername(name)}.json`);

  try {
    // Try to load existing user
    try {
      const data = await fs.readFile(userFile, "utf8");
      const userData = UserModel.fromJSON(JSON.parse(data));

      return res.status(200).json({
        success: true,
        code: 200,
        message: "User data retrieved successfully",
        data: userData.toJSON(),
      });
    } catch (readErr) {
      if (readErr.code === "ENOENT") {
        // Create new user
        const newUser = new UserModel(name);
        await fs.writeFile(userFile, JSON.stringify(newUser, null, 2));

        return res.status(201).json({
          success: true,
          code: 201,
          message: "New user created successfully",
          data: newUser.toJSON(),
        });
      }
      throw readErr;
    }
  } catch (err) {
    const statusCode = err.code === "EPERM" ? 403 : 500;

    return res.status(statusCode).json({
      success: false,
      code: statusCode,
      message:
        process.env.NODE_ENV === "development"
          ? err.message
          : "Unable to process user data",
      details:
        process.env.NODE_ENV === "development"
          ? {
              stack: err.stack,
              fullError: err,
            }
          : undefined,
    });
  }
};
