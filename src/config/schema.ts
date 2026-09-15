import {
  pgTable,
  serial,
  varchar,
  text,
  timestamp,
  integer,
} from "drizzle-orm/pg-core";

export const usersTable = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 100 }).notNull(),
  email: varchar("email", { length: 255 }).notNull(),
  password: varchar("password", { length: 255 }).notNull(),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const categoriesTable = pgTable("categories", {
  id: serial("id").primaryKey(),
  name: varchar("name", { length: 100 }).notNull(),
  createdAt: timestamp("created_at").defaultNow(),
});

export const postsTable = pgTable("posts", {
  id: serial("id").primaryKey(),

  userId: integer("user_id").notNull(),

  categoryId: integer("category_id").notNull(),

  title: varchar("title", { length: 255 }).notNull(),

  content: text("content").notNull(),

  imageUrl: varchar("image_url", { length: 500 }),

  imagePublicId: varchar("image_public_id", { length: 255 }),

  status: varchar("status", { length: 20 }).default("published"),

  createdAt: timestamp("created_at").defaultNow(),

  updatedAt: timestamp("updated_at").defaultNow(),
});

export const commentsTable = pgTable("comments", {
  id: serial("id").primaryKey(),

  userId: integer("user_id").notNull(),

  postId: integer("post_id").notNull(),

  content: text("content").notNull(),

  createdAt: timestamp("created_at").defaultNow(),

  updatedAt: timestamp("updated_at").defaultNow(),
});