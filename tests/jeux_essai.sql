-- Scénarios de test SQL

-- Préparation ---------------------------------------------------------------
SOURCE ../sql/drop_db.sql;
SOURCE ../sql/create_db.sql;
SOURCE ../sql/insert_data.sql;
SOURCE ../sql/procedures.sql;

-- Vérification contenu initial ---------------------------------------------
SELECT COUNT(*) AS proprietaires FROM locationsbiens.proprietaire;
SELECT COUNT(*) AS locataires FROM locationsbiens.locataire;
SELECT COUNT(*) AS biens FROM locationsbiens.bien;
SELECT COUNT(*) AS locations FROM locationsbiens.location;

-- Test ajout propriétaire --------------------------------------------------
INSERT INTO locationsbiens.proprietaire (nom, domicile, telephone, email)
VALUES ('Testeur', '1 Rue du Test, 1000 Bruxelles', '0102030405', 'testeur@example.com');
SELECT * FROM locationsbiens.proprietaire WHERE nom = 'Testeur';

-- Test suppression propriétaire (cascade) ---------------------------------
DELETE FROM locationsbiens.proprietaire WHERE id_proprietaire = 1;
SELECT EXISTS(
  SELECT 1 FROM locationsbiens.bien WHERE id_proprietaire = 1
) AS biens_orphelins;
SELECT EXISTS(
  SELECT 1 FROM locationsbiens.location l
  JOIN locationsbiens.bien b ON b.id_bien = l.id_bien
  WHERE b.id_proprietaire = 1
) AS locations_orphelines;

-- Ré-injection pour conserver jeu complet ---------------------------------
INSERT INTO locationsbiens.proprietaire (id_proprietaire, nom, domicile)
VALUES (1, 'Dupont', '123 Rue de Bruxelles, 1000 Bruxelles');
UPDATE locationsbiens.bien SET id_proprietaire = 1 WHERE id_bien = 1;
INSERT INTO locationsbiens.location (id_bien, id_locataire, date_debut)
VALUES (1, 1, '2024-01-01');
UPDATE locationsbiens.location SET loyer = 1200 WHERE id_location = LAST_INSERT_ID();

-- Test filtre commune ------------------------------------------------------
SELECT id_bien, commune FROM locationsbiens.bien WHERE commune = 'Bruxelles';

-- Test procédure ajustement prix ------------------------------------------
SET @prixMoyen := NULL;
CALL locationsbiens.ajuster_prix_bien(2, 10, 5, @prixMoyen);
SELECT prix FROM locationsbiens.bien WHERE id_bien = 2;
SELECT @prixMoyen AS prix_moyen_post_ajustement;

-- Test protection procédure (bien inexistant) ------------------------------
DELIMITER //

CREATE PROCEDURE test_erreur_ajustement()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT 'Erreur attendue ajustement' AS message;
  END;
  CALL locationsbiens.ajuster_prix_bien(999, 5, 0, @prixMoyen);
END //

CREATE PROCEDURE test_prix_negatif()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT 'Erreur attendue prix négatif' AS message;
  END;
  INSERT INTO locationsbiens.bien (type_bien, commune, prix, superficie, adresse, id_proprietaire)
  VALUES ('appartement', 'TestVille', -100, 40, 'Rue du Test 1', 1);
  SELECT 'Insertion prix négatif non bloquée' AS message;
END //

DELIMITER ;

CALL test_erreur_ajustement();
CALL test_prix_negatif();
DROP PROCEDURE test_erreur_ajustement;
DROP PROCEDURE test_prix_negatif;

-- Test moyenne prix --------------------------------------------------------
SELECT ROUND(AVG(prix), 2) AS verification_prix_moyen FROM locationsbiens.bien;

-- Nettoyage facultatif -----------------------------------------------------
-- CALL locationsbiens.ajuster_prix_bien(2, -10, 0, @prixMoyen); -- Example rollback test