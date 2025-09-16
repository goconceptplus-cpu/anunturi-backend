require('dotenv').config();
const fs = require('fs');
const path = require('path');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const db = require('./config/database');
const authRoutes = require('./routes/auth');
const announcementRoutes = require('./routes/announcements');
const categoryRoutes = require('./routes/categories');
const countyRoutes = require('./routes/counties');
const uploadRoutes = require('./routes/upload');

const app = express();
const PORT = process.env.PORT || 5000;

// Init DB (run schema.sql once; it's idempotent)
(async () => {
  try {
    const schema = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
    await db.pool.query(schema);
    console.log('✓ Database initialized (schema.sql)');
  } catch (err) {
    console.error('DB init error:', err.message);
  }
})();

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));

const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 });
app.use('/api', limiter);

app.get('/api/health', (req,res)=>res.json({ok:true}));
app.use('/api/auth', authRoutes);
app.use('/api/announcements', announcementRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/counties', countyRoutes);
app.use('/api', uploadRoutes);

app.use((req, res) => res.status(404).json({ error: 'Route not found' }));

app.listen(PORT, () => console.log(`API listening on :${PORT}`));
