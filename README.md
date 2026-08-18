# SplitCloud — Gestion de dépenses partagées (Serverless AWS)

Petite API serverless permettant à un groupe d'amis de suivre leurs dépenses communes et de calculer automatiquement qui doit combien à qui, inspirée d'applications comme Splitwise ou Tricount.

Projet réalisé dans le cadre de ma formation Cloud, pour mettre en pratique une architecture serverless complète sur AWS.

##  Objectif du projet

Construire une API REST 100% serverless, en respectant les bonnes pratiques d'architecture cloud (séparation des responsabilités, permissions IAM restreintes, coûts maîtrisés via le Free Tier AWS).

##  Architecture

```
Client (HTTP)
     │
     ▼
API Gateway (API HTTP)
     │
     ├── POST /groupes        → Lambda: creer-groupe
     ├── POST /depenses       → Lambda: ajouter-depense
     ├── GET  /depenses       → Lambda: lister-depenses
     └── GET  /soldes         → Lambda: calculer-soldes
                                       │
                                       ▼
                              DynamoDB (2 tables)
                              ├── Groupes
                              └── depenses
```

##  Services AWS utilisés

| Service | Rôle |
|---|---|
| **API Gateway** (API HTTP) | Point d'entrée HTTP, expose les routes de l'API |
| **AWS Lambda** (Python 3.13) | Logique métier — 4 fonctions indépendantes |
| **Amazon DynamoDB** | Stockage NoSQL des groupes et des dépenses |
| **IAM** | Permissions entre Lambda et DynamoDB |
| **CloudWatch** | Logs et monitoring des exécutions Lambda |
| **AWS Budgets** | Alerte de facturation pour rester dans le Free Tier |

##  Modèle de données

### Table `Groupes`
- Clé de partition : `groupe_id` (String, UUID généré à la création)
- Attributs : `nom`, `membres` (liste de noms)

### Table `depenses`
- Clé de partition : `groupe_id` (String)
- Clé de tri : `depense-SortKey` (String, UUID)
- Attributs : `payeur`, `montant`, `description`

> La clé de tri permet de regrouper toutes les dépenses d'un même groupe et de les récupérer en une seule requête (`Query`), sans avoir à scanner toute la table.

## 🔌 Fonctions Lambda

### `creer-groupe`
Crée un nouveau groupe avec une liste de membres. Génère un `groupe_id` unique (UUID).

**Entrée** : `{ "nom": "...", "membres": ["...", "..."] }`
**Sortie** : `{ "groupe_id": "...", "message": "Groupe créé" }`

### `ajouter-depense`
Enregistre une dépense payée par un membre du groupe.

**Entrée** : `{ "groupe_id": "...", "payeur": "...", "montant": ..., "description": "..." }`
**Sortie** : `{ "depense_id": "...", "message": "Dépense ajoutée" }`

### `lister-depenses`
Récupère toutes les dépenses d'un groupe donné, via une requête `Query` DynamoDB (par `groupe_id`).

**Entrée** : `?groupe_id=...`
**Sortie** : liste des dépenses du groupe

### `calculer-soldes`
Calcule, pour chaque membre du groupe :
1. Le total qu'il a payé
2. La part équitable qui lui revenait (total général ÷ nombre de membres)
3. Son solde (payé − part équitable) : positif = on lui doit de l'argent, négatif = il doit de l'argent au groupe

**Entrée** : `?groupe_id=...`
**Sortie** : `{ "total_general": ..., "part_equitable": ..., "soldes": { "Marie": 45.0, "Tom": -15.0, ... } }`

##  Sécurité & permissions

Chaque fonction Lambda dispose d'un rôle IAM d'exécution avec les permissions nécessaires pour lire/écrire dans DynamoDB (`AmazonDynamoDBFullAccess` pour cette version de démonstration — en production, on utiliserait une politique restreinte limitée aux actions et tables strictement nécessaires, principe du moindre privilège).

##  Maîtrise des coûts (FinOps)

Architecture pensée pour rester dans le Free Tier AWS :
- Lambda : gratuit à vie jusqu'à 1M requêtes/mois
- DynamoDB : mode On-Demand, gratuit à vie jusqu'à 25 Go
- API Gateway : gratuit 12 mois jusqu'à 1M appels/mois

Une alerte de budget (AWS Budgets) est configurée pour notifier en cas de dépassement.

##  Roadmap

- [x] API CRUD (créer groupe, ajouter dépense)
- [x] Lecture des dépenses
- [x] Calcul des soldes
- [ ] Authentification utilisateurs (Amazon Cognito)
- [ ] Frontend web (S3 + CloudFront)
- [ ] Infrastructure as Code (Terraform)
- [ ] Tests automatisés

## 🛠️ Stack technique

- **Langage** : Python 3.13
- **SDK AWS** : boto3
- **Infra** : AWS (console — migration prévue vers Terraform)

---

*Projet pédagogique réalisé en autonomie dans le cadre d'une formation Cloud, en vue d'un stage/CDI cloud/DevOps.*
