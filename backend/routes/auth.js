const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();
const jwtSecret = process.env.JWT_SECRET || 'secret';

// Đăng nhập
router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ message: 'Missing credentials' });

  const user = await User.findOne({ username });
  if (!user) return res.status(401).json({ message: 'Invalid username or password' });

  const match = await bcrypt.compare(password, user.password);
  if (!match) return res.status(401).json({ message: 'Invalid username or password' });

  const token = jwt.sign({ id: user._id }, jwtSecret, { expiresIn: '8h' });

  res.json({
    token,
    user: {
      id: user._id,
      username: user.username,
      email: user.email,
      image: user.image
    }
  });
});

module.exports = router;
