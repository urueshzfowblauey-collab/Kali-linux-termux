#!/bin/bash

source "$(dirname "$0")/config.sh" 2>/dev/null || {
  KALI_DIR="$HOME/kali-fs"
  declare -A TOOLS
  TOOLS["nmap"]="https://github.com/nmap/nmap"
  TOOLS["sqlmap"]="https://github.com/sqlmapproject/sqlmap"
  TOOLS["hydra"]="https://github.com/vanhauser-thc/thc-hydra"
  TOOLS["nikto"]="https://github.com/sullo/nikto"
  TOOLS["john"]="https://github.com/openwall/john"
  TOOLS["mr-ripper"]=""
}

R='\033[0;31m'
RB='\033[1;31m'
W='\033[1;37m'
D='\033[2;37m'
G='\033[0;32m'
N='\033[0m'

trap "echo -e '${N}'; exit" INT TERM

show_ascii() {
  echo -e "${RB}"
  echo "⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣦⣤⣄⣈⡑⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮⣷⣤⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯⣧⡀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢷⡤⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣯⡛⠻⢦⡀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣆⠀⠙⢆⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣆⠀⠈⢣"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⡆⠀⠈"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀"
  echo -e "${N}"
  echo -e "${W}        K A L I - T E R M U X   T O O L S${N}"
  echo -e "${D}              by LinuxKyaev  •  v2.0${N}\n"
}

progress_bar() {
  local label="$1"
  local total=35
  echo -ne "\n  ${W}${label}${N}\n  ${R}["
  for ((i=0; i<total; i++)); do
    sleep 0.05
    echo -ne "${R}█"
  done
  echo -e "${W}]  ${R}OK${N}"
  sleep 0.3
}

install_deps() {
  echo -e "\n${R}  [*]${W} Vérification des dépendances...${N}\n"
  local deps=("proot-distro" "wget" "curl" "git")
  for dep in "${deps[@]}"; do
    echo -ne "  ${R}+${N} ${W}${dep}${D}..."
    if command -v "$dep" &>/dev/null; then
      echo -e " ${R}ok${N}"
    else
      pkg install -y "$dep" &>/dev/null 2>&1
      command -v "$dep" &>/dev/null && echo -e " ${R}installé${N}" || echo -e " ${W}échec${N}"
    fi
  done
  echo
}

download_kali() {
  clear
  show_ascii
  echo -e "${R}  [*]${W} Installation de l'environnement Linux...${N}\n"
  install_deps
  echo -e "  ${R}[*]${W} Téléchargement via proot-distro...${N}\n"
  progress_bar "Téléchargement en cours"
  proot-distro install ubuntu
  echo -e "\n  ${R}[✓]${W} Environnement installé !${N}\n"
  echo -e "  ${D}Lance l'option 1 pour démarrer.${N}\n"
  sleep 1
}

check_installed() {
  proot-distro list 2>/dev/null | grep -q "ubuntu" && return 0
  # fallback check
  [ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ] && return 0
  return 1
}

launch_kali() {
  if ! check_installed; then
    echo -e "\n  ${W}[!]${R} Environnement non installé.${N}"
    echo -e "  ${D}Lance l'option depuis le menu principal.${N}"
    sleep 2; return
  fi

  clear
  show_ascii
  echo -e "  ${D}Connexion en cours...${N}\n"
  proot-distro login ubuntu

  echo -e "\n  ${R}[*]${W} Session terminée.${N}"
  sleep 1
}

update_kali() {
  if ! check_installed; then
    echo -e "\n  ${W}[!]${R} Environnement non installé.${N}"
    sleep 2; return
  fi
  clear
  show_ascii
  echo -e "${R}  [*]${W} Mise à jour...${N}\n"
  proot-distro login ubuntu -- bash -c "apt update && apt upgrade -y && apt autoremove -y"
  echo -e "\n  ${R}[✓]${W} Mise à jour terminée.${N}"
  sleep 2
}

tools_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R}  ──────────────────────────────────${N}"
    echo -e "${W}         MENU DES TOOLS${N}"
    echo -e "${R}  ──────────────────────────────────${N}\n"

    local idx=1
    local tool_keys=()
    for tool in "${!TOOLS[@]}"; do
      tool_keys+=("$tool")
    done

    for tool in "${tool_keys[@]}"; do
      echo -e "  ${R}[${W}${idx}${R}]${N}  ${W}${tool}${N}"
      idx=$((idx+1))
    done
    echo -e "  ${R}[${W}b${R}]${N}  ${D}Retour${N}"
    echo -e "\n${R}  ──────────────────────────────────${N}"
    echo -ne "\n  ${R}» ${W}"
    read -r CHOICE
    echo -ne "${N}"

    [ "$CHOICE" = "b" ] || [ "$CHOICE" = "B" ] && return

    local idx=1
    for tool in "${tool_keys[@]}"; do
      if [ "$idx" -eq "$CHOICE" ] 2>/dev/null; then
        local url="${TOOLS[$tool]}"
        echo -e "\n  ${R}[*]${W} Installation de ${R}${tool}${N} dans Ubuntu..."
        if [ -n "$url" ]; then
          proot-distro login ubuntu -- bash -c "apt install -y ${tool} 2>/dev/null || git clone ${url} /root/tools/${tool}"
          echo -e "\n  ${R}[✓]${W} ${tool} installé${N}"
        else
          echo -e "  ${W}[!]${R} Aucun dépôt pour ${tool}.${N}"
          echo -e "  ${D}    Modifie config.sh pour ajouter le lien.${N}"
        fi
        echo -ne "\n  ${D}[Entrée]${N}"
        read -r
        break
      fi
      idx=$((idx+1))
    done
  done
}

help_cmd() {
  echo -e "\n${R}  ──────────────────────────────────${N}"
  echo -e "${W}  COMMANDES${N}"
  echo -e "${R}  ──────────────────────────────────${N}"
  echo -e "  ${R}help${N}    ${D}→${N}  afficher cette aide"
  echo -e "  ${R}tools${N}   ${D}→${N}  menu des tools"
  echo -e "  ${R}update${N}  ${D}→${N}  mettre à jour"
  echo -e "  ${R}clear${N}   ${D}→${N}  effacer l'écran"
  echo -e "  ${R}exit${N}    ${D}→${N}  quitter"
  echo -e "${R}  ──────────────────────────────────${N}\n"
}

main_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R}  ──────────────────────────────────${N}\n"
    echo -e "  ${R}[${W}1${R}]${N}  ${W}Lancer Linux${N}"
    echo -e "  ${R}[${W}2${R}]${N}  ${W}Mettre à jour${N}"
    echo -e "  ${R}[${W}3${R}]${N}  ${W}Sortir${N}"
    echo -e "\n${R}  ──────────────────────────────────${N}"
    echo -ne "\n  ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"

    case "$OPT" in
      1) launch_kali ;;
      2) update_kali ;;
      3) clear; show_ascii; echo -e "\n  ${D}À bientôt.${N}\n"; exit 0 ;;
      help)   help_cmd; echo -ne "  ${D}[Entrée]${N}"; read -r ;;
      tools)  tools_menu ;;
      update) update_kali ;;
      clear)  clear ;;
      exit)   exit 0 ;;
      *)      echo -e "\n  ${W}[!]${R} Commande invalide.${N}"; sleep 0.5 ;;
    esac
  done
}

install_menu() {
  clear
  show_ascii
  echo -e "${R}  ──────────────────────────────────${N}\n"
  echo -e "  ${R}[${W}1${R}]${N}  ${W}Installer l'environnement Linux${N}"
  echo -e "\n${R}  ──────────────────────────────────${N}"
  echo -ne "\n  ${R}» ${W}"
  read -r OPT
  echo -ne "${N}"
  case "$OPT" in
    1) download_kali; main_menu ;;
    exit) exit 0 ;;
    *) echo -e "\n  ${W}[!]${R} Option invalide.${N}"; sleep 1; install_menu ;;
  esac
}

# ── Démarrage ──────────────────────────────────────────
clear
show_ascii

if ! check_installed; then
  install_menu
fi

main_menu
