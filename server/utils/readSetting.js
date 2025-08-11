import fs from "fs";

function readSettings(path) {
  try {
    // Read the file synchronously
    const data = fs.readFileSync(path, "utf8");
    // Parse the JSON data
    const settings = JSON.parse(data);

    return settings;
  } catch (error) {
    throw error; // Re-throw the error for the caller to handle
  }
}
export { readSettings };
