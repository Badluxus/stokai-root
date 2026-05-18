# STOKAI — Spécifications Fonctionnelles
**Gestion de Stock & Prise de Commande**
*Plateforme SaaS mobile-first pour commerçants sénégalais*

| Champ | Valeur |
|---|---|
| Type | Spécifications Fonctionnelles |
| Version | v1.1 — Mai 2026 |
| Auteur | Badluxus |
| Statut | Brouillon initial |

---

## Table des matières

1. [Contexte et Objectifs](#1-contexte-et-objectifs)
2. [Acteurs du Système](#2-acteurs-du-système)
3. [Fonctionnalités Détaillées](#3-fonctionnalités-détaillées)
4. [Règles Métier](#4-règles-métier)
5. [Architecture Technique Recommandée](#5-architecture-technique-recommandée)
6. [Roadmap et Phases de Développement](#6-roadmap-et-phases-de-développement)
7. [Exigences Non Fonctionnelles](#7-exigences-non-fonctionnelles)
8. [Glossaire](#8-glossaire)
9. [Annexes](#9-annexes)
10. [Stack Technique Retenu](#10-stack-technique-retenu)
11. [Suivi d'Avancement](#11-suivi-davancement)

---

## 1. Contexte et Objectifs

### 1.1 Contexte

Le commerce informel et de proximité représente une part majeure de l'activité économique au Sénégal. Les commerçants — épiciers, boutiques de quartier, grossistes, artisans — gèrent encore leurs stocks et commandes de façon manuelle (cahiers, mémoire, Excel) avec les risques que cela implique : ruptures non détectées, sur-stocks coûteux, commandes perdues, mécontentement client.

Parallèlement, les clients finaux n'ont aucun moyen simple de passer commande à distance, de vérifier la disponibilité d'un produit ou de suivre leur historique d'achats auprès de leurs commerçants habituels.

### 1.2 Objectifs du projet

- Offrir aux commerçants un outil mobile simple, offline-compatible, pour gérer stocks, produits et commandes.
- Permettre aux clients de parcourir les catalogues, passer commande et suivre leurs achats.
- Générer un revenu passif récurrent via un modèle SaaS à abonnements, ciblant le marché sénégalais.
- Fournir à l'éditeur (admin) un outil de gestion des utilisateurs, abonnements et métriques.

### 1.3 Nom de l'application

Le nom de travail retenu est **STOKAI** (Stock + OK + désinence mobile-friendly). Ce nom est susceptible d'évoluer.

### 1.4 Modèle économique

| Plan | Prix (XOF/mois) | Cible | Inclus |
|---|---|---|---|
| Gratuit | 0 | Test / micro-commerçants | 1 boutique, 50 produits, 30 commandes/mois |
| Starter | 5 000 | Boutiques actives | 1 boutique, 500 produits, commandes illimitées, export CSV |
| Pro | 15 000 | PME / grossistes | 3 boutiques, produits illimités, dashboard web, API partenaires |
| Entreprise | Sur devis | Grandes enseignes | Multi-boutiques, SLA, support dédié, personnalisation |

> 💡 Paiement via Wave, Orange Money (intégration CinetPay / PayDunya). Facturation mensuelle ou annuelle (-15%).

---

## 2. Acteurs du Système

L'application mobile unique gère trois rôles distincts. Un utilisateur peut cumuler les rôles COMMERÇANT et CLIENT s'il le souhaite.

| Rôle | Description | Accès principal |
|---|---|---|
| ADMIN | Éditeur de la plateforme | Backoffice web : gestion utilisateurs, abonnements, métriques |
| COMMERÇANT | Propriétaire d'une ou plusieurs boutiques | App mobile : gestion stock, produits, commandes reçues |
| CLIENT | Acheteur final | App mobile : catalogue, panier, commandes passées, suivi |

### 2.1 Parcours d'inscription

1. L'utilisateur télécharge l'app et s'inscrit avec son numéro de téléphone (OTP SMS).
2. Il choisit son rôle initial : Client ou Commerçant.
3. Un commerçant crée sa boutique (nom, description, adresse, catégorie, photo).
4. Un client peut parcourir les boutiques sans créer de compte (mode invité limité).

---

## 3. Fonctionnalités Détaillées

### 3.1 Authentification & Profil

#### 3.1.1 Inscription / Connexion

- Inscription via numéro de téléphone + code OTP (6 chiffres, validité 5 min)
- Ergonomie : Autofocus sur les champs critiques et validation par touche "Entrée" (mobile-friendly)
- Option e-mail + mot de passe en complément
- Connexion persistante avec refresh token JWT (30 jours)
- Déconnexion depuis n'importe quel appareil
- Récupération de compte : renvoi OTP ou lien e-mail

#### 3.1.2 Profil utilisateur

- Nom complet, photo de profil, numéro de téléphone, e-mail
- Langue de l'interface : Français / Wolof (v2)
- Gestion du consentement RGPD (droit d'accès, de suppression)

### 3.2 Gestion de Boutique (rôle COMMERÇANT)

#### 3.2.1 Création et configuration

- Nom de la boutique, slogan, logo/photo de couverture
- Catégorie principale (Alimentaire, Électronique, Mode, Pharmacie, Autre)
- Adresse (quartier, commune), géolocalisation optionnelle
- Horaires d'ouverture par jour de semaine
- Modes de paiement acceptés (Wave, Orange Money, Cash)
- **Configuration Livraison** : 
    - Activation/Désactivation de la livraison
    - Frais de livraison personnalisables (ex: 1 500 F)
    - Seuil de livraison gratuite (ex: dès 50 000 F)
- Statut de la boutique : Ouverte / Fermée temporairement / Définitivement fermée

#### 3.2.2 Multi-boutique (plan Pro et +)

- Un commerçant peut gérer jusqu'à 3 boutiques (Pro) ou illimité (Entreprise)
- Sélecteur de boutique active en haut de l'interface
- Chaque boutique a son propre stock, catalogue, commandes

### 3.3 Gestion des Stocks

#### 3.3.1 Catalogue produits

- Ajout de produit : nom, description, catégorie, photo(s), unité (pièce, kg, litre...)
- Prix de vente, prix d'achat (pour calcul marges), TVA applicable
- Code-barres / QR Code : scan via caméra ou saisie manuelle
- Produits avec variantes (ex. T-shirt : taille S/M/L, couleur)
- Produits composés / kits (ex. pack de 12 bouteilles)
- Archivage produit (soft delete, historique conservé)

#### 3.3.2 Gestion des quantités

- Stock actuel affiché en temps réel
- Seuil d'alerte personnalisable par produit (ex. alerter si < 10 unités)
- Entrée de stock : bon de réception, fournisseur, date, quantité, prix d'achat
- Sortie de stock : vente manuelle ou automatique via commande
- Ajustement inventaire (correction après comptage physique)
- Historique des mouvements de stock (entrées, sorties, ajustements)

#### 3.3.3 Alertes et notifications stock

- Notification push : produit en rupture de stock
- Notification push : produit atteignant le seuil d'alerte
- Rapport hebdomadaire : produits les plus vendus, taux de rotation

#### 3.3.4 Import / Export

- Import catalogue via fichier CSV (colonnes : nom, prix, quantité, catégorie, code-barres)
- Export stock complet en CSV / Excel (plan Starter et +)
- Export rapport de mouvements filtrable par date

### 3.4 Gestion des Commandes (vue COMMERÇANT)

#### 3.4.1 Réception des commandes

- Notification push instantanée à chaque nouvelle commande
- Liste des commandes filtrables : En attente / Confirmée / En préparation / Livrée / Annulée
- Détail commande : produits, quantités, client, adresse, mode de paiement, note client

#### 3.4.2 Traitement des commandes

| Statut | Action commerçant | Déclencheur |
|---|---|---|
| En attente | Confirmer ou Refuser | Nouveau ordre client |
| Confirmée | Marquer En préparation | Commerçant accepte |
| En préparation | Marquer Prête / Expédiée | Produits préparés |
| Prête / Expédiée | Confirmer Livraison | Client récupère ou livreur dépose |
| Livrée | — (terminal) | Livraison confirmée |
| Annulée | — (terminal) | Refus commerçant ou annulation client |

- Possibilité d'ajouter une note interne sur la commande
- Impression du bon de commande (PDF partageable)

#### 3.4.3 Vente directe (point de vente simplifié)

- Le commerçant peut créer une commande manuelle pour un client en boutique
- Sélection produits + quantités, calcul automatique du total
- Enregistrement de la vente sans que le client ait l'app
- Paiement enregistré : cash, Wave, Orange Money

### 3.5 Expérience Client (rôle CLIENT)

#### 3.5.1 Découverte des boutiques

- Page d'accueil (Marketplace) : Design Premium avec bannières promotionnelles 3D, arrière-plans mesh et navigation par catégories horizontales (pilules).
- Moteur de recherche : Page dédiée avec historique de recherche local et suggestions par tendances.
- Fiche boutique : logo, description, horaires, avis, catalogue
- Favoris : enregistrer ses boutiques préférées

#### 3.5.2 Catalogue et panier

- Parcourir les produits avec filtres : catégorie, disponibilité, prix
- Fiche produit : photos, description, prix, disponibilité en temps réel
- Ajout au panier (multi-boutique non supporté dans le même panier)
- Panier : modification quantités, suppression d'articles, affichage sous-total
- **Calcul Livraison Dynamique** : Frais de livraison calculés selon les paramètres de la boutique (gratuit si seuil atteint)

#### 3.5.3 Passage de commande

- Saisie de l'adresse de livraison ou option "Retrait en boutique"
- Choix du mode de paiement : Wave / Orange Money / Cash à la livraison
- Champ note optionnelle pour le commerçant
- Récapitulatif avant validation
- Confirmation par OTP (sécurité anti-spam commandes)

#### 3.5.4 Suivi des commandes

- Historique de toutes les commandes passées
- Suivi en temps réel du statut (push notifications à chaque changement)
- Possibilité d'annuler si statut = "En attente"
- Notation de la boutique et du commerçant après livraison (étoiles 1–5 + commentaire)

### 3.6 Notifications

| Événement | Destinataire | Canal |
|---|---|---|
| Nouvelle commande reçue | Commerçant | Push + SMS optionnel |
| Commande confirmée / refusée | Client | Push + SMS optionnel |
| Statut commande mis à jour | Client | Push |
| Stock en alerte / rupture | Commerçant | Push |
| Abonnement expirant (J-7) | Commerçant | Push + E-mail |
| Paiement abonnement confirmé | Commerçant | E-mail |
| Rapport hebdomadaire stock | Commerçant | E-mail |

Les notifications SMS sont optionnelles (coût additionnel) et activables par le commerçant dans ses paramètres. Intégration via Africa's Talking.

### 3.7 Gestion des Abonnements (côté commerçant)

- Page "Mon Abonnement" : plan actuel, date de renouvellement, historique de paiements
- Changement de plan (upgrade/downgrade) à tout moment, prorata calculé
- Paiement Wave / Orange Money via PayDunya ou CinetPay
- Facture PDF générée automatiquement après chaque paiement
- Période d'essai gratuite : 14 jours sur le plan Starter à l'inscription
- Suspension automatique du compte en cas de non-paiement (après 7 jours de grâce)

### 3.8 Backoffice Admin (application web Angular)

#### 3.8.1 Tableau de bord

- KPIs : MRR, nombre d'abonnés actifs, taux de churn, nouvelles inscriptions
- Graphiques : évolution MRR sur 12 mois, répartition par plan, taux de conversion essai → payant

#### 3.8.2 Gestion des utilisateurs

- Liste de tous les comptes (recherche par nom, téléphone, e-mail)
- Fiche utilisateur : rôles, boutiques, abonnement actif, historique connexions
- Actions : suspendre / réactiver / supprimer un compte
- Impersonnation (se connecter en tant qu'utilisateur pour support)

#### 3.8.3 Gestion des abonnements

- Visualiser et modifier le plan d'un commerçant
- Accorder une extension gratuite (gestes commerciaux)
- Historique des paiements avec statuts : Succès / Échoué / En attente
- Export comptable des transactions (CSV/Excel)

#### 3.8.4 Gestion du catalogue global

- Modération des boutiques signalées par des clients
- Suppression de produits illicites
- Catégories globales : création, édition, désactivation

#### 3.8.5 Paramétrage de la plateforme

- Configuration des plans (prix, limites) sans redéploiement
- Messages de maintenance / bannières d'information
- Gestion des templates de notification (SMS, e-mail, push)

---

## 4. Règles Métier

### 4.1 Stock

- Un stock ne peut pas passer en dessous de 0 automatiquement — une commande dépassant le stock disponible est refusée ou mise en liste d'attente selon la préférence du commerçant.
- Toute modification de stock (entrée, sortie, ajustement) est tracée avec l'horodatage et l'utilisateur responsable.
- La suppression d'un produit est un archivage logique : les commandes historiques restent consultables.

### 4.2 Commandes

- Une commande ne peut être annulée par le client que si son statut est "En attente".
- Un commerçant a 30 minutes pour confirmer ou refuser une commande avant qu'elle soit automatiquement annulée (paramétrable).
- En cas de rupture de stock entre la commande et la confirmation, le commerçant doit notifier le client et proposer un ajustement ou remboursement.
- Le paiement mobile (Wave/OM) est initié côté client avant confirmation de la commande (mode prépayé) ou à la livraison (mode COD).

### 4.3 Abonnements et limites

| Limite | Gratuit | Starter | Pro | Entreprise |
|---|---|---|---|---|
| Boutiques | 1 | 1 | 3 | Illimité |
| Produits par boutique | 50 | 500 | Illimité | Illimité |
| Commandes par mois | 30 | Illimité | Illimité | Illimité |
| Export CSV/Excel | Non | Oui | Oui | Oui |
| Dashboard web | Non | Non | Oui | Oui |
| Support | Communauté | Chat | Chat + email | Dédié |

Un commerçant dépassant la limite du plan reçoit une notification et a 7 jours pour upgrader avant blocage des nouvelles entrées.

### 4.4 Sécurité

- Toutes les communications passent par HTTPS/TLS 1.3.
- Les mots de passe sont hachés avec BCrypt (coût 12).
- Les tokens JWT ont une durée de vie configurable : 24h (access) et 30 jours (refresh) pour limiter les reconnexions mobiles.
- Rate limiting sur les endpoints publics : 100 requêtes / minute / IP.
- Les données de paiement ne transitent jamais par le backend STOKAI (délégation totale à PayDunya/CinetPay).

---

## 5. Architecture Technique Recommandée

> ⚠️ Ce document est un cahier des charges fonctionnel. L'architecture ci-dessous est indicative et sera affinée dans un document technique dédié.

### 5.1 Vue d'ensemble

| Composant | Technologie |
|---|---|
| Backend | Spring Boot 3.x — Monolithe modulaire (Java 21) |
| Base de données | PostgreSQL 15 (production) + H2 (tests) |
| Cache / Sessions | Redis 7 |
| App mobile | Ionic 7 + Angular 17 (Capacitor pour iOS/Android) |
| App backoffice | Angular 17 (standalone, web only) |
| Notifications Push | Firebase Cloud Messaging (FCM) |
| Paiement | CinetPay ou PayDunya (Wave, Orange Money) |
| SMS | Africa's Talking |
| Stockage fichiers | Cloudflare R2 (photos produits, logos) |
| Hébergement | VPS hors Sénégal (OVH Europe ou AWS Paris) |
| CI/CD | GitHub Actions → Docker Compose |

### 5.2 Modules backend (monolithe modulaire)

| Module | Responsabilité | Entités principales |
|---|---|---|
| auth | Authentification, JWT, OTP, rôles | User, Role, RefreshToken, OtpCode |
| boutique | CRUD boutiques, catégories, horaires | Boutique, Categorie, Horaire |
| stock | Produits, variantes, mouvements de stock | Produit, Variante, MouvementStock |
| commande | Cycle de vie des commandes, panier | Commande, LigneCommande, Panier |
| notification | Push FCM, SMS, e-mail (templates) | Notification, Template |
| abonnement | Plans, paiements, limites, webhooks | Abonnement, Paiement, PlanConfig |
| admin | API backoffice, métriques, modération | Rapport, ActionAdmin |

### 5.3 Mode offline-first (mobile)

Compte tenu des réalités de connectivité au Sénégal, l'app mobile doit fonctionner en mode dégradé :

- SQLite local (Capacitor SQLite) comme base de données embarquée
- Synchronisation bidirectionnelle via API REST à la reconnexion
- Stratégie de résolution de conflits : "last-write-wins" pour les stocks, queue FIFO pour les commandes
- Indicateur visuel clair quand l'app est hors-ligne

---

## 6. Roadmap et Phases de Développement

### Phase 1 — MVP (J+0 à J+90)

Objectif : lancer un produit fonctionnel pour valider l'adéquation produit-marché.

| Fonctionnalité | Priorité | Effort |
|---|---|---|
| Inscription / Connexion OTP | Critique | M |
| Création boutique | Critique | S |
| Gestion produits (CRUD) | Critique | M |
| Gestion stock (entrées/sorties/alertes) | Critique | L |
| Catalogue public (vue client) | Critique | M |
| Panier et prise de commande | Critique | L |
| Gestion statuts commande | Critique | M |
| Notifications push | Haute | M |
| Vente directe point de vente | Haute | S |
| Backoffice admin minimal | Haute | M |

*S = < 1 semaine solo, M = 1–2 semaines, L = 2–3 semaines*

### Phase 2 — Monétisation (J+90 à J+150)

- Intégration paiement Wave / Orange Money (PayDunya)
- Système d'abonnements avec périodes d'essai
- Export CSV/Excel des stocks et commandes
- Notifications SMS
- Système de notation boutiques

### Phase 3 — Croissance (J+150 à J+240)

- Dashboard web commerçant (plan Pro)
- Multi-boutique (plan Pro)
- Rapports analytiques avancés (top produits, CA, marges)
- Scan code-barres via caméra
- Version Wolof de l'interface
- API partenaires

### Phase 4 — Expansion (J+240+)

- Module livraison (intégration coursiers locaux)
- Module fournisseurs (bons de commande fournisseur)
- Marketplace entre commerçants
- App iOS native (si traction suffisante)

---

## 7. Exigences Non Fonctionnelles

### 7.1 Performance

- Temps de réponse API < 500ms au P95 en conditions normales
- L'app mobile doit rester utilisable avec une connexion 3G (< 1 MB par écran)
- Les images produits sont compressées et redimensionnées côté serveur (WebP, max 300KB)

### 7.2 Disponibilité

- Cible uptime : 99.5% — soit < 3h d'indisponibilité/mois
- Sauvegardes PostgreSQL automatiques quotidiennes, rétention 30 jours

### 7.3 Sécurité

- Chiffrement des données sensibles au repos (AES-256)
- Journalisation des actions admin avec horodatage
- Tests de pénétration avant le lancement public

### 7.4 Conformité

- Respect des conditions d'utilisation de Wave et Orange Money
- Politique de confidentialité conforme au cadre réglementaire sénégalais (CDP)
- CGU en français, signées électroniquement à l'inscription

### 7.5 Accessibilité et UX

- Interface lisible en plein soleil (contraste élevé, polices >= 14pt)
- Navigation au pouce en bas d'écran (zones tactiles >= 44px)
- Messages d'erreur explicites en français simple
- Support Android 8+ et iOS 13+

---

## 8. Glossaire

| Terme | Définition |
|---|---|
| MRR | Monthly Recurring Revenue — chiffre d'affaires mensuel récurrent issu des abonnements |
| Churn | Taux de désabonnement — pourcentage de commerçants payants qui ne renouvellent pas |
| COD | Cash On Delivery — paiement à la livraison |
| OTP | One-Time Password — code à usage unique envoyé par SMS pour l'authentification |
| JWT | JSON Web Token — standard d'authentification sans état côté serveur |
| FCM | Firebase Cloud Messaging — service de notifications push de Google |
| XOF | Franc CFA ouest-africain — monnaie utilisée au Sénégal |
| Mouvement de stock | Toute entrée ou sortie de produit dans le stock |
| Seuil d'alerte | Quantité minimale déclenchant une notification de réapprovisionnement |
| Plan | Niveau d'abonnement SaaS définissant les fonctionnalités et limites accessibles |

---

## 9. Annexes

### 9.1 Flux de commande

```
CLIENT                          SYSTÈME                        COMMERÇANT
  │                               │                               │
  ├─ Panier + Validation ────────►│                               │
  │                               ├─ Créer commande (En attente) ►│
  │                               │                               ├─ Confirmer
  │◄─ Statut: Confirmée ──────────┤◄──────────────────────────────┤
  │                               │                               ├─ En préparation
  │◄─ Statut: En préparation ─────┤◄──────────────────────────────┤
  │                               │                               ├─ Prête
  │◄─ Statut: Prête ──────────────┤◄──────────────────────────────┤
  ├─ Retrait / Livraison ─────────┤                               │
  │                               ├─ Décrémentation stock ───────►│
  │◄─ Statut: Livrée ─────────────┤◄──────────────────────────────┤
```

### 9.2 Entités de données principales

| Entité | Attributs clés |
|---|---|
| User | id, phone, email, passwordHash, roles[], createdAt |
| Boutique | id, userId, nom, categorie, adresse, latitude, longitude, statut, planId |
| Produit | id, boutiqueId, nom, description, prix, prixAchat, unite, codeBarre, actif |
| Variante | id, produitId, libelle, valeur, prixSupplementaire, stockQuantite |
| MouvementStock | id, produitId, type(ENTREE/SORTIE/AJUSTEMENT), quantite, motif, userId, createdAt |
| Commande | id, clientId, boutiqueId, statut, modeReglement, adresseLivraison, total, createdAt |
| LigneCommande | id, commandeId, produitId, variante, quantite, prixUnitaire |
| Abonnement | id, userId, planId, dateDebut, dateFin, statut, autoRenouvellement |
| Paiement | id, abonnementId, montant, devise(XOF), statut, reference, gatewayRef, createdAt |

### 9.3 Intégrations tierces

| Service | Usage | Alternative |
|---|---|---|
| PayDunya | Paiement Wave, Orange Money, CB | CinetPay |
| Firebase FCM | Notifications push iOS/Android | OneSignal |
| Africa's Talking | Envoi OTP et alertes SMS | Twilio |
| Cloudflare R2 | Stockage photos (S3-compatible) | AWS S3, Supabase Storage |
| Mapbox / Leaflet | Carte boutiques, géolocalisation | Google Maps (payant) |
| Sentry | Monitoring erreurs frontend/backend | — |
| Grafana + Prometheus | Métriques serveur (plan Entreprise) | — |

---

## 10. Stack Technique Retenu

### 10.1 Backend — Spring Boot

| Champ | Valeur |
|---|---|
| Langage | Java 21 |
| Framework | Spring Boot 3.x |
| Build tool | Maven |
| Architecture | Monolithe modulaire |
| IDE | IntelliJ IDEA |

#### Dépendances Spring Initializr

| Dépendance | Usage |
|---|---|
| Spring Web | API REST |
| Spring Data JPA | ORM et accès base de données |
| Spring Security | Authentification et autorisation |
| Validation | Validation des DTOs (@Valid, @NotBlank…) |
| Lombok | Réduction du boilerplate Java |
| Spring Boot DevTools | Hot reload en développement |
| Spring Boot Actuator | Health checks, métriques |
| PostgreSQL Driver | Connexion base de données production |
| Flyway Migration | Versionnement des migrations SQL |
| Spring Data Redis | Cache et gestion des sessions |
| OAuth2 Resource Server | Validation JWT intégrée |

#### Dépendances additionnelles (pom.xml manuel)

| Dépendance | Version | Usage |
|---|---|---|
| mapstruct | 1.5.5.Final | Mapping automatique DTO <-> Entité |
| springdoc-openapi-starter-webmvc-ui | 2.3.0 | Documentation Swagger UI |
| firebase-admin | 9.2.0 | Notifications push Firebase FCM |
| africastalking core | 3.4.5 | Envoi de SMS (OTP, alertes) |

### 10.2 Frontend — Nx Monorepo

#### Structure du monorepo

```
stokai-front/
├── apps/
│   ├── admin-web/     ← Angular 17 standalone (backoffice admin)
│   └── mobile/        ← Angular 17 + Ionic + Capacitor (app commerçant/client)
├── libs/
│   └── shared/        ← modèles TS, services HTTP, interceptors, guards
├── android/           ← généré par Capacitor
├── capacitor.config.json
└── nx.json
```

#### Technologies frontend

| Composant | Technologie |
|---|---|
| Workspace | Nx Monorepo (preset: apps) |
| Framework | Angular 17 (standalone components) |
| UI Mobile | Ionic 7 (@ionic/angular/standalone) |
| Mobile natif | Capacitor 8 |
| Style | SCSS |
| Bundler | esbuild (@angular/build:application) |
| Tests unitaires | Vitest Angular |
| Tests E2E | Cypress |
| Package manager | npm |

#### Plugins Capacitor installés

| Package | Version | Usage |
|---|---|---|
| @capacitor/core | 8.3.1 | Noyau Capacitor |
| @capacitor/android | 8.3.1 | Plateforme Android |
| @capacitor/app | 8.1.0 | Cycle de vie de l'app |
| @capacitor/haptics | 8.0.2 | Vibrations tactiles |
| @capacitor/keyboard | 8.0.3 | Gestion du clavier virtuel |
| @capacitor/status-bar | 8.0.2 | Barre de statut native |

### 10.3 Services tiers retenus

| Service | Usage | Coût |
|---|---|---|
| Firebase FCM | Notifications push iOS/Android | Gratuit (illimité) |
| Africa's Talking | OTP SMS + alertes SMS | ~0,02$/SMS (sandbox gratuit) |
| CinetPay ou PayDunya | Paiement Wave / Orange Money | Commission par transaction |
| Cloudflare R2 | Stockage photos produits et logos | Gratuit jusqu'à 10 GB |
| Resend ou Brevo | E-mails transactionnels | Gratuit jusqu'à 3 000/mois |
| Sentry | Monitoring erreurs | Gratuit (plan dev) |

### 10.4 Infrastructure

| Composant | Choix |
|---|---|
| Hébergement | VPS hors Sénégal (OVH Europe ou AWS Paris) |
| Conteneurisation | Docker Compose (dev) → Docker (prod) |
| CI/CD | GitHub Actions |
| Base de données prod | PostgreSQL 15 |
| Base de données test | H2 (in-memory) |
| Cache | Redis 7 |

---

## 11. Suivi d'Avancement

**Légende :** ✅ FAIT | 🔄 EN COURS | ⏳ À FAIRE | ❌ BLOQUÉ

### 11.1 Setup & Infrastructure

| Tâche | Statut | Notes |
|---|---|---|
| Création projet Spring Boot (Initializr) | ✅ FAIT | Java 21, Maven, dépendances de base sélectionnées |
| Configuration dépendances Maven (pom.xml) | ✅ FAIT | Ajout manuel MapStruct / Firebase / Africa's Talking / Cloudinary OK |
| Création Nx monorepo (stokai-front) | ✅ FAIT | Workspace initialisé avec preset apps |
| App Angular admin-web | ✅ FAIT | Générée avec esbuild, vitest, cypress, SCSS |
| App mobile (Angular + Ionic) | ✅ FAIT | Générée et buildée avec succès |
| Lib partagée (libs/shared) | ✅ FAIT | Générée, buildable, path alias @stokai/shared configuré |
| Capacitor Android configuré | ✅ FAIT | cap sync android OK, cap doctor : Android looking great |
| Capacitor iOS configuré | ⏳ À FAIRE | Nécessite un Mac |
| Docker Compose (dev) | ✅ FAIT | PostgreSQL + Redis + backend |
| CI/CD Auto-Deploy (Production) | ✅ FAIT | CI/CD automatisé sur Vercel (Frontend) et Render (Backend) à chaque push |
| Hébergement Production Cloud | ✅ FAIT | API Spring Boot en HTTPS sur Render, PWA Mobile sur Vercel, PostgreSQL managé sur Render |
| Hébergement des Médias (Cloudinary) | ✅ FAIT | Stockage robuste et persistant des images produits sur Cloudinary |

### 11.2 Backend — Modules à développer

| Module | Tâche | Statut | Priorité |
|---|---|---|---|
| Projet | Structure packages modulaires | ✅ FAIT | Critique |
| Projet | Configuration application.yml (dev/prod profiles) | ✅ FAIT | Critique |
| Projet | Configuration Flyway (migration initiale) | ✅ FAIT | Schéma initial + Auth + Stock movements OK |
| Projet | Configuration Spring Security + JWT | ✅ FAIT | Critique |
| auth | Entités User, Role, RefreshToken, OtpCode | ✅ FAIT | Critique |
| auth | Endpoint POST /auth/register (OTP envoi) | ✅ FAIT | Critique |
| auth | Endpoint POST /auth/verify-otp (validation) | ✅ FAIT | Critique |
| auth | Endpoint POST /auth/login (email+mdp) | ✅ FAIT | Critique |
| auth | Endpoint POST /auth/refresh (refresh token) | ✅ FAIT | Haute |
| boutique | Entités Boutique, Categorie, Horaire | ✅ FAIT | Critique |
| boutique | CRUD boutique (commerçant) | ✅ FAIT | Critique |
| boutique | Endpoint public GET /boutiques | ✅ FAIT | Critique |
| stock | Entités Produit, Variante, MouvementStock | ✅ FAIT | Critique |
| stock | CRUD produits | ✅ FAIT | Critique |
| stock | Entrée / Sortie / Ajustement stock | ✅ FAIT | Critique |
| stock | Alertes seuil (trigger + notification) | ✅ FAIT | Haute |
| stock | Import CSV produits | ✅ FAIT | Moyenne |
| stock | Export CSV/Excel stock | ✅ FAIT | Moyenne |
| commande | Entités Commande, LigneCommande, Panier | ✅ FAIT | Critique |
| commande | Gestion cycle de vie statuts commande | ✅ FAIT | Critique |
| commande | Vente directe (point de vente manuel) | ✅ FAIT | Haute |
| commande | Auto-annulation après 30 min sans réponse | ✅ FAIT | Haute |
| notification | Intégration Firebase FCM (push) | ✅ FAIT | Haute |
| notification | Intégration Africa's Talking (SMS) | ✅ FAIT | Haute |
| notification | Templates e-mail (Resend/Brevo) | ✅ FAIT | Moyenne |
| abonnement | Entités Abonnement, Paiement, PlanConfig | ✅ FAIT | Haute |
| abonnement | Intégration CinetPay / PayDunya webhook | ✅ FAIT | Haute |
| abonnement | Logique de limites par plan (middleware) | ✅ FAIT | Haute |
| admin | Endpoints métriques (MRR, churn, inscriptions) | ✅ FAIT | Moyenne |
| admin | CRUD utilisateurs (suspend/réactiver) | ✅ FAIT | Moyenne |

### 11.3 Frontend Mobile (apps/mobile)

| Écran / Feature | Statut | Priorité |
|---|---|---|
| Configuration Ionic dans app.component.ts | ✅ FAIT | Critique |
| Structure routing (auth / merchant / client) | ✅ FAIT | Critique |
| Écran Splash / Onboarding | ✅ FAIT | Haute |
| Écran Inscription (numéro de téléphone) | ✅ FAIT | Critique |
| Écran Vérification OTP | ✅ FAIT | Critique |
| Écran Connexion (e-mail + mot de passe) | ✅ FAIT | Critique |
| Écran Choix de rôle (commerçant / client) | ✅ FAIT | Critique |
| Système de thème (Dark Mode / Couleurs) | ✅ FAIT | Moyenne |
| Modèles TypeScript partagés (libs/shared) | ✅ FAIT | Critique |
| Services API & Intercepteurs JWT | ✅ FAIT | Critique |
| [MARCHAND] Dashboard (commandes, profit du jour, alertes) | ✅ FAIT | Critique |
| [MARCHAND] Liste produits + stock | ✅ FAIT | Critique |
| [MARCHAND] Ajout / édition produit (Premium UX + Aide) | ✅ FAIT | Critique |
| [MARCHAND] Gestion stock (entrées/sorties) | ✅ FAIT | Critique |
| [MARCHAND] Création Boutique (onboarding) | ✅ FAIT | Critique |
| [MARCHAND] Liste ventes & Analyse profit | ✅ FAIT | Critique |
| [MARCHAND] Détail commande + changement statut | ✅ FAIT | Critique |
| [MARCHAND] Vente directe (POS simplifié) | ✅ FAIT | Haute |
| [MARCHAND] Paramètres boutique & Livraison | ✅ FAIT | Haute |
| [MARCHAND] Mon abonnement | ✅ FAIT | Haute |
| [CLIENT] Marketplace (accueil, boutiques, catalogue) | ✅ FAIT | Critique |
| [CLIENT] Moteur de recherche (page dédiée + historique) | ✅ FAIT | Critique |
| [CLIENT] Détail Boutique & Liste produits | ✅ FAIT | Critique |
| [CLIENT] Détail Produit (Premium UX + Qté) | ✅ FAIT | Critique |
| [CLIENT] Panier & Gestion quantités | ✅ FAIT | Critique |
| [CLIENT] Passage de commande (adresse + paiement) | ✅ FAIT | Critique |
| [CLIENT] Suivi commandes & Historique | ✅ FAIT | Critique |
| [SYSTEM] Guards de sécurité & Rôles | ✅ FAIT | Critique |
| [SYSTEM] Design System & Tokens (Mobile/Web) | ✅ FAIT | Haute |
| Notifications push (FCM + Capacitor Push Plugin) | ✅ FAIT | Haute |
| Mode offline (SQLite local + sync) | ✅ FAIT | Haute |

### 11.4 Frontend Admin (apps/admin-web)

| Écran / Feature | Statut | Priorité |
|---|---|---|
| Layout principal (sidebar, header, routing) | ✅ FAIT | Critique |
| Dashboard KPIs (MRR, abonnés, churn, inscriptions) | ✅ FAIT | Critique |
| Liste et gestion des utilisateurs | ✅ FAIT | Critique |
| Notifications et Paramètres système | ✅ FAIT | Haute |
| Gestion des abonnements | ✅ FAIT | Haute |
| Modération boutiques / produits | ✅ FAIT | Moyenne |
| Paramétrage plans (prix, limites) | ✅ FAIT | Haute |
| Export comptable transactions | ✅ FAIT | Moyenne |
| Authentification admin sécurisée (rôle ADMIN) | ✅ FAIT | Critique |

### 11.5 Lib Partagée (libs/shared)

| Fichier | Contenu | Statut |
|---|---|---|
| models/user.model.ts | Interface User, Role, AuthResponse | ✅ FAIT |
| models/boutique.model.ts | Interface Boutique, Categorie, Horaire | ✅ FAIT |
| models/produit.model.ts | Interface Produit, Variante, MouvementStock | ✅ FAIT |
| models/commande.model.ts | Interface Commande, LigneCommande, StatutCommande | ✅ FAIT |
| models/abonnement.model.ts | Interface Abonnement, Plan, Paiement | ✅ FAIT |
| services/api.service.ts | HttpClient base (baseUrl, headers, error handling) | ✅ FAIT |
| services/auth.service.ts | JWT storage, currentUser$, isLoggedIn() | ✅ FAIT |
| interceptors/auth.interceptor.ts | Inject Bearer token sur chaque requête HTTP | ✅ FAIT |
| guards/auth.guard.ts | Redirection si non authentifié | ✅ FAIT |
| guards/role.guard.ts | Redirection si rôle insuffisant | ✅ FAIT |
| index.ts | Barrel export de tous les éléments de la lib | ✅ FAIT |

### 11.6 Prochaines étapes immédiates (par ordre de priorité)

1. Finaliser les dépendances Maven manuelles dans pom.xml (MapStruct, Firebase, Africa's Talking) ✅ FAIT
2. Créer la structure de packages modulaires dans le projet Spring Boot ✅ FAIT
3. Configurer application.yml pour les profils dev et prod ✅ FAIT
4. Créer la migration Flyway initiale (schéma de base : users, roles, boutiques, produits) ✅ FAIT
5. Implémenter le module Boutique (CRUD + horaires + catégories) ✅ FAIT
6. Implémenter le module Stock (Produits, Variantes, Mouvements de stock, Import/Export, Alertes) ✅ FAIT
7. Implémenter le module Commande (Cycle de vie, SMS notifications, déstockage, POS, Auto-cancel) ✅ FAIT
8. Implémenter le module Abonnement (Plans, limites, paiements, webhooks) ✅ FAIT
9. Finaliser le module Auth (Endpoints complets + Africa's Talking) ✅ FAIT
10. Implémenter le module Notification (FCM, SMS) ✅ FAIT
11. Implémenter le module Admin (Dashboard stats, User management) ✅ FAIT
12. Configurer Ionic dans apps/mobile (app.component.ts, main.ts, styles) ✅ FAIT
13. Créer les modèles TypeScript dans libs/shared ✅ FAIT
14. Développer les écrans d'inscription et connexion dans l'app mobile ✅ FAIT
15. Résoudre l'erreur d'injection Spring (AuthService bean missing) ✅ FAIT (Fix .env path)
16. Implémenter le parcours client complet (Marketplace, Panier, Commande) ✅ FAIT
17. Implémenter le détail des commandes & POS marchand ✅ FAIT
18. Sécuriser les routes avec des Guards (Auth, Role) ✅ FAIT
| 19. Développer le Dashboard Admin Web | ✅ FAIT |
| 20. Intégration complète Design System (Tokens) | ✅ FAIT |
| 21. Nettoyage Mockups & Connexion Stats réelles | ✅ FAIT |
| 22. Page Détail Boutique client | ✅ FAIT |
| 23. Gestion des utilisateurs (Liste, Détails, Suspendre) | ✅ FAIT |
| 24. Système de notifications & Paramètres Admin | ✅ FAIT |
| 25. Configuration des paramètres de livraison (Backend + Migration V14) | ✅ FAIT |
| 26. Optimisation UX (Hiding scrollbars, Full-width design) | ✅ FAIT |
| 27. Accessibilité (A11y, Alt text, Keyboard navigation) | ✅ FAIT |
| 28. Refonte visuelle Marketplace & Recherche | ✅ FAIT |
| 29. Migration vers Angular Signals (Merchant/Client) | ✅ FAIT |
| 30. Configurer les notifications push natives | ✅ FAIT |
| 31. Intégration de Cloudinary pour le stockage d'images robuste | ✅ FAIT |
| 32. Optimisation du boot de démarrage Spring Boot sur Render (Lazy Init) | ✅ FAIT |
| 33. Auto-refresh réactif de la liste des produits (ionViewWillEnter) | ✅ FAIT |
| 34. Fix de l'icône corbeille et des doubles chevrons de navigation iOS | ✅ FAIT |
| 35. Intégration de la passerelle de paiement PayDunya | 🔄 EN COURS |

---

*STOKAI — Document confidentiel, usage interne*