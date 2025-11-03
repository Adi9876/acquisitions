import 'dotenv/config';

import { neon, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';

// Configure Neon HTTP endpoint; allow override via env for Docker
if (process.env.NODE_ENV === 'development') {
  const endpoint =
    process.env.NEON_FETCH_ENDPOINT || 'http://localhost:5432/sql';
  neonConfig.fetchEndpoint = endpoint;
  neonConfig.useSecureWebSocket = false;
  neonConfig.poolQueryViaFetch = true;
}

const sql = neon(process.env.DATABASE_URL);

const db = drizzle(sql);

export { db, sql };
