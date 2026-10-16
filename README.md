# Keep Talking and Nobody Explodes … UNIX version !

# Le principe

![illustration.jpg](illustration.jpg)

## Les rôles

Ce jeu ce joue à deux joueurs :

- **Le démineur :** c’est celui derrière l’ordinateur.
  Lui seul peut interagir avec la bombe.
- **Le gars derrière le fauteuil :** c’est vous !
  Vous avez toutes les instructions pour désamorcer cette bombe.

Vous devez coopérer pour comprendre ce que l’un et l’autre doivent faire !

## Les modules

Il y a aujourd’hui 7 modules, tous ont pour but de vous faire découvrir des commandes UNIX différentes :

- _fils_
- _citations_
- _alphabet_
- _morse_
- _tintin_
- _cities_
- _memory_

Chaque module a une certaine difficulté, mais soyez-en surs : plus vous jouerez, plus vous y arriverez !

**L’ordre dans lequel vous résolvez les modules n’a aucune importance !**

## Comment gagner ?

Chaque bombe a un niveau de difficulté différents (_voir ci-dessous_). L’unique moyen pour gagner :

**Désamorcer tous les modules activés avant la fin du compte à rebours.**

### Et comment perdre ?

Il y a deux manières de perdre :

- ne pas arriver à désamorcer tous les modules avant la fin du compte à rebours.
- dépasser le nombre d’erreurs maximum autorisé

Chaque fois que vous vous trompez dans un module, une erreur vous serez comptabilisée.

Chaque niveau a un nombre d’erreurs autorisées différents. Ce nombre vous sera donné au début de chaque lancement de bombe. Si vous arrivez au nombre d’erreurs maximum autorisé, la bombe explosera même si vous n’êtes pas à la fin du compteur !

## Les commandes

Il y a de nombreuses commandes, et vous seul ayant le manuel peut éclairer le démineur.

- Les commandes de bases sont notés dans l’introduction ci-après.
- Certains modules précisent quelles commandes il faut utilisée pour réussir telle étape
- Toutes les commandes à utiliser sont listées dans une annexe _Les commandes_.
  Vous y trouverez une explication, des exemples ainsi que la liste des options à connaître.

## La progression

Voici la liste des niveaux :

| Numéro de niveau | Mini-jeu lancé    | Temps  | Erreurs autorisées | Votre record | Les modules impliqués |
| ---------------- | ----------------- | ------ | ------------------ | ------------ | --------------------- |
| 0                | fils              | 50 min | 7                  |              | N/A                   |
| 1                | citations         | 50 min | 7                  |              | N/A                   |
| 2                | fils, citations   | 50 min | 5                  |              | N/A                   |
| 3                | alphabet          | 40 min | 5                  |              | N/A                   |
| 4                | morse             | 40 min | 5                  |              | N/A                   |
| 5                | tintin            | 40 min | 5                  |              | N/A                   |
| 6                | cities            | 40 min | 5                  |              | N/A                   |
| 7                | memory            | 40 min | 5                  |              | N/A                   |
| 8                | alphabet, morse   | 40 min | 4                  |              | N/A                   |
| 9                | tintin, cities    | 40 min | 4                  |              | N/A                   |
| 10               | memory, citations | 40 min | 4                  |              | N/A                   |
| 11               | 2 modules random  | 30 min | 4                  |              |                       |
| 12               | 3 modules random  | 30 min | 4                  |              |                       |
| 13               | 3 modules random  | 30 min | 3                  |              |                       |
| 14               | 4 modules random  | 30 min | 3                  |              |                       |
| 15               | 3 modules random  | 30 min | 2                  |              |                       |
| 16               | 4 modules random  | 30 min | 2                  |              |                       |
| 17               | 3 modules random  | 20 min | 1                  |              |                       |
| 18               | 3 modules random  | 20 min | 1                  |              |                       |
| 19               | 5 modules random  | 30 min | 3                  |              |                       |
| 20               | 6 modules random  | 30 min | 3                  |              |                       |
| 21               | Les 7 modules !   | 30 min | 3                  |              |                       |
| 22               | Les 7 modules !   | 20 min | 3                  |              |                       |
| 23               | Les 7 modules !   | 10 min | 3                  |              |                       |
| 24               | Les 7 modules !   | 10 min | 1                  |              |                       |

# Les commandes de bases à savoir

- Lancer un script `bash`:
  `./<nom_script.sh>` _- Les scripts `bash` ont généralement une extension en `.sh`_
- Lister tous les fichiers : `ls`
- Se déplacer dans un répertoire de fichier :
  - `cd <nom_du_repertoire>` pour entrer dans le répertoire
  - `cd ..` pour remonter au répertoire d’au-dessus
- Pour afficher le contenu d’un fichier : `cat <nom_du_fichier>`

## En pratique

### Comment obtenir le jeu ?

1. Lancer un terminal
2. Naviguez dans vos dossiers avec `cd` jusqu’à l’endroit où vous souhaitez télécharger le jeu.
3. Entrer la commande suivante :  `git clone https://github.com/vrbq/unix-ktane`


### Comment lancer le jeu ?

1. Lancer un terminal.
2. Entrer dans le répertoire principal du jeu, appelé `unix-ktane`
3. Lancer le script `./start --level 0` pour démarrer au niveau 0.
   _(une fois le niveau réussi, passez au niveau 1 !)_

Si la bombe a bien été lancé, un message de confirmation apparaitra sur l’interface.

### Comment savoir combien de temps il me reste ?

1. Naviguez jusque dans répertoire principal `unix-ktane`
2. Afficher le contenu du fichier `time` avec la commande `cat`
