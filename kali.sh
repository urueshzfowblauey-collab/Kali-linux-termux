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
  TOOLS["metasploit-framework"]=""
  TOOLS["beef-xss"]=""
  TOOLS["gobuster"]=""
  TOOLS["dirb"]=""
  TOOLS["netcat-openbsd"]=""
}

TOOL_ORDER=("nmap" "sqlmap" "hydra" "nikto" "john" "aircrack-ng" "hashcat" "metasploit-framework" "beef-xss" "gobuster" "dirb" "netcat-openbsd")

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
  echo -e "${W} K A L I - T E R M U X${N}\n"
}

progress_bar() {
  local label="$1"
  local total=30
  echo -ne "\n ${W}${label}${N}\n ${R}["
  for ((i=0; i<total; i++)); do
    sleep 0.02
    echo -ne "${R}█"
  done
  echo -e "${W}] ${R}OK${N}"
}

check_installed() {
  proot-distro list 2>&1 | grep -q "ubuntu"
}

check_proot() {
  if ! command -v proot-distro &>/dev/null; then
    pkg install proot-distro -y
    command -v proot-distro &>/dev/null || return 1
  fi
  return 0
}

download_kali() {
  clear
  show_ascii
  check_proot || return 1
  if check_installed; then
    sleep 1
    return 0
  fi
  progress_bar "Téléchargement de l'environnement"
  proot-distro install ubuntu
  if ! check_installed; then
    echo -e "\n ${R}[✗] Installation échouée. Vérifie ta connexion.${N}"
    return 1
  fi
  progress_bar "Finalisation"
  sleep 1
  return 0
}

get_sys_info() {
  local ip os kernel ram disk
  ip=$(proot-distro login ubuntu -- bash -c "hostname -I 2>/dev/null | awk '{print \$1}'" 2>/dev/null)
  os=$(proot-distro login ubuntu -- bash -c "grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'\"' -f2" 2>/dev/null)
  kernel=$(proot-distro login ubuntu -- bash -c "uname -r 2>/dev/null" 2>/dev/null)
  ram=$(proot-distro login ubuntu -- bash -c "free -m 2>/dev/null | awk '/Mem:/{print \$2\" MB / \"\$3\" MB\"}'" 2>/dev/null)
  disk=$(proot-distro login ubuntu -- bash -c "df -h / 2>/dev/null | awk 'NR==2{print \$4\" / \"\$2}'" 2>/dev/null)
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} INFOS SYSTÈME${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -e " ${R}OS     ${N}${W}${os:-inconnu}${N}"
  echo -e " ${R}Kernel ${N}${W}${kernel:-inconnu}${N}"
  echo -e " ${R}IP     ${N}${W}${ip:-non disponible}${N}"
  echo -e " ${R}RAM    ${N}${W}${ram:-inconnu}${N}"
  echo -e " ${R}Disk   ${N}${W}${disk:-inconnu}${N}"
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"
  read -r
}

linux_tools_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} OUTILS — LANCER${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"
    local idx=1
    for tool in "${TOOL_ORDER[@]}"; do
      echo -e " ${R}[${W}${idx}${R}]${N} ${W}${tool}${N}"
      idx=$((idx+1))
    done
    echo -e "\n ${R}[${W}b${R}]${N} ${D}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r CHOICE
    echo -ne "${N}"
    [[ "$CHOICE" == "b" || "$CHOICE" == "B" ]] && return
    [[ ! "$CHOICE" =~ ^[0-9]+$ ]] && continue
    local i=1
    for tool in "${TOOL_ORDER[@]}"; do
      if [[ "$i" -eq "$CHOICE" ]]; then
        local installed
        installed=$(proot-distro login ubuntu -- bash -c "command -v ${tool} 2>/dev/null")
        if [[ -z "$installed" ]]; then
          proot-distro login ubuntu -- bash -c "apt update -qq && apt install -y ${tool}"
        fi
        proot-distro login ubuntu -- bash -c "${tool}"
        echo -ne "\n ${D}Entrée...${N}"
        read -r
        break
      fi
      i=$((i+1))
    done
  done
}

linux_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} SESSION LINUX${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Shell libre${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Lancer un outil${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Infos système${N}"
    echo -e " ${R}[${W}4${R}]${N} ${W}Passer en user${N}"
    echo -e " ${R}[${W}5${R}]${N} ${W}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1)
        clear; show_ascii
        proot-distro login ubuntu
        ;;
      2) linux_tools_menu ;;
      3) get_sys_info ;;
      4)
        clear; show_ascii
        proot-distro login ubuntu --user ubuntu 2>/dev/null || \
          proot-distro login ubuntu -- bash -c "id ubuntu &>/dev/null && su - ubuntu || bash"
        ;;
      5|exit) return ;;
      *) sleep 0.5 ;;
    esac
  done
}

update_kali() {
  check_proot || return
  check_installed || return
  clear
  show_ascii
  proot-distro login ubuntu -- bash -c "apt update && apt upgrade -y && apt autoremove -y"
  sleep 2
}

tools_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} INSTALLER UN OUTIL${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"
    check_installed || { sleep 2; return; }
    local idx=1
    for tool in "${TOOL_ORDER[@]}"; do
      echo -e " ${R}[${W}${idx}${R}]${N} ${W}${tool}${N}"
      idx=$((idx+1))
    done
    echo -e "\n ${R}[${W}b${R}]${N} ${D}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r CHOICE
    echo -ne "${N}"
    [[ "$CHOICE" == "b" || "$CHOICE" == "B" ]] && return
    [[ ! "$CHOICE" =~ ^[0-9]+$ ]] && continue
    local i=1
    for tool in "${TOOL_ORDER[@]}"; do
      if [[ "$i" -eq "$CHOICE" ]]; then
        proot-distro login ubuntu -- bash -c "apt update -qq && apt install -y ${tool}"
        echo -ne "\n ${D}Entrée...${N}"
        read -r
        break
      fi
      i=$((i+1))
    done
  done
}

help_cmd() {
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -e "${W} COMMANDES${N}"
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e " ${R}1${N}      ${D}→${N} Lancer Linux"
  echo -e " ${R}2${N}      ${D}→${N} Mettre à jour"
  echo -e " ${R}3${N}      ${D}→${N} Quitter"
  echo -e " ${R}tools${N}  ${D}→${N} Installer des outils"
  echo -e " ${R}help${N}   ${D}→${N} Cette aide"
  echo -e " ${R}clear${N}  ${D}→${N} Effacer"
  echo -e " ${R}exit${N}   ${D}→${N} Quitter"
  echo -e "${R} ──────────────────────────────────${N}\n"
}

main_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Lancer Linux${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Mettre à jour${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1)     check_proot && check_installed && linux_menu || sleep 2 ;;
      2)     update_kali ;;
      3)     clear; show_ascii; echo -e "\n ${D}À bientôt.${N}\n"; exit 0 ;;
      tools) tools_menu ;;
      help)  help_cmd; echo -ne " ${D}Entrée...${N}"; read -r ;;
      clear) clear ;;
      exit)  exit 0 ;;
      *)     sleep 0.5 ;;
    esac
  done
}

install_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Installer Linux${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1)
        download_kali && main_menu && return
        ;;
      2|exit) exit 0 ;;
      *) sleep 0.8 ;;
    esac
  done
}

clear
show_ascii
check_proot
if check_installed; then
  main_menu
else
  install_menu
fi
