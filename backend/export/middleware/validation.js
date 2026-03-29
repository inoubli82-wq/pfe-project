const Joi = require('joi');

const exportDataSchema = Joi.object({
  trailer_number: Joi.string().required().max(50),
  embarkation_date: Joi.date().iso().required(),
  client_name: Joi.string().required().max(100),
  number_of_bars: Joi.number().integer().min(0).required(),
  number_of_straps: Joi.number().integer().min(0).required(),
  number_of_suction_cups: Joi.number().integer().min(0).required()
});

const validateExportData = (req, res, next) => {
  const { error } = exportDataSchema.validate(req.body);
  
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  
  next();
};

module.exports = { validateExportData };