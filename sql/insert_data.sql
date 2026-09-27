--- Insertion des données dans la base locationsbiens

USE locationsbiens;

INSERT INTO proprietaire (nom, domicile, telephone, email) VALUES
('Dupont', '123 Rue de Bruxelles, 1000 Bruxelles', NULL, NULL),
('Martin', '456 Avenue de Liège, 4000 Liège', NULL, NULL),
('Bernard', '789 Boulevard de Charleroi, 6000 Charleroi', NULL, NULL),
('Durand', '321 Rue de Namur, 5000 Namur', NULL, NULL),
('Lefevre', '654 Avenue de Mons, 7000 Mons', NULL, NULL),
('Moreau', '987 Boulevard de Bruges, 8000 Bruges', NULL, NULL),
('Simon', '147 Rue de Louvain, 3000 Louvain', NULL, NULL),
('Laurent', '258 Avenue de Gand, 9000 Gand', NULL, NULL),
('Michel', '369 Boulevard de Anvers, 2000 Anvers', NULL, NULL),
('Garcia', '159 Rue de Arlon, 6700 Arlon', NULL, NULL);

INSERT INTO locataire (nom, domicile, telephone, email) VALUES
('Petit', '12 Rue de la Loi, 1000 Bruxelles', NULL, NULL),
('Roux', '34 Avenue des Arts, 4000 Liège', NULL, NULL),
('Fournier', '56 Boulevard Tirou, 6000 Charleroi', NULL, NULL),
('Chevalier', '78 Rue de Fer, 5000 Namur', NULL, NULL),
('Blanc', '90 Avenue du Parc, 7000 Mons', NULL, NULL),
('Garnier', '21 Boulevard de la Reine, 8000 Bruges', NULL, NULL),
('Faure', '43 Rue de la Station, 3000 Louvain', NULL, NULL),
('Mercier', '65 Avenue de la Liberté, 9000 Gand', NULL, NULL),
('Dupuis', '87 Boulevard Léopold, 2000 Anvers', NULL, NULL),
('Lemoine', '19 Rue de Bastogne, 6700 Arlon', NULL, NULL);

INSERT INTO bien (type_bien, commune, prix, superficie, adresse, id_proprietaire) VALUES
('appartement', 'Bruxelles', 1200.00, 45.5, NULL, 1),
('maison', 'Liège', 1500.00, 85.0, NULL, 2),
('appartement', 'Charleroi', 900.00, 60.0, NULL, 3),
('maison', 'Namur', 1300.00, 75.0, NULL, 4),
('appartement', 'Mons', 1100.00, 50.0, NULL, 5),
('maison', 'Bruges', 1600.00, 90.0, NULL, 6),
('appartement', 'Louvain', 1000.00, 55.0, NULL, 7),
('maison', 'Gand', 1400.00, 80.0, NULL, 8),
('appartement', 'Anvers', 1250.00, 65.0, NULL, 9),
('maison', 'Arlon', 1350.00, 70.0, NULL, 10);

INSERT INTO location (id_bien, id_locataire, date_debut, date_fin, loyer, statut) VALUES
(1, 1, '2023-01-01', '2023-12-31', NULL, NULL),
(2, 2, '2023-02-01', '2023-11-30', NULL, NULL),
(3, 3, '2023-03-01', '2023-10-31', NULL, NULL),
(4, 4, '2023-04-01', '2023-09-30', NULL, NULL),
(5, 5, '2023-05-01', '2023-08-31', NULL, NULL),
(6, 6, '2023-06-01', '2023-07-31', NULL, NULL),
(7, 7, '2023-07-01', '2024-06-30', NULL, NULL),
(8, 8, '2023-08-01', '2024-05-31', NULL, NULL),
(9, 9, '2023-09-01', '2024-04-30', NULL, NULL),
(10, 10, '2023-10-01', '2024-03-31', NULL, NULL);