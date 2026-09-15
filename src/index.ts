import express from "express";
import cors from "cors";

import authRouter from "./routes/auth/auth.route";
import postsRouter from "./routes/posts/post.route";

const app = express();

app.use(
  cors({
    origin: true,
    methods: ["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.use(express.json());

app.use("/api/v1/auth", authRouter);
app.use("/api/v1/posts", postsRouter);

app.get("/", (req, res) => {
  res.send("Hello world");
});

app.listen(3001, () => {
  console.log(`Server running on http://localhost:3001`);
});