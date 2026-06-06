#!/bin/bash

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
W='\033[1;37m'
D='\033[2;37m'
N='\033[0m'

echo -e "${R}╔══════════════════════════════════════╗${N}"
echo -e "${R}║ ${W}KaliTermux — Setup GitHub Push${R}   ║${N}"
echo -e "${R}╚══════════════════════════════════════╝${N}\n"

echo -ne "${Y}[?] Pseudo GitHub : ${W}"; read -r GH_USER
echo -ne "${Y}[?] Email GitHub  : ${W}"; read -r GH_EMAIL
echo -ne "${Y}[?] Nom du repo   : ${W}"; read -r GH_REPO
echo -ne "${N}"

echo -e "\n${G}[1/5] Installation de git...${N}"
pkg install git -y &>/dev/null \
  && echo -e "${G} ✓ git OK${N}" \
  || echo -e "${R} ✗ échec${N}"

echo -e "${G}[2/5] Configuration git...${N}"
git config --global user.name  "$GH_USER"
git config --global user.email "$GH_EMAIL"
echo -e "${G} ✓ identité configurée${N}"

echo -e "${G}[3/5] Initialisation du repo local...${N}"
cd "$(dirname "$0")"
git init
git add kali.sh config.sh README.md setup_github.sh
git commit -m "first commit — KaliTermux v1.0"
git branch -M main
echo -e "${G} ✓ commit initial créé${N}"

echo -e "${G}[4/5] Ajout du remote origin...${N}"
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/${GH_USER}/${GH_REPO}.git"
echo -e "${G} ✓ remote: https://github.com/${GH_USER}/${GH_REPO}.git${N}"

echo -e "\n${R}╔══════════════════════════════════════╗${N}"
echo -e "${R}║ ${W}AVANT DE CONTINUER${R}               ║${N}"
echo -e "${R}╠══════════════════════════════════════╣${N}"
echo -e "${R}║ ${Y}1.${W} Va sur github.com/new           ${R}║${N}"
echo -e "${R}║ ${Y}2.${W} Crée le repo : ${G}${GH_REPO}${R}"
echo -e "${R}║ ${Y}3.${W} Public, SANS README ni .gitignore${R}║${N}"
echo -e "${R}║ ${Y}4.${W} Génère un token :               ${R}║${N}"
echo -e "${R}║    ${D}Settings > Developer settings    ${R}║${N}"
echo -e "${R}║    ${D}> Tokens (classic) > repo        ${R}║${N}"
echo -e "${R}╚══════════════════════════════════════╝${N}"

echo -ne "\n${Y}[?] Repo créé + token prêt ? [o/N] : ${W}"; read -r READY
echo -ne "${N}"

if [[ "$READY" =~ ^[oO]$ ]]; then
  echo -e "\n${G}[5/5] Push vers GitHub...${N}"
  echo -e "${D} (entre ton token GitHub quand demandé)${N}\n"
  git push -u origin main
  if [ $? -eq 0 ]; then
    echo -e "\n${G}╔══════════════════════════════════════╗${N}"
    echo -e "${G}║  ✓ Push réussi !                     ║${N}"
    echo -e "${G}║  → github.com/${GH_USER}/${GH_REPO}${N}"
    echo -e "${G}╚══════════════════════════════════════╝${N}"
    sed -i "s|https://github.com/kyaev/kali-termux|https://github.com/${GH_USER}/${GH_REPO}|g" config.sh
  else
    echo -e "\n${R} ✗ Push échoué. Vérifie ton token et que le repo existe.${N}"
  fi
else
  echo -e "\n${Y} Lance ce script à nouveau quand tu es prêt.${N}"
  echo -e " ${D}Push manuel : ${W}git push -u origin main${N}"
fi
