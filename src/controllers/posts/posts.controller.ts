import { Request, Response } from "express";

import {
  createPostSchema,
  postIdSchema,
  updatePostSchema,
} from "../../validations/post.validations";

import { db } from "../../config/db";
import { postsTable } from "../../config/schema";

import { and, desc, eq } from "drizzle-orm";

import {
  deleteFromCloudinary,
  uploadToCloudinary,
} from "../../services/cloudinary.service";

export class PostsController {
  // =========================
  // CREATE POST
  // =========================
  createPost = async (req: Request, res: Response) => {
    try {
      const validateData = createPostSchema.parse(req.body);

      const {
        userId,
        categoryId,
        title,
        content,
      } = validateData;

      let imageUrl: string | undefined;
      let imagePublicId: string | undefined;

      if (req.file) {
        const uploadResult = await uploadToCloudinary(req.file.buffer);

        imageUrl = uploadResult.secure_url;
        imagePublicId = uploadResult.public_id;
      }

      const [result] = await db
        .insert(postsTable)
        .values({
          userId,
          categoryId,
          title,
          content,
          imageUrl,
          imagePublicId,
        })
        .returning({
          id: postsTable.id,
        });

      return res.status(201).json({
        success: true,
        message: "Post created successfully",
        data: {
          id: result.id,
          userId,
          categoryId,
          title,
          content,
          imageUrl,
          imagePublicId,
        },
      });
    } catch (error) {
      console.error("Create post error:", error);

      return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
        error: error instanceof Error
          ? error.message
          : error,
      });
    }
  };

  // =========================
  // GET ALL POSTS
  // =========================
  getPosts = async (req: Request, res: Response) => {
    try {
      const posts = await db
        .select()
        .from(postsTable)
        .where(eq(postsTable.status, "published"))
        .orderBy(desc(postsTable.createdAt));

      return res.status(200).json({
        success: true,
        message: "Get Posts Successfully",
        data: {
          posts,
        },
      });
    } catch (error) {
      console.error("Get posts error:", error);

      return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
        error: error instanceof Error
          ? error.message
          : error,
      });
    }
  };

  // =========================
  // GET POST BY ID
  // =========================
  getPostById = async (req: Request, res: Response) => {
    try {
      const validatedParams = postIdSchema.parse(req.params);
      const { id } = validatedParams;

      const [post] = await db
        .select()
        .from(postsTable)
        .where(
          and(
            eq(postsTable.id, id),
            eq(postsTable.status, "published")
          )
        );

      if (!post) {
        return res.status(404).json({
          success: false,
          message: "Post Not Found",
        });
      }

      return res.status(200).json({
        success: true,
        message: "Post retrieved successfully",
        data: {
          post,
        },
      });
    } catch (error) {
      console.error("Get post by id error:", error);

      return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
        error: error instanceof Error
          ? error.message
          : error,
      });
    }
  };

  // =========================
  // DELETE POST
  // =========================
  deletePost = async (req: Request, res: Response) => {
    try {
      const validatedParams = postIdSchema.parse(req.params);
      const { id } = validatedParams;

      const existingPost = await db.query.postsTable.findFirst({
        where: eq(postsTable.id, id),
      });

      if (!existingPost) {
        return res.status(404).json({
          success: false,
          message: "Post not found",
        });
      }

      await db
        .update(postsTable)
        .set({
          status: "delete",
          updatedAt: new Date(),
        })
        .where(eq(postsTable.id, id));

      return res.status(200).json({
        success: true,
        message: "Post deleted successfully",
      });
    } catch (error) {
      console.error("Delete post error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error instanceof Error
          ? error.message
          : error,
      });
    }
  };

  // =========================
  // UPDATE POST
  // =========================
  updatePost = async (req: Request, res: Response) => {
    try {
      const validatedParams = postIdSchema.parse(req.params);
      const { id } = validatedParams;

      const bodyData = {
        categoryId: req.body.categoryId,
        title: req.body.title,
        content: req.body.content,
      };

      const validatedData = updatePostSchema.parse(bodyData);

      const {
        categoryId,
        title,
        content,
      } = validatedData;

      const [existingPost] = await db
        .select()
        .from(postsTable)
        .where(eq(postsTable.id, id));

      if (!existingPost) {
        return res.status(404).json({
          success: false,
          message: "Post not found",
        });
      }

      let imageUrl = existingPost.imageUrl;
      let imagePublicId = existingPost.imagePublicId;

      if (req.file) {
        const uploadResult = await uploadToCloudinary(req.file.buffer);

        imageUrl = uploadResult.secure_url;
        imagePublicId = uploadResult.public_id;

        if (existingPost.imagePublicId) {
          await deleteFromCloudinary(existingPost.imagePublicId);
        }
      }

      await db
        .update(postsTable)
        .set({
          ...(categoryId !== undefined && {
            categoryId,
          }),

          ...(title !== undefined && {
            title,
          }),

          ...(content !== undefined && {
            content,
          }),

          ...(req.file && {
            imageUrl,
            imagePublicId,
          }),

          status: "published",
          updatedAt: new Date(),
        })
        .where(eq(postsTable.id, id));

      const [updatedPost] = await db
        .select()
        .from(postsTable)
        .where(eq(postsTable.id, id));

      return res.status(200).json({
        success: true,
        message: "Post updated successfully",
        data: {
          post: updatedPost,
        },
      });
    } catch (error) {
      console.error("Update post error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error instanceof Error
          ? error.message
          : error,
      });
    }
  };
}

// PENTING: INI HARUS ADA
export default new PostsController();