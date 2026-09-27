-- Suppression/réinitialisation de la BDD

SET @old_foreign_key_checks := @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

DROP PROCEDURE IF EXISTS ajuster_prix_bien;

DROP DATABASE IF EXISTS locationsbiens;

SET FOREIGN_KEY_CHECKS = @old_foreign_key_checks;