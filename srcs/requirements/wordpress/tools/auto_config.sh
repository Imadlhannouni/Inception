#!/bin/bash
set -e

echo "⏳ Waiting for MariaDB..."
until mysql -h"$SQL_HOST" -u"$SQL_USER" -p"$SQL_PASSWORD" "$SQL_DATABASE" &>/dev/null; do
  sleep 1
done
echo "✅ MariaDB ready"

cd /var/www/wordpress

# ÉTAPE MANQUANTE : Télécharger les fichiers si le dossier est vide
if [ ! -f wp-config.php ]; then
  echo "📥 Downloading WordPress core..."
  wp core download --allow-root

  echo "⚙️ Creating wp-config.php..."
  wp config create \
    --dbname="$SQL_DATABASE" \
    --dbuser="$SQL_USER" \
    --dbpass="$SQL_PASSWORD" \
    --dbhost="$SQL_HOST" \
    --allow-root

  echo "🚀 Installing WordPress..."
  wp core install \
    --url="https://$DOMAIN_NAME" \
    --title="Inception" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  echo "👤 Creating secondary user..."
  wp user create \
    "$WP_USER" "$WP_USER_EMAIL" \
    --role=author \
    --user_pass="$WP_USER_PASSWORD" \
    --allow-root
fi

# S'assurer que les permissions sont correctes pour php-fpm
chown -R www-data:www-data /var/www/wordpress

exec "$@"