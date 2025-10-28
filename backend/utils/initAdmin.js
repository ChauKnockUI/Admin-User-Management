const bcrypt = require('bcrypt');
const User = require('../models/User');

async function ensureAdminExists() {
  const username = process.env.ADMIN_USERNAME || 'admin';
  const password = process.env.ADMIN_PASSWORD || 'admin123';
  const email = process.env.ADMIN_EMAIL || 'admin@system.com';

  const existing = await User.findOne({ username });
  if (!existing) {
    const hashed = await bcrypt.hash(password, 10);
    const admin = new User({ username, email, password: hashed });
    await admin.save();
    console.log('Default admin created:', username);
  } else {
    console.log('ℹAdmin already exists');
  }
}

module.exports = { ensureAdminExists };
