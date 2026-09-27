# locationsbiens (Lazarus + MySQL)

Ce projet est un TRAVAIL DE FIN DE MODULE DE PROJET DE DEVELOPPEMENT SGBD.

## 1. Aperçu
Application Lazarus (Free Pascal) de gestion de propriétaires, biens, locataires et locations soutenue par une base MySQL. Deux interfaces:
- Interface 1: CRUD propriétaires + recherche multi‑critères croisée propriétaires/biens.
- Interface 2: gestion des biens, filtrage par commune, ajustement des prix via procédure stockée, calcul du prix moyen.

## 2. Prérequis
- MySQL 9.6.0 avec utilisateur disposant des droits DDL/DML.
- MySQL ODBC 9.6.0 Driver (required for ODBC connection).
- Lazarus IDE 4.0.0 (SQLDB + ODBCConn package).
- FPC 3.2.2 (bundled).
- Outils optionnels: mysql CLI, lazbuild, VS Code (+ tasks.json).

## 3. Structure synthétique
```
pr_dev_sgbd/
  pascal/ (units .pas/.lfm, main.lpr, main.lpi, utils, db_connection)
  sql/ (create_db.sql, drop_db.sql, insert_data.sql, procedures.sql)
  tests/ (jeux_essai.sql, test_interface1.md, test_interface2.md)
  docs/ (documentation.md, contraintes.md, rapport.md, structure.md)
  .vscode/ (tasks.json exemple)
  README.md
```

## 4. Mise en place base de données
Exécuter (dans l’ordre) :
```bash
mysql -u root -p < sql/drop_db.sql
mysql -u root -p < sql/create_db.sql
mysql -u root -p < sql/insert_data.sql
mysql -u root -p < sql/procedures.sql
```

### Configuration ODBC (Windows)
1. Ouvrir ODBC Data Source Administrator: `Win+R` → `odbcad32.exe` (64-bit)
2. Aller à l'onglet **System DSN** → Add → Sélectionner `MySQL ODBC 9.6.0 Unicode Driver`
3. Créer un DSN nommé `MySQL92` pointant vers la base `locationsbiens`
4. Configurer: User=`root`, Password=(vide ou selon configuration)
5. Tester la connexion via l'interface ODBC avant de lancer l'application

Paramètres par défaut :
- Driver: MySQL ODBC 9.6.0 Unicode Driver
- DSN: MySQL92
- User: root
- Password: (vide)

## 5. Compilation & exécution
### Lazarus IDE
1. Ouvrir pascal/main.lpi
2. Vérifier packages SQLDB/ODBCConn
3. F9 (build + run)

### Ligne de commande
Windows (PowerShell):
```powershell
& "C:\lazarus\lazbuild.exe" --build-all pascal\main.lpi
```
Linux/macOS:
```bash
lazbuild --build-all pascal/main.lpi
```

## 6. Contraintes de données (résumé)
- bien.type_bien ∈ {maison, appartement}
- bien.prix > 0 ; bien.superficie > 0
- location.loyer ≥ 0 ou NULL
- date_fin NULL si location statut 'en_cours'
- ON DELETE CASCADE: Proprietaire→Bien, Bien→Location, Locataire→Location
- Indexes: bien(commune), bien(prix), bien(id_proprietaire), location(id_bien), location(id_locataire)
- ≥ 10 enregistrements par table (jeu de test)

## 7. Interfaces (résumé fonctionnel)
### Interface 1
- Grille propriétaires + navigation (CRUD persistant)
- Ajout / suppression (cascade sur biens & locations)
- Recherche multi‑critères (nom, domicile, commune, prix min/max, superficie min/max)

### Interface 2
- Grille biens + filtrage par commune (SELECT DISTINCT)
- Affichage détails d’un bien
- Ajustement prix via procédure stockée (delta signé)
- Recalcul automatique du prix moyen
- Rafraîchissement dynamique des communes

## 8. Procédure stockée
Spécification unifiée (augmentation ou diminution via delta signé) :
```sql
CALL maj_prix_bien(<id_bien>, <percent_delta>);
-- percent_delta = 10  => +10%
-- percent_delta = -5  => -5%
```
Règles:
- Vérifie existence du bien
- Calcule nouveau_prix = prix * (1 + percent_delta/100)
- Refuse nouveau_prix ≤ 0 (rollback)
- Retourne le nouveau prix (SELECT) 

## 9. Tests
Scripts:
```bash
mysql -u root -p < tests/jeux_essai.sql
```
Manuels:
- Interface 1: [tests/test_interface1.md](tests/test_interface1.md)
- Interface 2:  [tests/test_interface2.md](tests/test_interface2.md)

Checklist essentielle:
- Connexion / CRUD propriétaire / cascade suppression
- Recherche multi‑critères (critères partiels acceptés)
- Filtrage commune + refresh distinct
- Ajustement prix (positif, négatif, échec sur delta extrême)
- Prix moyen cohérent

## 10. Développement & bonnes pratiques
- SQL paramétré uniquement (pas de concaténation entrées utilisateur)
- Transactions courtes (Commit/Rollback explicites)
- utf8mb4 pour compatibilité (accentuation)
- Parsing percent/montant via utils (locale‑agnostic)
- Rafraîchir communes après modifications biens
- Logger erreurs critiques (sans exposer mots de passe)

Workflow:
1. Modifier .pas/.lfm
2. Compiler (IDE ou lazbuild)
3. Mettre à jour tests
4. Exécuter scripts de validation

## 11. Conventions
- Fichiers Pascal: snake_case (db_connection.pas)
- Types/classes: PascalCase (TDbManager)
- Tables: singular (Bien, Proprietaire, Locataire, Location)
- PK: id_<entite>
- Procédures: verbe_entite (maj_prix_bien)
- Documents tests: test_interfaceX.md

## 13. Licence & Auteur
Projet académique locationsbiens (usage pédagogique).
Privé — pas ouvert aux contributions externes. Propriété de l'auteur.  
Conçu avec ❤️ par [PG](https://patrickgagli.github.io/pgdigital/)







