-- Procédures stockées (ex: maj prix)
USE locationsbiens;

DROP PROCEDURE IF EXISTS ajuster_prix_bien;

DELIMITER //

CREATE PROCEDURE ajuster_prix_bien(
  IN p_bien_id INT,
  IN p_aug_percent DOUBLE,
  IN p_dim_percent DOUBLE,
  OUT p_prix_moyen DECIMAL(10,2)
)
BEGIN
  DECLARE v_aug_factor DOUBLE DEFAULT 1;
  DECLARE v_dim_factor DOUBLE DEFAULT 1;

  SET v_aug_factor := 1 + COALESCE(p_aug_percent, 0) / 100;
  SET v_dim_factor := 1 - COALESCE(p_dim_percent, 0) / 100;

  START TRANSACTION;
    UPDATE bien
    SET prix = GREATEST(0, prix * v_aug_factor * v_dim_factor)
    WHERE id_bien = p_bien_id;

    IF ROW_COUNT() = 0 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bien introuvable pour l''ajustement de prix.';
    END IF;

    SELECT ROUND(AVG(prix), 2) INTO p_prix_moyen FROM bien;
  COMMIT;
END //

DELIMITER ;