import 'dotenv/config';

export default {
  schema: './src/modals/*.js',
  output: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL,
  },
};
