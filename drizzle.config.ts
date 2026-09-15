import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./src/config/schema.ts",
  dialect: "postgresql",
  dbCredentials: {
    host: "127.0.0.1",
    port: 5432,
    user: "postgres",
    password: "",
    database: "db_blog_app",
  },
});