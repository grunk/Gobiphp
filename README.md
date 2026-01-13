# GobiPHP

Application native macOS pour exécuter du code PHP avec coloration syntaxique.

## Fonctionnalités

- Éditeur de code avec coloration syntaxique PHP (mots-clés, variables, chaînes, commentaires, nombres)
- Exécution du code PHP via le bouton "Exécuter" ou le raccourci **Cmd+Entrée**
- Affichage du résultat avec mise en évidence des erreurs en rouge
- Détection automatique de PHP sur le système
- Message d'aide si PHP n'est pas installé

## Prérequis

- **macOS 13.0** ou supérieur
- **Xcode 15** ou supérieur (pour compiler)
- **PHP** installé sur le système

### Installation de PHP (si nécessaire)

Via Homebrew :
```bash
brew install php
```

## Compilation et lancement

1. Ouvrir le projet dans Xcode :
   ```bash
   open GobiPHP.xcodeproj
   ```

2. Compiler et lancer avec **Cmd+R**

## Structure du projet

```
GobiPHP/
├── GobiPHPApp.swift       # Point d'entrée de l'application
├── ContentView.swift      # Interface utilisateur (éditeur + résultat)
├── PHPExecutor.swift      # Logique d'exécution PHP
├── GobiPHP.entitlements   # Permissions de l'application
└── Assets.xcassets/       # Ressources (icônes, couleurs)
```

## Utilisation

1. Saisir du code PHP dans l'éditeur (sans les balises `<?php ?>`)
2. Cliquer sur "Exécuter" ou appuyer sur **Cmd+Entrée**
3. Le résultat s'affiche dans le panneau inférieur

### Exemple

```php
echo "Hello, World!";
```

## Licence

MIT
