# Cas de test Interface 2

## Table des matières
1. Pré‑requis
2. Connexion et chargement
3. Navigation de base
4. Filtre par commune
5. Rafraîchissement des communes
6. Affichage des détails
7. Ajustement de prix (procédure stockée)
8. Gestion des erreurs procédure
9. Validation post‑mise à jour
10. Nettoyage
11. Checklist d’exécution

## 1. Pré‑requis
ID: TC_PREREQ_01  
- Exécuter dans l’ordre: drop_db.sql, create_db.sql, insert_data.sql, procedures.sql.  
- Vérifier paramètres de connexion (host, port, user, password, database).  
- Garantir au moins: 1 bien par plusieurs communes pour tester filtrage.

## 2. Connexion et chargement
ID: TC_CONN_01  
Étapes:
1. Lancer l’interface.
2. Cliquer sur Connecter.
Attendu:
- Libellé statut = “Connecté”.
- Grille Bien peuplée.
- Barre de navigation active.
Validation SQL: `SELECT COUNT(*) FROM bien;` > 0.

## 3. Navigation de base
ID: TC_NAV_01  
Étapes:
1. Boutons premier, suivant, précédent, dernier.
Attendu:
- Changement d’enregistrement reflété dans les zones de détails (id, commune, prix, superficie).  
- Pas d’erreur ni blocage.
Validation: ID affiché correspond à celui en base (`SELECT id_bien FROM bien ORDER BY id_bien LIMIT ...`).

## 4. Filtre par commune
ID: TC_FILTER_01  
Étapes:
1. Sélectionner “Bruxelles” dans la liste déroulante.
Attendu:
- Grille affiche uniquement `bien.commune='Bruxelles'`.
Validation: `SELECT COUNT(*) FROM bien WHERE commune='Bruxelles';` = nombre lignes grille.

ID: TC_FILTER_02  
Étapes:
1. Choisir “(Tous)” / valeur vide.
Attendu:
- Retour à l’ensemble des enregistrements.
Validation: comptage total initial restauré.

## 5. Rafraîchissement des communes
ID: TC_COMMUNE_REFRESH_01  
Étapes:
1. Insérer via SQL un bien avec commune nouvelle “Namur-Sud”.
2. Cliquer sur Rafraîchir communes (ou reconnecter).
Attendu:
- “Namur-Sud” apparaît dans la liste.
Validation: `SELECT DISTINCT commune FROM bien;` contient “Namur-Sud”.

ID: TC_COMMUNE_REFRESH_02  
Étapes:
1. Supprimer le bien “Namur-Sud”.
2. Rafraîchir.
Attendu:
- “Namur-Sud” retirée de la liste.
Validation: `SELECT DISTINCT commune FROM bien WHERE commune='Namur-Sud';` retourne 0.

## 6. Affichage des détails
ID: TC_DETAILS_01  
Étapes:
1. Sélectionner un enregistrement dans la grille.
2. Cliquer sur Afficher (si bouton prévu) ou observer binding auto.
Attendu:
- Zones: type_bien, commune, prix, superficie, adresse renseignées correctement.

## 7. Ajustement de prix (procédure stockée)
Procédure attendue: `maj_prix_bien(p_id_bien INT, p_percent_delta DECIMAL)` (delta signé).

ID: TC_PRICE_UP_01  
Étapes:
1. Saisir id_bien existant, delta = 10 (augmentation 10%).
2. Cliquer Ajuster.
Attendu:
- Nouveau prix = ancien_prix * 1.10 (arrondi selon DECIMAL).
- Prix moyen recalculé (champ mis à jour).
Validation: `SELECT prix FROM bien WHERE id_bien=...;`

ID: TC_PRICE_DOWN_01  
Étapes:
1. Delta = -5 (diminution 5%).
Attendu:
- Nouveau prix = ancien_prix * 0.95 (>0).
- Mise à jour immédiate de la grille.

ID: TC_PRICE_ZERO_DELTA  
Étapes:
1. Delta = 0.
Attendu:
- Prix inchangé; aucune erreur.

## 8. Gestion des erreurs procédure
ID: TC_PRICE_ERR_ID  
Étapes:
1. id_bien inexistant, delta = 10.
Attendu:
- Message d’erreur contrôlé (“Bien introuvable”); aucun changement global.

ID: TC_PRICE_ERR_NEGATIVE  
Étapes:
1. Choisir un bien avec prix faible (ex. 100).
2. Delta = -200 (→ prix théorique négatif).
Attendu:
- Procédure annule opération (exception), prix inchangé.
Validation: `SELECT prix FROM bien WHERE id_bien=...;` reste identique.

## 9. Validation post‑mise à jour
ID: TC_POST_UPDATE_NAV  
Étapes:
1. Après ajustement, utiliser navigation.
Attendu:
- Aucune transaction bloquante; prix modifié persistant.
ID: TC_POST_AVG_REFRESH  
Étapes:
1. Comparer champ prix moyen affiché avec `SELECT ROUND(AVG(prix),2) FROM bien;`.
Attendu:
- Valeurs identiques.

## 10. Nettoyage
ID: TC_CLEANUP_01  
Étapes:
1. Réexécuter ajustement inverse (ex: delta = -10 si +10 appliqué avant) pour restaurer prix.
Attendu:
- Prix ramené proche de la valeur initiale (écart lié aux arrondis possible).

## 11. Checklist d’exécution
- [ ] Connexion réussie.
- [ ] Navigation basique OK.
- [ ] Filtre commune fonctionne.
- [ ] Rafraîchissement liste communes (ajout/suppression).
- [ ] Détails d’un bien corrects.
- [ ] Augmentation prix (delta positif).
- [ ] Diminution prix (delta négatif).
- [ ] Delta zéro stable.
- [ ] Erreur ID inexistant gérée.
- [ ] Erreur delta trop négatif gérée (pas de prix <=0).
- [ ] Navigation après ajustements OK.
- [ ] Prix moyen conforme à calcul SQL.
- [ ] Nettoyage effectué.