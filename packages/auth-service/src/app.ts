import express, { Request, Response } from "express";
import { requestOtp, verifyOtp } from "./auth";

export const app = express();
app.use(express.json());

// POST /auth/request-otp
app.post("/auth/request-otp", async (req: Request, res: Response) => {
  const { phone } = req.body as { phone?: string };

  if (!phone || typeof phone !== "string" || phone.trim() === "") {
    return res.status(400).json({
      error: { code: "INVALID_PHONE", message: "Invalid phone number" },
    });
  }

  try {
    await requestOtp(phone.trim());
    return res.status(200).json({ message: "OTP sent" });
  } catch (err) {
    return res.status(500).json({
      error: { code: "INTERNAL_ERROR", message: "Failed to send OTP" },
    });
  }
});

// POST /auth/verify-otp
app.post("/auth/verify-otp", async (req: Request, res: Response) => {
  const { phone, otp } = req.body as { phone?: string; otp?: string };

  if (!phone || !otp) {
    return res.status(400).json({
      error: { code: "MISSING_FIELDS", message: "phone and otp are required" },
    });
  }

  const result = await verifyOtp(phone, otp);

  if (result.success) {
    return res.status(200).json({ token: result.token });
  }

  return res.status(result.status).json({
    error: { code: result.code, message: result.message },
  });
});
