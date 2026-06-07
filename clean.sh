#!/bin/bash

source "$(dirname "$0")/config.sh" 2>/dev/null

R='\033[0;31m'
RB='\033[1;31m'
W='\033[1;37m'
D='\033[2;37m'
G='\033[0;32m'
Y='\033[1;33m'
N='\033[0m'

SCRIPT_DIR="$(dirname "$0")"
LOG_FILE="${SCRIPT_DIR}/update.log"

trap "echo -e '${N}'; exit" INT TERM

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [CLEAN] $1" >> "$LOG_FILE"
}

show_ascii() {
  echo -e "${RB}"
  echo "⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣦⣤⣄⣈⡑⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀"
  echo "⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮⣷⣤⠀⠀⠀⠀⠀⠀"
  echo -e "${N}"
  echo -e "${W} K A L I - T E R M U X  —  C L E A N${N}\n"
}

progress_bar() {
  local label="$1"
  local total=25
  echo -ne " ${W}${label}${N}\n ${R}["
  for ((i=0; i<total; i++)); do
    sleep 0.02
    echo -ne "${R}█"
  done
  echo -e "${W}] ${G}OK${N}"
}

get_size() {
  du -sh "$1" 2>/dev/null | cut -f1
}

clean_apt() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} NETTOYAGE APT (LINUX)${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  if ! proot-distro list 2>&1 | grep -q "ubuntu"; then
    echo -e " ${D}Linux non installé, ignoré.${N}"
    sleep 2; return
  fi

  local before
  before=$(proot-distro login ubuntu -- bash -c "df -h / 2>/dev/null | awk 'NR==2{print \$4}'" 2>/dev/null)

  echo -e " ${D}Nettoyage du cache apt...${N}"
  proot-distro login ubuntu -- bash -c "apt clean -y 2>/dev/null && echo OK" | grep -q "OK" && \
    echo -e " ${G}✓${N} ${W}Cache apt vidé${N}"

  echo -e " ${D}Suppression des paquets orphelins...${N}"
  proot-distro login ubuntu -- bash -c "apt autoremove -y 2>/dev/null && echo OK" | grep -q "OK" && \
    echo -e " ${G}✓${N} ${W}Paquets orphelins supprimés${N}"

  echo -e " ${D}Suppression des listes obsolètes...${N}"
  proot-distro login ubuntu -- bash -c "apt autoclean -y 2>/dev/null && echo OK" | grep -q "OK" && \
    echo -e " ${G}✓${N} ${W}Listes nettoyées${N}"

  local after
  after=$(proot-distro login ubuntu -- bash -c "df -h / 2>/dev/null | awk 'NR==2{print \$4}'" 2>/dev/null)

  echo -e "\n ${D}Espace avant : ${W}${before:-?}${N}"
  echo -e " ${D}Espace après  : ${W}${after:-?}${N}"
  log "APT clean : avant=${before} après=${after}"

  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

clean_logs() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} NETTOYAGE DES LOGS${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  if ! proot-distro list 2>&1 | grep -q "ubuntu"; then
    echo -e " ${D}Linux non installé, ignoré.${N}"
    sleep 2; return
  fi

  local logs=("/var/log/syslog" "/var/log/auth.log" "/var/log/kern.log"
              "/var/log/dpkg.log" "/var/log/apt/history.log" "/var/log/apt/term.log")

  for logfile in "${logs[@]}"; do
    proot-distro login ubuntu -- bash -c \
      "[[ -f '${logfile}' ]] && cat /dev/null > '${logfile}' && echo 'OK:${logfile}' || echo 'SKIP:${logfile}'" 2>/dev/null | \
    while IFS=: read -r status name; do
      if [[ "$status" == "OK" ]]; then
        echo -e " ${G}✓${N} ${W}${name}${N} vidé"
      else
        echo -e " ${D}—${N} ${D}${name} absent${N}"
      fi
    done
  done

  echo -e " ${D}Nettoyage historique bash Linux...${N}"
  proot-distro login ubuntu -- bash -c "cat /dev/null > /root/.bash_history 2>/dev/null && echo OK" | grep -q "OK" && \
    echo -e " ${G}✓${N} ${W}Historique Linux vidé${N}"

  log "Logs Linux nettoyés"
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

clean_termux() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} NETTOYAGE TERMUX${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  echo -e " ${D}Nettoyage cache pkg...${N}"
  pkg clean 2>/dev/null && echo -e " ${G}✓${N} ${W}Cache pkg vidé${N}"

  echo -e " ${D}Nettoyage fichiers temporaires...${N}"
  rm -rf /tmp/* 2>/dev/null && echo -e " ${G}✓${N} ${W}/tmp vidé${N}"

  local histsize
  histsize=$(wc -l < ~/.bash_history 2>/dev/null || echo 0)
  echo -ne "\n ${W}Vider l'historique Termux (${histsize} lignes) ? [o/N] : ${N}"
  read -r CONFIRM
  if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
    cat /dev/null > ~/.bash_history && echo -e " ${G}✓${N} ${W}Historique Termux vidé${N}"
    log "Historique Termux vidé"
  fi

  log "Termux nettoyé"
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

clean_backups() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} NETTOYAGE DES VIEUX BACKUPS${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  local BACKUP_DIR="${SCRIPT_DIR}/backups"
  if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
    echo -e " ${D}Aucun backup trouvé.${N}"
    sleep 2; return
  fi

  local count=0
  echo -e " ${D}Backups présents :${N}\n"
  for d in "${BACKUP_DIR}"/*/; do
    local name size
    name=$(basename "$d")
    size=$(du -sh "$d" 2>/dev/null | cut -f1)
    echo -e "  ${W}${name}${N} ${D}(${size})${N}"
    count=$((count+1))
  done

  echo -e "\n ${Y}[!]${N} ${W}${count} backup(s) trouvé(s).${N}"
  echo -ne " ${W}Supprimer les backups de plus de 7 jours ? [o/N] : ${N}"
  read -r CONFIRM
  if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
    find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +7 -exec rm -rf {} + 2>/dev/null
    echo -e " ${G}✓${N} ${W}Vieux backups supprimés${N}"
    log "Vieux backups (>7j) supprimés"
  fi

  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

clean_all() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} NETTOYAGE COMPLET${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -e " ${Y}[!]${N} ${W}Cela va nettoyer apt, logs, tmp et cache.${N}"
  echo -ne " ${W}Confirmer ? [o/N] : ${N}"
  read -r CONFIRM
  [[ ! "$CONFIRM" =~ ^[oO]$ ]] && return

  progress_bar "Nettoyage apt..."
  proot-distro login ubuntu -- bash -c "apt clean -y && apt autoremove -y && apt autoclean -y" &>/dev/null

  progress_bar "Nettoyage logs..."
  proot-distro login ubuntu -- bash -c \
    "for f in /var/log/syslog /var/log/auth.log /var/log/kern.log /var/log/dpkg.log; do [ -f \"\$f\" ] && cat /dev/null > \"\$f\"; done" &>/dev/null

  progress_bar "Nettoyage tmp..."
  rm -rf /tmp/* 2>/dev/null
  pkg clean 2>/dev/null

  echo -e "\n ${G}✓${N} ${W}Nettoyage complet terminé.${N}"
  log "Nettoyage complet effectué"
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

disk_usage() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} UTILISATION DISQUE${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  echo -e " ${D}Termux home :${N} ${W}$(get_size ~)${N}"
  echo -e " ${D}Scripts     :${N} ${W}$(get_size "$SCRIPT_DIR")${N}"
  [[ -d "${SCRIPT_DIR}/backups" ]] && \
    echo -e " ${D}Backups     :${N} ${W}$(get_size "${SCRIPT_DIR}/backups")${N}"
  echo -e " ${D}/tmp        :${N} ${W}$(get_size /tmp)${N}"

  if proot-distro list 2>&1 | grep -q "ubuntu"; then
    local linux_used
    linux_used=$(proot-distro login ubuntu -- bash -c "df -h / 2>/dev/null | awk 'NR==2{print \$3\"/\"\$2}'" 2>/dev/null)
    echo -e " ${D}Linux rootfs:${N} ${W}${linux_used:-?}${N}"
  fi

  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

main_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Nettoyage apt (Linux)${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Nettoyage des logs${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Nettoyage Termux${N}"
    echo -e " ${R}[${W}4${R}]${N} ${W}Supprimer vieux backups${N}"
    echo -e " ${R}[${W}5${R}]${N} ${W}Nettoyage complet${N}"
    echo -e " ${R}[${W}6${R}]${N} ${W}Utilisation disque${N}"
    echo -e "\n ${R}[${W}0${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1) clean_apt ;;
      2) clean_logs ;;
      3) clean_termux ;;
      4) clean_backups ;;
      5) clean_all ;;
      6) disk_usage ;;
      0) clear; exit 0 ;;
      *) sleep 0.5 ;;
    esac
  done
}

clear
show_ascii
log "===== clean.sh lancé ====="
main_menu
