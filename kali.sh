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
  TOOLS["wfuzz"]=""
  TOOLS["netcat-openbsd"]=""
  TOOLS["curl"]=""
  TOOLS["wget"]=""

  declare -A TOOL_BIN
  TOOL_BIN["nmap"]="nmap"
  TOOL_BIN["sqlmap"]="sqlmap"
  TOOL_BIN["hydra"]="hydra"
  TOOL_BIN["nikto"]="nikto"
  TOOL_BIN["john"]="john"
  TOOL_BIN["aircrack-ng"]="aircrack-ng"
  TOOL_BIN["hashcat"]="hashcat"
  TOOL_BIN["metasploit-framework"]="msfconsole"
  TOOL_BIN["beef-xss"]="beef"
  TOOL_BIN["gobuster"]="gobuster"
  TOOL_BIN["dirb"]="dirb"
  TOOL_BIN["wfuzz"]="wfuzz"
  TOOL_BIN["netcat-openbsd"]="nc"
  TOOL_BIN["curl"]="curl"
  TOOL_BIN["wget"]="wget"

  TOOL_ORDER=("nmap" "sqlmap" "hydra" "nikto" "john" "aircrack-ng" "hashcat" "metasploit-framework" "beef-xss" "gobuster" "dirb" "wfuzz" "netcat-openbsd" "curl" "wget")
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

editor_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} ÉDITEUR DE TEXTE${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}nano${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}vim${N}"
    echo -e "\n ${R}[${W}b${R}]${N} ${D}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1)
        echo -ne "\n ${W}Fichier à ouvrir (vide = nouveau) : ${N}"
        read -r FICHIER
        proot-distro login ubuntu -- bash -c "apt install -y nano -qq && nano ${FICHIER}"
        ;;
      2)
        echo -ne "\n ${W}Fichier à ouvrir (vide = nouveau) : ${N}"
        read -r FICHIER
        proot-distro login ubuntu -- bash -c "apt install -y vim -qq && vim ${FICHIER}"
        ;;
      b|B) return ;;
      *) sleep 0.5 ;;
    esac
  done
}

logs_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} LOGS & HISTORIQUE${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Historique des commandes${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Logs système (syslog)${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Logs auth${N}"
    echo -e " ${R}[${W}4${R}]${N} ${W}Vider l'historique${N}"
    echo -e "\n ${R}[${W}b${R}]${N} ${D}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1)
        proot-distro login ubuntu -- bash -c "cat ~/.bash_history 2>/dev/null || echo 'Vide'"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      2)
        proot-distro login ubuntu -- bash -c "cat /var/log/syslog 2>/dev/null | tail -50 || echo 'Non disponible'"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      3)
        proot-distro login ubuntu -- bash -c "cat /var/log/auth.log 2>/dev/null | tail -50 || echo 'Non disponible'"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      4)
        proot-distro login ubuntu -- bash -c "cat /dev/null > ~/.bash_history && echo 'Historique vidé'"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      b|B) return ;;
      *) sleep 0.5 ;;
    esac
  done
}

security_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} SÉCURITÉ RAPIDE${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Scan réseau local${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Scan ports (IP)${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Ping host${N}"
    echo -e " ${R}[${W}4${R}]${N} ${W}Traceroute${N}"
    echo -e " ${R}[${W}5${R}]${N} ${W}Infos interface réseau${N}"
    echo -e "\n ${R}[${W}b${R}]${N} ${D}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1)
        proot-distro login ubuntu -- bash -c "apt install -y nmap -qq && nmap -sn 192.168.1.0/24"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      2)
        echo -ne "\n ${W}IP cible : ${N}"
        read -r TARGET
        proot-distro login ubuntu -- bash -c "apt install -y nmap -qq && nmap -sV ${TARGET}"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      3)
        echo -ne "\n ${W}Host : ${N}"
        read -r TARGET
        proot-distro login ubuntu -- bash -c "ping -c 4 ${TARGET}"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      4)
        echo -ne "\n ${W}Host : ${N}"
        read -r TARGET
        proot-distro login ubuntu -- bash -c "apt install -y traceroute -qq && traceroute ${TARGET}"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      5)
        proot-distro login ubuntu -- bash -c "ip a"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      b|B) return ;;
      *) sleep 0.5 ;;
    esac
  done
}

update_tools_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} METTRE À JOUR LES OUTILS${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"
    local idx=1
    for tool in "${TOOL_ORDER[@]}"; do
      echo -e " ${R}[${W}${idx}${R}]${N} ${W}${tool}${N}"
      idx=$((idx+1))
    done
    echo -e " ${R}[${W}a${R}]${N} ${W}Tous les outils${N}"
    echo -e "\n ${R}[${W}b${R}]${N} ${D}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r CHOICE
    echo -ne "${N}"
    [[ "$CHOICE" == "b" || "$CHOICE" == "B" ]] && return
    if [[ "$CHOICE" == "a" || "$CHOICE" == "A" ]]; then
      for tool in "${TOOL_ORDER[@]}"; do
        proot-distro login ubuntu -- bash -c "apt install -y --only-upgrade ${tool} 2>/dev/null"
      done
      echo -ne "\n ${D}Entrée...${N}"; read -r
      continue
    fi
    [[ ! "$CHOICE" =~ ^[0-9]+$ ]] && continue
    local i=1
    for tool in "${TOOL_ORDER[@]}"; do
      if [[ "$i" -eq "$CHOICE" ]]; then
        proot-distro login ubuntu -- bash -c "apt install -y --only-upgrade ${tool}"
        echo -ne "\n ${D}Entrée...${N}"; read -r
        break
      fi
      i=$((i+1))
    done
  done
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
        local bin="${TOOL_BIN[$tool]:-$tool}"
        proot-distro login ubuntu -- bash -c \
          "command -v '${bin}' &>/dev/null || apt install -y '${tool}' -qq" 2>/dev/null
        proot-distro login ubuntu -- bash -c "${bin}"
        echo -ne "\n ${D}Entrée...${N}"
        read -r
        break
      fi
      i=$((i+1))
    done
  done
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
    echo -e " ${R}[${W}5${R}]${N} ${W}Éditeur de texte${N}"
    echo -e " ${R}[${W}6${R}]${N} ${W}Logs & historique${N}"
    echo -e " ${R}[${W}7${R}]${N} ${W}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1) clear; show_ascii; proot-distro login ubuntu ;;
      2) linux_tools_menu ;;
      3) get_sys_info ;;
      4)
        clear; show_ascii
        proot-distro login ubuntu --user ubuntu 2>/dev/null || \
          proot-distro login ubuntu -- bash -c "id ubuntu &>/dev/null && su - ubuntu || bash"
        ;;
      5) editor_menu ;;
      6) logs_menu ;;
      7|exit) return ;;
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

reset_kali() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} RÉINITIALISER LINUX${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -e " ${R}[!]${N} ${W}Toutes les données seront perdues.${N}"
  echo -ne "\n ${W}Confirmer ? [o/N] : ${N}"
  read -r CONFIRM
  if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
    proot-distro reset ubuntu
    progress_bar "Réinitialisation"
    sleep 1
  fi
}

remove_kali() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} DÉSINSTALLER LINUX${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -e " ${R}[!]${N} ${W}Linux sera complètement supprimé.${N}"
  echo -ne "\n ${W}Confirmer ? [o/N] : ${N}"
  read -r CONFIRM
  if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
    proot-distro remove ubuntu
    progress_bar "Désinstallation"
    sleep 1
    install_menu
  fi
}

run_backup() {
  local BACKUP_SCRIPT
  BACKUP_SCRIPT="$(dirname "$0")/backup.sh"
  if [[ -f "$BACKUP_SCRIPT" ]]; then
    bash "$BACKUP_SCRIPT"
  else
    echo -e "\n ${R}[✗] backup.sh introuvable.${N}"
    sleep 2
  fi
}

run_pass() {
  local PASS_SCRIPT
  PASS_SCRIPT="$(dirname "$0")/pass.sh"
  if [[ -f "$PASS_SCRIPT" ]]; then
    bash "$PASS_SCRIPT"
  else
    echo -e "\n ${R}[✗] pass.sh introuvable.${N}"
    sleep 2
  fi
}

run_clean() {
  local CLEAN_SCRIPT
  CLEAN_SCRIPT="$(dirname "$0")/clean.sh"
  if [[ -f "$CLEAN_SCRIPT" ]]; then
    bash "$CLEAN_SCRIPT"
  else
    echo -e "\n ${R}[✗] clean.sh introuvable.${N}"
    sleep 2
  fi
}

run_doctor() {
  local DOCTOR_SCRIPT
  DOCTOR_SCRIPT="$(dirname "$0")/doctor.sh"
  if [[ -f "$DOCTOR_SCRIPT" ]]; then
    bash "$DOCTOR_SCRIPT"
  else
    echo -e "\n ${R}[✗] doctor.sh introuvable.${N}"
    sleep 2
  fi
}

run_exercice() {
  local EXERCICE_SCRIPT
  EXERCICE_SCRIPT="$(dirname "$0")/exercice.sh"
  if [[ -f "$EXERCICE_SCRIPT" ]]; then
    bash "$EXERCICE_SCRIPT"
  else
    echo -e "\n ${R}[✗] exercice.sh introuvable.${N}"
    sleep 2
  fi
}

run_vpn() {
  local VPN_SCRIPT
  VPN_SCRIPT="$(dirname "$0")/vpn.sh"
  if [[ -f "$VPN_SCRIPT" ]]; then
    bash "$VPN_SCRIPT"
  else
    echo -e "\n ${R}[✗] vpn.sh introuvable.${N}"
    sleep 2
  fi
}

help_cmd() {
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -e "${W} COMMANDES${N}"
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e " ${R}1${N}  ${D}→${N} Lancer Linux"
  echo -e " ${R}2${N}  ${D}→${N} Mettre à jour Linux"
  echo -e " ${R}3${N}  ${D}→${N} Mettre à jour les outils"
  echo -e " ${R}4${N}  ${D}→${N} Installer un outil"
  echo -e " ${R}5${N}  ${D}→${N} Infos système"
  echo -e " ${R}6${N}  ${D}→${N} Sécurité rapide"
  echo -e " ${R}7${N}  ${D}→${N} Réinitialiser Linux"
  echo -e " ${R}8${N}  ${D}→${N} Désinstaller Linux"
  echo -e " ${R}9${N}  ${D}→${N} Updater le projet"
  echo -e " ${R}b${N}  ${D}→${N} Backup"
  echo -e " ${R}p${N}  ${D}→${N} Passwords"
  echo -e " ${R}c${N}  ${D}→${N} Clean"
  echo -e " ${R}d${N}  ${D}→${N} Doctor"
  echo -e " ${R}e${N}  ${D}→${N} Exercices OSINT"
  echo -e " ${R}v${N}  ${D}→${N} VPN"
  echo -e " ${R}0${N}  ${D}→${N} Quitter"
  echo -e " ${R}help${N}  ${D}→${N} Cette aide"
  echo -e " ${R}clear${N} ${D}→${N} Effacer"
  echo -e "${R} ──────────────────────────────────${N}\n"
}

main_menu() {
  while true; do
    clear
    show_ascii

    # ── Détection Ubuntu ──────────────────────────────
    local linux_status linux_label linux_color
    if ! command -v proot-distro &>/dev/null; then
      linux_status="proot-distro manquant"
      linux_color="$R"
    elif check_installed; then
      linux_status="Ubuntu installé"
      linux_color="$G"
    else
      linux_status="Ubuntu non installé"
      linux_color="$R"
    fi

    # ── Détection scripts optionnels ─────────────────
    local sd
    sd="$(dirname "$0")"
    local scripts_ok=0 scripts_total=5
    [[ -f "$sd/pass.sh" ]]     && scripts_ok=$((scripts_ok+1))
    [[ -f "$sd/clean.sh" ]]    && scripts_ok=$((scripts_ok+1))
    [[ -f "$sd/doctor.sh" ]]   && scripts_ok=$((scripts_ok+1))
    [[ -f "$sd/exercice.sh" ]] && scripts_ok=$((scripts_ok+1))
    [[ -f "$sd/vpn.sh" ]]      && scripts_ok=$((scripts_ok+1))

    echo -e "${R} ──────────────────────────────────${N}"
    echo -e " ${D}Linux  :${N} ${linux_color}${linux_status}${N}"
    echo -e " ${D}Scripts:${N} ${W}${scripts_ok}/${scripts_total} détectés${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"

    # ── Menu — items grisés si Ubuntu absent ─────────
    if check_installed 2>/dev/null; then
      echo -e " ${R}[${W}1${R}]${N} ${W}Lancer Linux${N}"
      echo -e " ${R}[${W}2${R}]${N} ${W}Mettre à jour Linux${N}"
      echo -e " ${R}[${W}3${R}]${N} ${W}Mettre à jour les outils${N}"
      echo -e " ${R}[${W}4${R}]${N} ${W}Installer un outil${N}"
      echo -e " ${R}[${W}5${R}]${N} ${W}Infos système${N}"
      echo -e " ${R}[${W}6${R}]${N} ${W}Sécurité rapide${N}"
      echo -e " ${R}[${W}7${R}]${N} ${W}Réinitialiser Linux${N}"
      echo -e " ${R}[${W}8${R}]${N} ${W}Désinstaller Linux${N}"
    else
      echo -e " ${R}[${W}1${R}]${N} ${R}Installer Linux${N}"
      echo -e " ${D}[2]  Mettre à jour Linux       (Linux requis)${N}"
      echo -e " ${D}[3]  Mettre à jour les outils  (Linux requis)${N}"
      echo -e " ${D}[4]  Installer un outil        (Linux requis)${N}"
      echo -e " ${D}[5]  Infos système             (Linux requis)${N}"
      echo -e " ${D}[6]  Sécurité rapide           (Linux requis)${N}"
      echo -e " ${D}[7]  Réinitialiser Linux       (Linux requis)${N}"
      echo -e " ${D}[8]  Désinstaller Linux        (Linux requis)${N}"
    fi

    echo -e " ${R}[${W}9${R}]${N} ${W}Updater le projet${N}"
    echo -e " ${R}[${W}b${R}]${N} ${W}Backup${N}"

    [[ -f "$sd/pass.sh" ]]     && echo -e " ${R}[${W}p${R}]${N} ${W}Passwords${N}"        || echo -e " ${D}[p]  Passwords              (pass.sh manquant)${N}"
    [[ -f "$sd/clean.sh" ]]    && echo -e " ${R}[${W}c${R}]${N} ${W}Clean${N}"             || echo -e " ${D}[c]  Clean                  (clean.sh manquant)${N}"
    [[ -f "$sd/doctor.sh" ]]   && echo -e " ${R}[${W}d${R}]${N} ${W}Doctor${N}"            || echo -e " ${D}[d]  Doctor                 (doctor.sh manquant)${N}"
    [[ -f "$sd/exercice.sh" ]] && echo -e " ${R}[${W}e${R}]${N} ${W}Exercices OSINT${N}"   || echo -e " ${D}[e]  Exercices OSINT        (exercice.sh manquant)${N}"
    [[ -f "$sd/vpn.sh" ]]      && echo -e " ${R}[${W}v${R}]${N} ${W}VPN${N}"              || echo -e " ${D}[v]  VPN                    (vpn.sh manquant)${N}"

    echo -e " ${R}[${W}0${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1)
        if check_installed 2>/dev/null; then
          check_proot && linux_menu
        else
          download_kali && main_menu && return
        fi
        ;;
      2) check_installed && update_kali || { echo -e "\n ${R}[✗] Ubuntu non installé.${N}"; sleep 2; } ;;
      3) check_installed && update_tools_menu || { echo -e "\n ${R}[✗] Ubuntu non installé.${N}"; sleep 2; } ;;
      4) check_installed && tools_menu || { echo -e "\n ${R}[✗] Ubuntu non installé.${N}"; sleep 2; } ;;
      5) check_installed && get_sys_info || { echo -e "\n ${R}[✗] Ubuntu non installé.${N}"; sleep 2; } ;;
      6) check_installed && security_menu || { echo -e "\n ${R}[✗] Ubuntu non installé.${N}"; sleep 2; } ;;
      7) check_installed && reset_kali || { echo -e "\n ${R}[✗] Ubuntu non installé.${N}"; sleep 2; } ;;
      8) check_installed && remove_kali || { echo -e "\n ${R}[✗] Ubuntu non installé.${N}"; sleep 2; } ;;
      9)
        local UPDATE_SCRIPT
        UPDATE_SCRIPT="$(dirname "$0")/update.sh"
        if [[ -f "$UPDATE_SCRIPT" ]]; then
          bash "$UPDATE_SCRIPT"
        else
          echo -e "\n ${R}[✗] update.sh introuvable.${N}"
          sleep 2
        fi
        ;;
      b|B) run_backup ;;
      p|P) run_pass ;;
      c|C) run_clean ;;
      d|D) run_doctor ;;
      e|E) run_exercice ;;
      v|V) run_vpn ;;
      0) clear; show_ascii; echo -e "\n ${D}À bientôt.${N}\n"; exit 0 ;;
      help)  help_cmd; echo -ne " ${D}Entrée...${N}"; read -r ;;
      clear) clear ;;
      exit)  exit 0 ;;
      *) sleep 0.5 ;;
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
      1) download_kali && main_menu && return ;;
      2|exit) exit 0 ;;
      *) sleep 0.8 ;;
    esac
  done
}

clear
show_ascii
check_proot
main_menu
