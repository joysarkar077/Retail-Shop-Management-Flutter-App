const Order = require('../models/Order');

const generateInvoiceNumber = async () => {
  const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, ''); // Format: YYYYMMDD
  const prefix = `INV-${dateStr}-`;
  
  const lastOrder = await Order.findOne({ invoiceNumber: { $regex: `^${prefix}` } }).sort({ invoiceNumber: -1 });

  let seq = 1;
  if (lastOrder && lastOrder.invoiceNumber) {
    const parts = lastOrder.invoiceNumber.split('-');
    if (parts.length === 3) {
      seq = parseInt(parts[2], 10) + 1;
    }
  }
  
  const seqStr = seq.toString().padStart(3, '0');
  return `${prefix}${seqStr}`;
};

module.exports = {
  generateInvoiceNumber,
};
