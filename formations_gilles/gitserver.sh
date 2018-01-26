#! /bin/bash
set -e -o pipefail

# Mise en place d'un serveur git avec :
# - installation du paquet
# - ajout d'un utilisateur git
# - déploiement de la clé SSH voulue pour l'utilisateur
# - création d'un dépôt nu ~git/formation.git

# Le script doit être lancé en root
if [ $UID -ne 0 ]; then
	echo "Il faut lancer le programme en root."
	exit 1
fi

# Vérification paramètres
if [ -z "$1" ]; then
	depot=formation
else
	depot=$1
fi

# On suppose qu'on est sur une Debian
# -y : yes
# -q : silence
# Si git est installé, dpkg renvoie 0 et on continue
# Sinon => install
dpkg -l git || apt-get install -yq git

# Création de l'utilisateur en silence
# Si l'utilisateur existe, getent va renvoyer 0 et useradd ne se fera pas
# S'il n'existe pas, getent renverra 1 (ou +), et useradd se fera
getent passwd git || useradd -m git

# Création du répertoire .ssh s'il n'existe pas
if [ ! -d ~git/.ssh ]; then
	mkdir -p ~git/.ssh
fi

# Copie des clés autorisées pour root pour git
cp /root/.ssh/authorized_keys ~git/.ssh/authorized_keys

# Gestion des droits et permissions
chown -R git: ~git/.ssh
chmod 600 ~git/.ssh/authorized_keys
chmod 700 ~git/.ssh

# Boucle sur les paramètres passés
if [ $# -ge 1 ]; then
	for param in "$@"; do
		# Exécution par l'utilisateur git de la création du dépôt
		if [ ! -d "/home/git/${param}.git" ]; then
			su git -c "git init --bare ~git/${param}.git"
		fi
	done
else
	if [ ! -d "/home/git/${depot}.git" ]; then
		su git -c "git init --bare ~git/${depot}.git"
	fi

fi
