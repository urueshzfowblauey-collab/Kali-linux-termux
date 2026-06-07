#!/bin/bash

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
W='\033[1;37m'
D='\033[2;37m'
N='\033[0m'

echo -e "${R}╔══════════════════════════════════════╗${N}"
echo -e "${R}║ ${W}KaliTermux — Setup GitHub Push    ${R}║${N}"
echo -e "${R}╚══════════════════════════════════════╝${N}\n"
echo -ne "${Y}[?] Pseudo GitHub : ${W}"
read -r GH_USER
echo -ne "${Y}[?] Email GitHub : ${W}"
read -r GH_EMAIL
echo -ne "${Y}[?] Nom du repo : ${W}"
read -r GH_REPO
echo -ne "${N}"

[[ -z "$GH_USER" || -z "$GH_EMAIL" || -z "$GH_REPO" ]] && echo -e "\n${R}[✗] Champs vides.${N}" && exit 1

pkg install git -y &>/dev/null || { echo -e "${R}[✗] git échec${N}"; exit 1; }

git config --global user.name "$GH_USER"
git config --global user.email "$GH_EMAIL"

cd "$(dirname "$0")" || exit 1
[ ! -d ".git" ] && git init

for f in kali.sh config.sh setup_github.sh backup.sh update.sh; do
  [ -f "$f" ] && git add "$f"
done
[ -f README.md ] && git add README.md

git commit -m "KaliTermux v1.0" 2>/dev/null || git commit --allow-empty -m "update"
git branch -M main
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/${GH_USER}/${GH_REPO}.git"

echo -e "\n${R}╔══════════════════════════════════════╗${N}"
echo -e "${R}║ ${Y}1.${W} github.com/new                  ${R}║${N}"
echo -e "${R}║ ${Y}2.${W} Crée : ${G}${GH_REPO}${R}"
echo -e "${R}║ ${Y}3.${W} Public, sans README              ${R}║${N}"
echo -e "${R}║ ${Y}4.${W} Settings > Tokens (classic)      ${R}║${N}"
echo -e "${R}╚══════════════════════════════════════╝${N}"
echo -ne "\n${Y}[?] Repo créé + token prêt ? [o/N] : ${W}"
read -r READY
echo -ne "${N}"

if [[ "$READY" =~ ^[oO]$ ]]; then
  git push -u origin main
  if [[ $? -eq 0 ]]; then
    echo -e "\n${G}╔══════════════════════════════════════╗${N}"
    echo -e "${G}║  ✓ Push réussi !                     ║${N}"
    echo -e "${G}║  → github.com/${GH_USER}/${GH_REPO}${N}"
    echo -e "${G}╚══════════════════════════════════════╝${N}"
  else
    echo -e "\n${R}[✗] Push échoué.${N}"
    echo -e " ${W}· Repo existe ? Token scope 'repo' ?${N}"
    echo -e " ${W}· Réessaie : ${G}git push -u origin main${N}"
  fi
else
  echo -e "\n${D}Pour push plus tard : ${W}git push -u origin main${N}"
fi
