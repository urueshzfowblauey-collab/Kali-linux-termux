#!/bin/bash

source "$(dirname "$0")/config.sh" 2>/dev/null || {
  declare -A TOOLS
  TOOLS["nmap"]=""
  TOOLS["sqlmap"]=""
  TOOLS["hydra"]=""
  TOOLS["nikto"]=""
  TOOLS["john"]=""
  TOOLS["aircrack-ng"]=""
  TOOLS["hashcat"]=""
  TOOLS["metasploit"]=""
  TOOLS["beef"]=""
  TOOLS["mr-ripper"]=""
}

R='\033[0;31m'
RB='\033[1;31m'
W='\033[1;37m'
D='\033[2;37m'
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
  echo -e "${W}        K A L I - T E R M U X${N}\n"
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

check_installed() {
  [ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ] && return 0
  return 1
}

download_kali() {
  clear
  show_ascii
  echo -e "${R}  [*]${W} Installation...${N}\n"
  echo -ne "  ${R}+${N} ${W}proot-distro${D}..."
  if ! command -v proot-distro &>/dev/null; then
    pkg install -y proot-distro &>/dev/null 2>&1
    command -v proot-distro &>/dev/null && echo -e " ${R}ok${N}" || { echo -e " ${W}échec${N}"; sleep 2; return 1; }
  else
    echo -e " ${R}ok${N}"
  fi
  progress_bar "Téléchargement de l'environnement"
  proot-distro install ubuntu
  progress_bar "Configuration"
  echo -e "\n  ${R}[✓]${W} Installé !${N}\n"
  sleep 1
}

launch_kali() {
  if ! check_installed; then
    echo -e "\n  ${W}[!]${R} Non installé. Choisis l'option d'installation.${N}"
    sleep 2; return
  fi
  clear
  show_ascii
  echo -e "  ${D}Connexion...${N}\n"
  proot-distro login ubuntu
  echo -e "\n  ${R}[*]${W} Session terminée.${N}"
  sleep 1
}

update_kali() {
  if ! check_installed; then
    echo -e "\n  ${W}[!]${R} Non installé.${N}"
    sleep 2; return
  fi
  clear
  show_ascii
  echo -e "${R}  [*]${W} Mise à jour...${N}\n"
  proot-distro login ubuntu -- bash -c "apt update && apt upgrade -y && apt autoremove -y"
  echo -e "\n  ${R}[✓]${W} Terminé.${N}"
  sleep 2
}

tools_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R}  ──────────────────────────────────${N}"
    echo -e "${W}         OUTILS${N}"
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
        echo -e "\n  ${R}[*]${W} Installation de ${R}${tool}${N}..."
        proot-distro login ubuntu -- bash -c "apt install -y ${tool}"
        echo -e "\n  ${R}[✓]${W} ${tool} installé${N}"
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
  echo -e "  ${R}help${N}    ${D}→${N}  cette aide"
  echo -e "  ${R}tools${N}   ${D}→${N}  menu outils"
  echo -e "  ${R}update${N}  ${D}→${N}  mise à jour"
  echo -e "  ${R}clear${N}   ${D}→${N}  effacer"
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
      *)      echo -e "\n  ${W}[!]${R} Invalide.${N}"; sleep 0.5 ;;
    esac
  done
}

install_menu() {
  clear
  show_ascii
  echo -e "${R}  ──────────────────────────────────${N}\n"
  echo -e "  ${R}[${W}1${R}]${N}  ${W}Installer Linux${N}"
  echo -e "\n${R}  ──────────────────────────────────${N}"
  echo -ne "\n  ${R}» ${W}"
  read -r OPT
  echo -ne "${N}"
  case "$OPT" in
    1) download_kali; main_menu ;;
    exit) exit 0 ;;
    *) echo -e "\n  ${W}[!]${R} Invalide.${N}"; sleep 1; install_menu ;;
  esac
}

clear
show_ascii

if ! check_installed; then
  install_menu
fi

main_menu
