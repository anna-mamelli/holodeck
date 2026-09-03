# Notice d'installation et d'utilisation

Cette notice s'adresse à l'utilisateur final qui reçoit les deux machines virtuelles
exportées (`enterprise.ovf` et `holodeck.ovf`) et souhaite les faire fonctionner.

## 1. Installer VMware Workstation Pro

1. Créer un compte sur le portail Broadcom (support.broadcom.com).
2. Télécharger **VMware Workstation Pro** (gratuit pour un usage personnel) et l'installer
   avec les options par défaut. Redémarrer le PC si demandé.

## 2. Importer les machines virtuelles

1. `Fichier > Ouvrir...` → sélectionner `enterprise.ovf` → nommer la VM → **Import**.
   Si VMware signale un problème de conformité OVF, cliquer sur **Retry** (relâchement
   des contraintes) : l'import se poursuit normalement.
2. Répéter avec `holodeck.ovf`.

## 3. Vérifier le réseau (indispensable)

L'import peut perdre l'affectation des cartes. Contrôler :

| VM | Carte | Réglage attendu |
|---|---|---|
| enterprise | Network Adapter | **NAT** (accès internet, mises à jour) |
| enterprise | Network Adapter 2 | **LAN segment** `starfleet` |
| holodeck | Network Adapter | **LAN segment** `starfleet` (le même) |

Si le segment `starfleet` n'existe pas : `VM > Paramètres > Carte réseau > Segment LAN... > Ajouter`,
le créer, puis le sélectionner pour les deux cartes concernées.

## 4. Outils VMware

Les VM embarquent déjà les outils VMware (`open-vm-tools` sur le serveur,
`open-vm-tools-desktop` sur le client : presse-papiers partagé et glisser-déposer).

Pour les (ré)installer si nécessaire, dans la VM concernée, en root (`su -`) :

```
apt update
apt install -y open-vm-tools            # serveur (sans interface graphique)
apt install -y open-vm-tools-desktop    # client (avec bureau)
reboot
```

Vérification : `systemctl status open-vm-tools` (actif) et `vmware-toolbox-cmd -v`.

## 5. Démarrer

**Ordre impératif : le serveur d'abord.** C'est lui qui distribue les adresses (DHCP) et
résout les noms (DNS) du réseau `starfleet.lan`.

1. Démarrer `enterprise`, attendre l'invite `enterprise login:`.
2. Démarrer `holodeck`, ouvrir la session graphique.

## 6. Comptes

| Compte | Où | Usage |
|---|---|---|
| `root` | serveur (console) | administration complète — **sudo absent par design** (`su -`) |
| `natalia` | serveur + client + LDAP | session, SSH, authentification des sites web |
| `benahmed` | LDAP | second compte d'authentification web |
| `webmaster` | FTP uniquement | dépôt de fichiers web (pas de shell) |
| `cn=admin,dc=starfleet,dc=lan` | LDAP | administration de l'annuaire |
| `root`, `web` | MariaDB | administration SQL / accès des sites |

Les mots de passe sont fournis dans un document séparé, non versionné.

## 7. Utiliser et tester

Depuis **Firefox sur le client** (tout est en HTTPS, certificat interne Starfleet déjà
approuvé dans le navigateur) :

| URL | Attendu |
|---|---|
| https://www8.starfleet.lan | site en PHP 8.5 + version MariaDB |
| https://www7.starfleet.lan | site en PHP 7.4 |
| https://php.starfleet.lan | phpMyAdmin — identifiant LDAP demandé, puis compte SQL `web` |
| https://admin.starfleet.lan | administration du serveur (Cockpit) — LDAP puis `root` |
| https://vscore.starfleet.lan | Visual Studio Code Server — identifiant LDAP |

Dépôt de fichiers web : **FileZilla** sur le client → hôte `ftp.starfleet.lan`, port 21,
chiffrement *Connexion FTP explicite sur TLS*, utilisateur `webmaster`. L'utilisateur est
enfermé (chroot) dans `/var/www` : les fichiers déposés dans `www8/` sont servis sur
https://www8.starfleet.lan immédiatement.

Administration en ligne de commande : depuis le client, `ssh natalia@enterprise.starfleet.lan`
puis `su -`. Le SSH n'est accessible que depuis le LAN (pare-feu).

## 8. En cas de problème

| Symptôme | Vérification |
|---|---|
| Le client n'a pas d'adresse IP | serveur démarré ? les deux cartes sur le même LAN segment ? |
| Les URLs ne répondent pas | sur le serveur : `systemctl is-active nginx dnsmasq` |
| Avertissement de certificat | réimporter `starfleet-ca.crt` dans Firefox (Autorités) |
| FTP refuse la connexion | `systemctl is-active vsftpd` sur le serveur |
