-- Créer la base de données
CREATE DATABASE IF NOT EXISTS partner_export;
USE partner_export;

-- Créer la table
CREATE TABLE IF NOT EXISTS export_data (
  id INT AUTO_INCREMENT PRIMARY KEY,
  trailer_number VARCHAR(50) NOT NULL,
  embarkation_date DATE NOT NULL,
  client_name VARCHAR(100) NOT NULL,
  number_of_bars INT DEFAULT 0,
  number_of_straps INT DEFAULT 0,
  number_of_suction_cups INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insérer des données de test
INSERT INTO export_data (trailer_number, embarkation_date, client_name, number_of_bars, number_of_straps, number_of_suction_cups) 
VALUES ('759-GHZ', '2024-04-24', 'STÉG', 6, 9, 5);