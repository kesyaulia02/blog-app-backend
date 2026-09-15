import multer from "multer";
import path from "path";

const storage = multer.memoryStorage();

export const upload = multer({
  storage,

  limits: {
    fileSize: 5 * 1024 * 1024,
  },

  fileFilter: (_req, file, cb) => {
    console.log("NAMA FILE:", file.originalname);
    console.log("MIME TYPE:", file.mimetype);

    const allowedExtensions = [".jpg", ".jpeg", ".png", ".gif", ".webp"];
    const extension = path.extname(file.originalname).toLowerCase();

    if (
      file.mimetype.startsWith("image/") ||
      allowedExtensions.includes(extension)
    ) {
      cb(null, true);
    } else {
      cb(new Error("Hanya file gambar yang diperbolehkan!"));
    }
  },
}).single("image");