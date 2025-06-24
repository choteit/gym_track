/// GymTrack - Application mobile Flutter
///
/// Objectif : application personnelle pour suivre ses performances en salle de sport.
/// L'utilisateur peut enregistrer ses séances, avec une liste d'exercices, les répétitions, le poids, la distance ou la durée.
/// Il peut ensuite consulter l'historique des séances et voir sa progression.
///
/// Technologies :
/// - Flutter (app mobile)
/// - Firebase Firestore (base de données cloud avec synchronisation offline)
/// - Firebase Auth (authentification anonyme pour isoler les données)
///
/// Fonctionnalités MVP à implémenter :
///
/// 1. Authentification
///    - Connexion automatique via Firebase Auth (anonyme)
///
/// 2. Écran d'accueil
///    - Bouton "Nouvelle séance"
///    - Liste des séances passées (avec date et résumé)
///
/// 3. Création de séance
///    - Date (automatique ou choisie)
///    - Liste d'exercices (choisis depuis une liste statique en JSON)
///    - Pour chaque exercice : nombre de séries, répétitions, poids, durée ou distance
///
/// 4. Structure des données Firestore (NoSQL, avec gestion offline)
///    - Collection "workout_sessions"
///      - Chaque document = une séance
///        - `date`: Timestamp
///        - `exercises`: tableau d’objets contenant :
///            - `exerciseName`: String
///            - `category`: String
///            - `unitType`: Enum (ex: "reps_weight", "time_distance")
///            - `sets`: tableau de séries, chaque set contient :
///                - `reps`: int (nullable)
///                - `weight`: double (nullable)
///                - `time`: int (nullable, secondes)
///                - `distance`: double (nullable)
///    - L'utilisateur peut modifier une séance après coup
///
/// 5. Données statiques embarquées
///    - Un fichier JSON local (`assets/exercises.json`) contient une liste d'exercices avec nom, catégorie et type de mesure.
///    - Exemple :
///      {
///        "name": "Chest Press",
///        "category": "muscu",
///        "unitType": "reps_weight"
///      }
///
/// 6. Écran de détail d'une séance
///    - Affiche tous les exercices, les séries et leurs valeurs
///
/// 7. Synchronisation offline
///    - Utiliser la persistance Firestore par défaut
///
/// Étapes attendues dans le scaffold initial :
/// - Initialisation Firebase (Auth + Firestore)
/// - Auth anonyme
/// - Chargement du fichier JSON au démarrage
/// - Modèle de données : `WorkoutSession`, `Exercise`, `Set`, `ExerciseTemplate`
/// - Navigation de base : accueil, création, consultation
///
/// Commencer par un squelette d’application avec :
/// - Un écran principal avec bouton "Nouvelle séance" et liste vide de séances
/// - Un écran secondaire de création de séance avec sélection d’un ou plusieurs exercices

