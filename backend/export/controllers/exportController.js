const pool = require('../config/database');

const exportController = {
  // Récupérer tous les exports
  getAllExports: async (req, res) => {
    try {
      const [rows] = await pool.query('SELECT * FROM export_data ORDER BY created_at DESC');
      res.json(rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Erreur base de données' });
    }
  },

  // Créer un nouvel export
  createExport: async (req, res) => {
    try {
      const {
        trailer_number,
        embarkation_date,
        client_name,
        number_of_bars,
        number_of_straps,
        number_of_suction_cups
      } = req.body;

      const [result] = await pool.query(
        `INSERT INTO export_data 
         (trailer_number, embarkation_date, client_name, number_of_bars, 
          number_of_straps, number_of_suction_cups) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [trailer_number, embarkation_date, client_name, number_of_bars, number_of_straps, number_of_suction_cups]
      );

      res.status(201).json({ 
        id: result.insertId, 
        message: 'Export créé avec succès' 
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Erreur base de données' });
    }
  },

  // Mettre à jour un export
  updateExport: async (req, res) => {
    try {
      const { id } = req.params;
      const {
        trailer_number,
        embarkation_date,
        client_name,
        number_of_bars,
        number_of_straps,
        number_of_suction_cups
      } = req.body;

      const [result] = await pool.query(
        `UPDATE export_data 
         SET trailer_number = ?, embarkation_date = ?, client_name = ?,
             number_of_bars = ?, number_of_straps = ?, number_of_suction_cups = ?
         WHERE id = ?`,
        [trailer_number, embarkation_date, client_name, number_of_bars, number_of_straps, number_of_suction_cups, id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Export non trouvé' });
      }

      res.json({ message: 'Export mis à jour avec succès' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Erreur base de données' });
    }
  },

  // Supprimer un export
  deleteExport: async (req, res) => {
    try {
      const { id } = req.params;
      const [result] = await pool.query('DELETE FROM export_data WHERE id = ?', [id]);

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Export non trouvé' });
      }

      res.json({ message: 'Export supprimé avec succès' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Erreur base de données' });
    }
  }
};

module.exports = exportController;