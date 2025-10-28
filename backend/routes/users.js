const express = require('express');
const multer = require('multer');
const bcrypt = require('bcrypt');
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
const upload = multer();

// ⚙️ Tất cả các route bên dưới yêu cầu đăng nhập
router.use(authMiddleware);

// Lấy danh sách người dùng
router.get('/', async (req, res) => {
  const { search } = req.query;
  const q = {};
  if (search) {
    const regex = new RegExp(search, 'i');
    q.$or = [{ username: regex }, { email: regex }];
  }
  const users = await User.find(q).select('-password');
  res.json(users);
});

// Thêm người dùng mới
router.post('/', upload.single('image'), async (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password)
    return res.status(400).json({ message: 'Missing fields' });

  const existing = await User.findOne({ $or: [{ username }, { email }] });
  if (existing) return res.status(400).json({ message: 'Username or email already exists' });

  let imageData = null;
  if (req.file) {
    imageData = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
  } else if (req.body.image) {
    imageData = req.body.image;
  }

  const hashed = await bcrypt.hash(password, 10);
  const user = new User({ username, email, password: hashed, image: imageData });
  await user.save();

  res.status(201).json({
    message: 'User created',
    user: { id: user._id, username: user.username, email: user.email, image: user.image }
  });
});

// Lấy thông tin 1 user
router.get('/:id', async (req, res) => {
  const user = await User.findById(req.params.id).select('-password');
  if (!user) return res.status(404).json({ message: 'Not found' });
  res.json(user);
});

// Cập nhật user
router.put('/:id', upload.single('image'), async (req, res) => {
  const user = await User.findById(req.params.id);
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
  res.json({ message: 'User updated', user: { id: user._id, username: user.username, email: user.email, image: user.image } });
});

// Xóa user
router.delete('/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) return res.status(404).json({ message: 'Not found' });
  await user.deleteOne();
  res.json({ message: 'User deleted' });
});

module.exports = router;
