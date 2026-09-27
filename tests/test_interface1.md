# Cas de test Interface 1

## Table des matières
1. Pré‑requis
2. Connexion
3. Visualisation
4. Ajout propriétaire
5. Suppression propriétaire (cascade)
6. Recherche (mono‑critère)
7. Recherche multi‑critères
8. Cas limites / validations
9. Checklist d’exécution

## 1. Pré‑requis
- Exécuter dans l’ordre: `sql/drop_db.sql`, `sql/create_db.sql`, `sql/insert_data.sql`, `sql/procedures.sql`.
- Vérifier paramètres connexion (host, port, user, password, database).
- S’assurer d’au moins un propriétaire avec biens et locations pour tester la cascade.

## 2. Connexion
ID: TC_CONNEXION_01  
Étapes:
1. Lancer l’interface.
2. Cliquer sur bouton Connecter.
Attendu:
- Étiquette état: “Connecté”.
- Navigation (barre) activée.
- Aucun message d’erreur.  
Validation SQL (optionnel): `SELECT 1;` (connexion établie sans exception).

## 3. Visualisation propriétaires
ID: TC_LIST_01  
Étapes:
1. Après connexion, observer la grille des propriétaires.
2. Utiliser barre navigation (suivant/précédent/premier/dernier).
Attendu:
- Données cohérentes avec `SELECT id_proprietaire, nom, domicile FROM proprietaire;`
- Passage d’un enregistrement à l’autre sans erreur.

## 4. Ajout propriétaire
ID: TC_ADD_OWNER_01  
Pré‑requis: Nom/domicile non existants.  
Étapes:
1. Saisir Nom = “TestNomX”, Domicile = “TestRue 1”.
2. Cliquer sur Ajout.
Attendu:
- Ligne ajoutée visible immédiatement.
- SQL: `SELECT * FROM proprietaire WHERE nom='TestNomX';` retourne 1 ligne.
- Champs obligatoires validés (pas de vide).

ID: TC_ADD_OWNER_02 (erreur champ vide)  
Étapes:
1. Laisser Nom vide, saisir Domicile.
2. Cliquer Ajout.
Attendu:
- Message d’erreur bloquant.
- Aucun nouvel enregistrement (`SELECT COUNT(*) ...` stable).

## 5. Suppression propriétaire (cascade)
ID: TC_DELETE_OWNER_01  
Pré‑requis: Propriétaire P avec au moins 1 Bien B et 1 Location L.  
Étapes:
1. Sélectionner P dans la grille.
2. Cliquer Suppression.
Attendu:
- P disparu de la grille.
- `SELECT * FROM bien WHERE id_proprietaire=P.id;` retourne 0 lignes.
- `SELECT * FROM location l JOIN bien b ON l.id_bien=b.id_bien WHERE b.id_proprietaire=P.id;` retourne 0 lignes.
- Aucune erreur d’intégrité.

ID: TC_DELETE_OWNER_02 (inexistant)  
Étapes:
1. Forcer suppression via ID inexistant (si interface permet).
Attendu:
- Message “Propriétaire introuvable” (ou équivalent).
- Tables inchangées.

## 6. Recherche (mono‑critère)
ID: TC_SEARCH_SINGLE_01  
Critère: commune = “Bruxelles”.  
Étapes:
1. Renseigner commune.
2. Cliquer Rechercher.
Attendu:
- Grille basse affiche uniquement biens où `commune='Bruxelles'`.
- Aucune exigence sur autres champs (partiels ignorés).  
Validation: `SELECT ... FROM bien WHERE commune='Bruxelles';` même comptage.

## 7. Recherche multi‑critères
ID: TC_SEARCH_MULTI_01  
Critères: nom propriétaire = “Dupont”; prix entre 500 et 1500; superficie ≥ 60.  
Étapes:
1. Saisir critères.
2. Cliquer Rechercher.
Attendu:
- Chaque ligne satisfait tous les critères.
- Ordre par nom, commune (si implémenté).  
Validation SQL équivalente avec WHERE combiné.

ID: TC_SEARCH_MULTI_02 (critères partiels)  
Étapes:
1. Retirer superficie (laisser vide).
2. Rechercher.
Attendu:
- Filtrage sur nom + plage prix uniquement (pas d’erreur).
- Superficie non filtrée.

## 8. Cas limites / validations
ID: TC_SEARCH_EMPTY_01  
Étapes:
1. Aucuns critères.
2. Rechercher.
Attendu:
- Retourne tous les biens (SELECT COUNT(*) identique).

ID: TC_INPUT_SANITIZE_01  
Étapes:
1. Entrer commune avec espaces/majuscules mixtes (“  bruXELLES  ”).
2. Rechercher.
Attendu:
- Normalisation appliquée (résultats Bruxelles); pas d’erreur SQL.

ID: TC_ERROR_HANDLING_01  
Étapes:
1. Déconnecter serveur MySQL (simuler).
2. Cliquer Connecter.
Attendu:
- Message d’erreur contrôlé; pas de crash interface.

## 9. Checklist d’exécution
- [ ] Connexion réussie.
- [ ] Navigation OK.
- [ ] Ajout propriétaire valide.
- [ ] Ajout propriétaire champ vide bloqué.
- [ ] Suppression propriétaire cascade confirmée.
- [ ] Suppression inexistant gérée.
- [ ] Recherche mono‑critère correcte.
- [ ] Recherche multi‑critères complète.
- [ ] Recherche partielle sans erreur.
- [ ] Recherche vide retourne tout.
- [ ] Normalisation commune testée.
- [ ] Gestion erreur connexion serveur testée.