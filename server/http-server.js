import express from "express";
import helmet from "helmet";
import cors from "cors";

//const cookieParser = require('cookie-parser')

// middleware
const app = express();
app.use(cors());
app.use(helmet());
//app.use(cookieParser())
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// routes
import { router as userRoute } from "./routers/userRoute.js";
import { router as gameRoute } from "./routers/gameRoute.js";
app.use("/api/v1/user", userRoute);
app.use("/api/v1/game", gameRoute);
export default app;
