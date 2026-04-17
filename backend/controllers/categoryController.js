const Category = require('../models/Category');

const getAllCategories = async (req, res) => {
  try {
    const shopId = req.user.shopId;
    const categories = await Category.find({ shopId, isActive: true }).sort('name');
    res.json(categories);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const createCategory = async (req, res) => {
  const { name, description } = req.body;
  const shopId = req.user.shopId;

  try {
    const categoryExists = await Category.findOne({ name, shopId, isActive: true });
    if (categoryExists) {
      return res.status(400).json({ message: 'Category already exists' });
    }

    const category = await Category.create({ name, description, shopId });
    res.status(201).json(category);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const updateCategory = async (req, res) => {
  const { id } = req.params;
  const { name, description } = req.body;
  const shopId = req.user.shopId;

  try {
    const category = await Category.findOne({ _id: id, shopId });
    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }

    category.name = name || category.name;
    category.description = description !== undefined ? description : category.description;
    await category.save();

    res.json(category);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const deleteCategory = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;

  try {
    const category = await Category.findOne({ _id: id, shopId });
    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }

    category.isActive = false;
    await category.save();

    res.json({ message: 'Category deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  getAllCategories,
  createCategory,
  updateCategory,
  deleteCategory,
};
