const express = require('express');
const multer = require('multer');
const bcrypt = require('bcrypt');
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
const upload = multer();

// Lấy profile người dùng hiện tại
router.get('/', authMiddleware, async (req, res) => {
  const user = await User.findById(req.user._id).select('-password');
  res.json(user);
});

// Cập nhật profile
router.put('/', authMiddleware, upload.single('image'), async (req, res) => {
  const user = await User.findById(req.user._id);
  if (!user) return res.status(404).json({ message: 'Not found' });

  const { username, email, password } = req.body;
  if (username) user.username = username;
  if (email) user.email = email;
  if (password) user.password = await bcrypt.hash(password, 10);

  if (req.file) {
    user.image = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
  } else if (req.body.image) {
    user.image = req.body.image;
  }

  await user.save();
  res.json({
    message: 'Profile updated',
    user: { id: user._id, username: user.username, email: user.email, image: user.image }
  });
});

module.exports = router;
