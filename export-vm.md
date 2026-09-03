# Procédure d'exportation des machines virtuelles

Cette procédure produit, pour chaque VM, un ensemble de fichiers OVF transportables sur
n'importe quel poste équipé de VMware.

## 1. Préparer les VM

1. Se connecter à chaque VM et l'éteindre proprement :
   - serveur `enterprise` : `su -` puis `poweroff`
   - client `holodeck` : menu → Déconnexion → Éteindre (ou `poweroff` en root)
2. Dans VMware, pour **chaque** VM : `VM > Paramètres > CD/DVD (SATA)` :
   - sélectionner *Utiliser le lecteur physique* (pour ne plus pointer vers l'ISO Debian),
   - décocher *Se connecter lors de la mise sous tension*.
   Sans cela, l'ISO peut être embarqué dans l'export ou réclamé à l'import.

## 2. Exporter

Pour chaque VM, sélectionnée dans la bibliothèque (éteinte) :

1. `Fichier > Exporter au format OVF...`
2. Choisir le dossier de destination et le nom : `enterprise.ovf` puis `holodeck.ovf`.
3. Patienter (plusieurs minutes par VM, selon le disque).

## 3. Fichiers produits

| Fichier | Rôle |
|---|---|
| `enterprise.ovf` | descripteur XML : matériel virtuel (CPU, RAM, cartes, disque) |
| `enterprise-disk1.vmdk` | image du disque (32 Go provisionnés, fichier réel plus petit) |
| `enterprise.mf` | sommes de contrôle SHA des deux fichiers ci-dessus |

Même trio pour `holodeck` (disque 16 Go provisionnés).

## 4. Vérification

- Le `.mf` permet à VMware de vérifier l'intégrité à l'import.
- Test réalisé : ré-import des deux OVF sur le même poste (`Fichier > Ouvrir`), démarrage,
  et exécution des tests de la notice utilisateur — concluant.

Taille obtenue : 24 Ko (`enterprise` = 12,4 Ko, `holodeck` = 11,6 Ko).

