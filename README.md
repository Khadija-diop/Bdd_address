# 📘 Projet Base de Données Adresses 

Ce projet implémente une base de données relationnelle normalisée destinée à stocker, structurer et analyser un jeu d'adresses françaises (communes, voies, adresses, positions GPS et parcelles cadastrales). Il suit une modélisation **MERISE** complète (MCD → MLD → MPD) et un déploiement via **PostgreSQL + Docker Compose**.

---

## 📋 Table des matières

1. [Prérequis](#-prérequis)
2. [Installation rapide](#-installation-rapide)
3. [Modèle Conceptuel de Données (MCD)](#-modèle-conceptuel-de-données-mcd)
4. [Structure physique (MPD / SQL)](#-structure-physique-mpd--sql)
5. [Déploiement via Docker Compose](#-déploiement-via-docker-compose)
6. [Connexion avec DBeaver](#-connexion-avec-dbeaver)
7. [Importation des données](#-importation-des-données-brutes)
8. [Scripts Insertion des données](#-scripts---insertion-des-données)
9. [Nettoyage et qualité des données](#-nettoyage-et-qualité-des-données)
10. [Triggers et validation automatique](#-triggers-et-validation-automatique)
11. [Index et Optimisation](#-index-et-optimisation)
12. [Requêtes SQL principales](#-requêtes-sql-principales)
13. [Jeux de test & validations](#-jeux-de-test--validations)
14. [Arborescence du projet](#-arborescence-du-projet)

---

## 🔧 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- [PostgreSQL](https://www.postgresql.org/download/) (version 17 ou supérieure)
- [Docker Compose](https://docs.docker.com/compose/install/) 
- [DBeaver](https://dbeaver.io/download/) (optionnel, pour l'interface graphique)
- Un client PostgreSQL (psql) ou DBeaver

Vérifiez vos installations :


---

## 🏗️ Modèle Conceptuel de Données (MCD)

Le MCD MERISE se compose de 5 entités principales :

### **1. Commune**

| Attribut | Type | Description |
|----------|------|-------------|
| `code_insee` | PK | Code INSEE unique de la commune |
| `nom_commune` | | Nom de la commune |
| `code_postal` | | Code postal |
| `certification_commune` | | Statut de certification |

### **2. Voie**

| Attribut | Type | Description |
|----------|------|-------------|
| `id_fantoir` | PK | Identifiant FANTOIR unique |
| `nom_voie` | | Nom de la voie |
| `nom_afnor` | | Nom normalisé AFNOR |
| `source_nom_voie` | | Source du nom de voie |

### **3. Adresse**

| Attribut | Type | Description |
|----------|------|-------------|
| `id` | PK | Identifiant unique de l'adresse |
| `numero` | | Numéro dans la voie |
| `rep` | | Complément (bis, ter, etc.) |
| `libelle_acheminement` | | Libellé d'acheminement postal |
| `code_postal` | | Code postal |
| `code_insee` | FK | Référence à Commune |
| `id_fantoir` | FK | Référence à Voie |

### **4. Position**

| Attribut | Type | Description |
|----------|------|-------------|
| `id_position` | PK | Identifiant unique de la position |
| `x, y` | | Coordonnées Lambert |
| `lat, lon` | | Coordonnées GPS (latitude, longitude) |
| `type_position` | | Type de positionnement |
| `source_position` | | Source des coordonnées |
| `date_certification` | | Date de certification |
| `id` | FK | Référence à Adresse |

### **5. CadastreParcelle**

| Attribut | Type | Description |
|----------|------|-------------|
| `id_parcelle` | PK | Identifiant unique de la parcelle |
| `code_parcelle` | | Code parcellaire |
| `section` | | Section cadastrale |
| `numero` | | Numéro de parcelle |
| `surface` | | Surface en m² |
| `id` | FK | Référence à Adresse |

### **Associations du MCD**

- **Appartenir** : Voie → Adresse (1,n) / Adresse (0,n)
- **Rattacher** : Commune → Adresse (1,n)
- **Avoir** : Adresse → Position (1,1)
- **Posséder** : Adresse → CadastreParcelle (0,n)

> 📎 *L'image du MCD, MLD et MPD sont fournies dans le dossier `/docs` du projet.*

---

## 🧱 Structure physique (MPD / SQL)

Le MPD PostgreSQL a été généré à partir du MLD et correspond aux tables suivantes :

- `municipality` (communes)
- `road` (voies)
- `address` (adresses)
- `address_position` (positions GPS)
- `cadastral_plot` (parcelles cadastrales)

Toutes les clés primaires et étrangères respectent les cardinalités MERISE.

➡️ Le fichier `scripts/Create_table.sql` contient la création complète des tables avec :
- Définition des tables
- Contraintes de clés primaires et étrangères
- Types de données optimisés
- Contraintes de validation

---

---

### **Étape 1 : Créer la table intermédiaire**
## 📥 Importation des données brutes

Les données proviennent du fichier **`adresses-07.csv`** qui se trouve dans le dossier `data/`.

Avant d'importer, créez une table intermédiaire `adresses` dans votre base de données PostgreSQL.

### **Étape 2 : Importer le fichier CSV**

#### **Méthode : Via DBeaver**

1. Connectez-vous à la base de données `address`
2. Clic droit sur le schéma `public` → `Create` → `Table`
3. Créez une table nommée `adresses` avec les colonnes correspondant à votre CSV
4. Clic droit sur la table `adresses` → `Import Data`
5. Sélectionnez le fichier `data/adresses-07.csv`
6. Configurez le mapping des colonnes
7. Lancez l'import

> 📝 **Note** : Le fichier CSV contient les données brutes qui seront ensuite transformées et insérées dans les tables normalisées.

---

## 🔄 Scripts: (Insertion + Nettoyage + Validation)

### **Ordre d'exécution des scripts**

⚠️ **IMPORTANT** : Les scripts doivent être exécutés dans l'ordre suivant pour garantir la cohérence des données :
#### **Scripts d'initialisation (à exécuter dans l'ordre)**
1. **`Create_Table.sql`** - Création de la structure de la base de données (tables, contraintes)
2. **`Insertion.sql`** - Insertion des données depuis la table intermédiaire `adresses` vers les tables normalisées
3. **`Double.sql`** - Détection et suppression des doublons
4. **`Empty_column_cleaning.sql`** - Nettoyage des colonnes vides (optionnel)
5. **`Analysis_Optimization.sql`** - Création des index pour optimiser les performances
#### **Scripts de requêtes et analyses (à exécuter après l'initialisation)**
- **`Consultation_Requests.sql`** - Requêtes de consultation et recherche d'adresses
- **`Analysis.sql`** - Requêtes d'analyse et statistiques
- **`Aggregation_Analysis1.sql`** - Requêtes d'agrégation et analyses avancées
- **`Crud.sql`** - Exemples d'opérations CRUD (Create, Read, Update, Delete)
6. **`Trigger.sql`** 

>  **Attention** : Les triggers doivent être créés **en dernier** car ils valident les données lors des insertions. Si vous les créez avant l'insertion des données, certaines insertions pourraient être bloquées par les validations.


### **Détails des scripts**

Le script `scripts/Insertion.sql` permet d'insérer les données depuis la table intermédiaire vers les tables normalisées.

### **Ordre d'insertion**

1. **Communes** : Insertion avec `ON CONFLICT DO NOTHING` pour éviter les doublons
2. **Voies** : Insertion avec gestion des conflits sur `fantoir_id`
3. **Adresses** : Insertion avec jointure sur `road_id` pour récupérer l'identifiant de la voie
4. **Positions GPS** : Insertion des coordonnées depuis la table source
5. **Parcelles cadastrales** : Insertion avec troncature à 255 caractères

### **Gestion des doublons lors de l'insertion**

- **Communes** : Unicité via `insee_code` avec `ON CONFLICT DO NOTHING`
- **Voies** : Unicité via `fantoir_id` avec gestion des conflits
- **Adresses** : Matching automatique de `road_id` lors de l'insertion

### **Validation des données GPS**

## 🧹 Nettoyage et qualité des données

Après l'insertion des données, plusieurs opérations de nettoyage ont été effectuées pour garantir la qualité des données.

### **1. Suppression des doublons**

Le script `scripts/Double.sql` permet de détecter et supprimer les adresses en double :

- **Détection** : Identification des doublons basés sur `number`, `road_id`, `postal_code`, `insee_code`
- **Suppression en cascade** : 
  - Suppression des `address_position` liées aux doublons
  - Suppression des `cadastral_plot` liées aux doublons
  - Suppression des adresses dupliquées (conservation de la première occurrence)
- **Vérification** : Contrôle des codes postaux et des noms de communes après suppression

>  **Résultat** : Tous les doublons ont été supprimés après vérification manuelle.

### **2. Suppression des adresses incohérentes**

Le script `scripts/Consultation_Requests.sql` permet de détecter les incohérences :

- **Adresses sans code postal** : Détection des adresses avec `postal_code` NULL ou vide alors que la commune existe
- **Vérification de l'intégrité référentielle** : 
  - Adresses sans voie associée
  - Adresses sans commune associée
  - Incohérences entre code postal de l'adresse et code postal de la commune

> **Résultat** : Toutes les adresses incohérentes ont été identifiées et supprimées.

### **3. Nettoyage des colonnes vides**

Le script `scripts/Empty_column_cleaning.sql` permet de :
- Détecter les colonnes entièrement vides (toutes valeurs NULL)
- Supprimer automatiquement ces colonnes vides si nécessaire

---

## ⚙️ Triggers et validation automatique

Le script `scripts/Trigger.sql` crée des triggers pour valider automatiquement les données.

### **Validation des adresses**

- **Cohérence code postal ↔ commune** : Vérifie que le code postal correspond à la commune
- **Timestamps automatiques** : `created_at` et `updated_at` sont mis à jour automatiquement
- **Intégrité référentielle** : Vérifie l'existence des voies et communes référencées

### **Validation des positions GPS**

- **Coordonnées obligatoires** : `lat` et `lon` doivent être renseignées
- **Bornes départementales** : Validation que les coordonnées sont dans les limites du département (exemple : Paris)

---

## 📊 Index et Optimisation

Le script `scripts/Analysis_Optimization.sql` crée des index pour optimiser les performances.

### **Index sur les clés étrangères**

```sql
CREATE INDEX idx_address_insee ON address(insee_code);
CREATE INDEX idx_address_road_id ON address(road_id);
CREATE INDEX idx_address_position_address ON address_position(address_id);
```

### **Index de recherche textuelle (Full-Text Search)**

```sql
CREATE INDEX idx_road_name_gin ON road 
USING gin (to_tsvector('french', road_name));
```

### **Index sur les colonnes de recherche fréquentes**

```sql
CREATE INDEX idx_address_postal_code ON address(postal_code);
CREATE INDEX idx_municipality_name ON municipality(municipality_name);
CREATE INDEX idx_road_name ON road(road_name);
```

---

## 🔍 Requêtes SQL principales

### **Statistiques générales**

```sql
-- Nombre total d'adresses
SELECT COUNT(*) AS total_adresses FROM address;

-- Nombre d'adresses par commune
SELECT 
  m.municipality_name,
  COUNT(*) AS nombre_adresses
FROM address a
JOIN municipality m ON m.insee_code = a.insee_code
GROUP BY m.municipality_name
ORDER BY nombre_adresses DESC;
```

### **Requêtes de consultation et recherche**

Le script `scripts/Consultation_Requests.sql` contient plusieurs requêtes de recherche et consultation :

- **Recherche d'adresses par commune** : Récupération de toutes les adresses d'une commune spécifique (ex: Montpezat-sous-Bauzon) avec leurs détails complets
- **Comptage d'adresses par commune et voie** : Statistiques sur le nombre d'adresses pour chaque couple commune/voie
- **Liste des communes distinctes** : Obtention de la liste unique de toutes les communes présentes dans la base
- **Recherche de voies contenant un mot-clé** : Recherche de toutes les adresses situées dans des voies contenant un terme spécifique (ex: "Boulevard")
- **Détection d'incohérences** : Identification des adresses sans code postal alors que la commune existe (pour audit de qualité)

### **Analyses et statistiques**

Le script `scripts/Analysis.sql` contient des requêtes d'analyse et de statistiques :

- **Statistiques par commune** : Nombre total d'adresses par commune avec calcul de la moyenne d'adresses par voie (utilisation de fonctions de fenêtre)
- **Top 10 des communes** : Classement des communes ayant le plus d'adresses, triées par ordre décroissant
- **Audit de qualité des données** : Analyse du taux de remplissage des colonnes importantes (number, road_id, postal_code, insee_code) avec calcul de pourcentages pour identifier les données manquantes

### **Agrégations et analyses avancées**

Le script `scripts/Aggregation_Analysis1.sql` contient :

- Recherche d'adresses par commune spécifique (ex: Villeneuve-de-Berg)
- Modification de structure de table (changement de type de colonne)
- Requêtes avec jointures complexes pour obtenir des informations complètes sur les adresses

---
## 🧪 Jeux de test & validations

### **Opérations CRUD**

Le script `scripts/Crud.sql` contient des exemples complets d'opérations CRUD :

- **INSERT** : Insertion de communes, voies, adresses et positions avec gestion des conflits
- **UPDATE** : Mise à jour de données (ex: modification du nom d'une voie via une adresse)
- **DELETE** : Suppression conditionnelle en cascade (ex: adresses avec numéro invalide)
- **SELECT** : Vérifications finales pour valider les opérations

Le script `scripts/Trigger.sql` contient des tests de validation :

- Test d'insertion valide
- Test d'insertion invalide (GPS hors bornes)
- Vérification de l'intégrité référentielle


## 🐳 Docker Compose

### **Configuration docker-compose.yml**

```yaml
services:
  bdaddress:
    image: postgres
    environment:
      POSTGRES_PASSWORD: root0987
      POSTGRES_DB: address
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### **Commandes utiles**

#### Démarrer les services
```bash
docker-compose up 
```

#### Arrêter et supprimer les conteneurs (conserve les volumes)
```bash
docker-compose down
```


---

## 📂 Arborescence du projet

```
📦 projet-bdd
 ├── 📁 data
 │     └── adresses-07.csv              # Données sources CSV
 ├── 📁 docs
 │     ├── mcd.png                      # Diagramme MCD MERISE
 │     ├── mld.png                      # Diagramme MLD MERISE
 │     └── mpd.png                      # Diagramme MPD MERISE
 ├── 📁 scripts
 │     ├── Create_Table.sql             # Création des tables (MPD)
 │     ├── Insertion.sql                # Scripts d'insertion ETL
 │     ├── Double.sql                    # Détection et suppression des doublons
 │     ├── Consultation_Requests.sql     # Requêtes de consultation et recherche
 │     ├── Analysis.sql                  # Requêtes d'analyse et statistiques
 │     ├── Analysis_Optimization.sql    # Création des index et optimisation
 │     ├── Trigger.sql                   # Triggers de validation
 │     ├── Crud.sql                      # Exemples d'opérations CRUD
 │     ├── Aggregation_Analysis1.sql     # Requêtes d'agrégation
 │     └── Empty_column_cleaning.sql    # Nettoyage des colonnes vides
 ├── docker-compose.yml                 # Configuration Docker
 └── README.md                          # Ce fichier
```

---

## 🧹 Scripts 

# Réexécuter les scripts SQL dans l'ordre :
# 1. Create_Table.sql
# 2. Insertion.sql
# 3. Double.sql (nettoyage des doublons)
# 4. Empty_column_cleaning.sql (nettoyage optionnel)
# 5. Analysis_Optimization.sql (création des index)
# 6. Trigger.sql
```

---

## 🏁 Conclusion

Ce projet constitue une base solide et optimisée pour gérer un ensemble complexe d'adresses françaises. Il inclut :

✅ Une modélisation MERISE complète (MCD → MLD → MPD)  
✅ Un MPD entièrement fonctionnel avec PostgreSQL  
✅ Un déploiement Docker reproductible et portable  
✅ Des triggers de validation automatiques  
✅ Des index optimisés pour les performances  
✅ Des scripts pour l'importation et le nettoyage  
✅ **Nettoyage complet des doublons après vérification**  
✅ **Suppression des adresses incohérentes**  
✅ Une documentation complète  

### **Vérification de l'intégrité référentielle**

Ce projet peut servir de fondation pour :

- 🗺️ **SIG (Systèmes d'Information Géographique)**
- 🌐 **API d'adresses** (géocodage, reverse géocodage)
- 📍 **Applications de géolocalisation**
- 🔗 **Interfaçage avec OpenStreetMap ou data.gouv.fr**
- 📊 **Analyses statistiques territoriales**

---

💡 *Ce README est évolutif.*

---

**Auteur** : Khady Diop
