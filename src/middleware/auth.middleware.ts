import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

export const authenticate = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.log("Authentication middleware");

  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      message: "Sesi habis, silahkan login kembali",
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    const secret = process.env.JWT_SECRET || "helloworld";

    jwt.verify(token, secret);

    console.log("Token valid");

    next();
  } catch (error) {
    console.error("JWT Error:", error);

    return res.status(401).json({
      success: false,
      message: "Sesi habis, silahkan login kembali",
    });
  }
};