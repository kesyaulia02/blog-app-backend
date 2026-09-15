import { Router } from "express";
import jwt from "jsonwebtoken";

const router = Router();

router.post("/login", (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "userId wajib diisi",
    });
  }

  const token = jwt.sign(
    { userId: Number(userId) },
    process.env.JWT_SECRET || "helloworld",
    { expiresIn: "1h" }
  );

  return res.status(200).json({
    success: true,
    message: "Login berhasil",
    data: {
      token,
    },
  });
});

export default router;