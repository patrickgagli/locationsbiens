-- Création de la base de données locationsbiens et de ses tables

-- Create locationsbiens database
CREATE DATABASE locationsbiens;
USE locationsbiens;

-- Create proprietaire table
CREATE TABLE IF NOT EXISTS proprietaire (
    id_proprietaire INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    domicile VARCHAR(200) NOT NULL,
    telephone VARCHAR(20),
    email VARCHAR(100)
);

-- Create locataire table
CREATE TABLE IF NOT EXISTS locataire (
    id_locataire INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    domicile VARCHAR(200),
    telephone VARCHAR(20),
    email VARCHAR(100)
);

-- Create bien table
CREATE TABLE IF NOT EXISTS bien (
    id_bien INT AUTO_INCREMENT PRIMARY KEY,
    type_bien ENUM('maison', 'appartement') NOT NULL,
    commune VARCHAR(100) NOT NULL,
    prix DECIMAL(10, 2) NOT NULL
      CHECK (prix > 0),
    superficie DECIMAL(8, 2) NOT NULL
      CHECK (superficie > 0),
    adresse VARCHAR(200),
    id_proprietaire INT NOT NULL,
    FOREIGN KEY (id_proprietaire) REFERENCES proprietaire(id_proprietaire) ON DELETE CASCADE
);

-- Create location table
CREATE TABLE IF NOT EXISTS location (
    id_location INT AUTO_INCREMENT PRIMARY KEY,
    id_bien INT NOT NULL,
    id_locataire INT NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE,
    loyer DECIMAL(10, 2)
      CHECK (loyer IS NULL OR loyer >= 0),
    statut VARCHAR(50),
    FOREIGN KEY (id_bien) REFERENCES bien(id_bien) ON DELETE CASCADE,
    FOREIGN KEY (id_locataire) REFERENCES locataire(id_locataire) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_bien_commune ON bien(commune);
CREATE INDEX idx_bien_prix ON bien(prix);
CREATE INDEX idx_bien_proprietaire ON bien(id_proprietaire);
CREATE INDEX idx_location_bien ON location(id_bien);
CREATE INDEX idx_location_locataire ON location(id_locataire);