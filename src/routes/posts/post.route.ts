import { Router } from "express";
import { upload } from "../../middleware/upload.middleware";
import PostsController from "../../controllers/posts/posts.controller";

const router = Router();

router.post("/", upload, PostsController.createPost);

router.get("/", PostsController.getPosts);

router.get("/:id", PostsController.getPostById);

router.patch("/:id", upload, PostsController.updatePost);

router.delete("/:id", PostsController.deletePost);

export default router;