#!/bin/bash
# Sauvegarde complete de la configuration du serveur enterprise
set -euo pipefail
DEST=/var/backups/holodeck
STAMP=$(date +%Y%m%d-%H%M)
WORK=$(mktemp -d)
mkdir -p "$DEST"

# Parametres reseau
ip -br a          > "$WORK/ip-addr.txt"
ip route          > "$WORK/ip-route.txt"
ufw status verbose > "$WORK/ufw-status.txt"

# Services et paquets installes
systemctl list-unit-files --state=enabled --no-pager > "$WORK/services-enabled.txt"
dpkg --get-selections                                > "$WORK/packages.txt"
cp -r /etc/apt/sources.list.d                        "$WORK/apt-sources"

# Configurations
tar czf "$WORK/etc.tar.gz" /etc 2>/dev/null || true
tar czf "$WORK/www.tar.gz" /var/www 2>/dev/null || true

# Donnees
mariadb-dump --all-databases --single-transaction > "$WORK/mariadb.sql"
slapcat -n 1                                      > "$WORK/ldap.ldif"

tar czf "$DEST/holodeck-$STAMP.tar.gz" -C "$WORK" .
rm -rf "$WORK"
find "$DEST" -name 'holodeck-*.tar.gz' -mtime +14 -delete
echo "Sauvegarde : $DEST/holodeck-$STAMP.tar.gz ($(du -h "$DEST/holodeck-$STAMP.tar.gz" | cut -f1))"
