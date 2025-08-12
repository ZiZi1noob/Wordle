import crypto from "crypto";

function hashUsername(name) {
  return crypto.createHash("sha256").update(name).digest("hex");
}

export { hashUsername };
