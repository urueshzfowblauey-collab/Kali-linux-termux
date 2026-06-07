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
BACKUP_DIR="${SCRIPT_DIR}/backups"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_NAME="kalitermux_backup_${DATE}"
LOG_FILE="${SCRIPT_DIR}/update.log"

trap "echo -e '${N}'; exit" INT TERM

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BACKUP] $1" >> "$LOG_FILE"
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
  echo -e "${W} K A L I - T E R M U X  —  B A C K U P${N}\n"
}

progress_bar() {
  local label="$1"
  local total=25
  echo -ne " ${W}${label}${N}\n ${R}["
  for ((i=0; i<total; i++)); do
    sleep 0.03
    echo -ne "${R}█"
  done
  echo -e "${W}] ${G}OK${N}"
}

# ─── BACKUP SCRIPTS ─────────────────────────────────
backup_scripts() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}SAUVEGARDE — SCRIPTS${N}"
  echo -e " ${R}──────────────────────────────────${N}\n"

  local DEST="${BACKUP_DIR}/${BACKUP_NAME}/scripts"
  mkdir -p "$DEST"

  local files=("kali.sh" "update.sh" "config.sh" "setup_github.sh" "backup.sh")
  local ok=0 fail=0

  for f in "${files[@]}"; do
    if [[ -f "${SCRIPT_DIR}/${f}" ]]; then
      cp "${SCRIPT_DIR}/${f}" "${DEST}/" && {
        echo -e " ${G}✓${N} ${W}${f}${N}"
        ok=$((ok+1))
      } || {
        echo -e " ${R}✗${N} ${W}${f} — copie échouée${N}"
        fail=$((fail+1))
      }
    else
      echo -e " ${D}—${N} ${D}${f} introuvable${N}"
    fi
  done

  # README si présent
  [[ -f "${SCRIPT_DIR}/README.md" ]] && cp "${SCRIPT_DIR}/README.md" "${DEST}/" && echo -e " ${G}✓${N} ${W}README.md${N}"

  echo -e "\n ${D}Scripts : ${G}${ok} OK${N} ${D}/ ${R}${fail} FAIL${N}"
  log "Scripts backup : OK=${ok} FAIL=${fail}"
}

# ─── BACKUP LINUX HOME ──────────────────────────────
backup_linux_home() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}SAUVEGARDE — HOME LINUX${N}"
  echo -e " ${R}──────────────────────────────────${N}\n"

  if ! proot-distro list 2>&1 | grep -q "ubuntu"; then
    echo -e " ${D}Linux non installé, ignoré.${N}"
    log "Linux home backup : non installé"
    return
  fi

  local DEST="${BACKUP_DIR}/${BACKUP_NAME}/linux_home"
  mkdir -p "$DEST"

  echo -e " ${D}Export du home root Linux...${N}"
  proot-distro login ubuntu -- bash -c \
    "tar czf /tmp/home_backup.tar.gz /root 2>/dev/null && echo OK || echo FAIL" | grep -q "OK"

  if [[ $? -eq 0 ]]; then
    # Copie depuis le filesystem proot vers Termux
    local PROOT_TMP
    PROOT_TMP=$(find ~/.local/share/proot-distro/installed-rootfs/ubuntu -name "home_backup.tar.gz" 2>/dev/null | head -1)
    if [[ -n "$PROOT_TMP" ]]; then
      cp "$PROOT_TMP" "${DEST}/home_backup.tar.gz" && {
        echo -e " ${G}✓${N} ${W}home_backup.tar.gz copié${N}"
        log "Linux home backup : OK"
      }
    else
      echo -e " ${R}✗${N} ${W}Fichier tar introuvable${N}"
      log "Linux home backup : tar introuvable"
    fi
  else
    echo -e " ${R}✗${N} ${W}Échec de la compression${N}"
    log "Linux home backup : compression FAIL"
  fi
}

# ─── BACKUP BASH HISTORY ────────────────────────────
backup_history() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}SAUVEGARDE — HISTORIQUE${N}"
  echo -e " ${R}──────────────────────────────────${N}\n"

  local DEST="${BACKUP_DIR}/${BACKUP_NAME}/history"
  mkdir -p "$DEST"

  # Termux history
  if [[ -f ~/.bash_history ]]; then
    cp ~/.bash_history "${DEST}/termux_bash_history" && \
      echo -e " ${G}✓${N} ${W}Historique Termux${N}"
  fi

  # Linux history
  if proot-distro list 2>&1 | grep -q "ubuntu"; then
    proot-distro login ubuntu -- bash -c \
      "cat /root/.bash_history 2>/dev/null" > "${DEST}/linux_bash_history" 2>/dev/null && \
      echo -e " ${G}✓${N} ${W}Historique Linux${N}"
  fi

  log "Historique backup : OK"
}

# ─── LISTER LES BACKUPS ─────────────────────────────
list_backups() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}BACKUPS EXISTANTS${N}"
  echo -e " ${R}──────────────────────────────────${N}\n"

  if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
    echo -e " ${D}Aucun backup trouvé.${N}"
    return
  fi

  local i=1
  for d in "${BACKUP_DIR}"/*/; do
    local name size
    name=$(basename "$d")
    size=$(du -sh "$d" 2>/dev/null | cut -f1)
    echo -e " ${R}[${W}${i}${R}]${N} ${W}${name}${N} ${D}(${size})${N}"
    i=$((i+1))
  done
  echo -e "\n ${D}Dossier : ${W}${BACKUP_DIR}${N}"
}

# ─── SUPPRIMER UN BACKUP ────────────────────────────
delete_backup() {
  list_backups
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -ne " ${W}Numéro à supprimer (vide = annuler) : ${N}"
  read -r CHOICE
  [[ -z "$CHOICE" ]] && return

  local i=1
  for d in "${BACKUP_DIR}"/*/; do
    if [[ "$i" -eq "$CHOICE" ]]; then
      local name
      name=$(basename "$d")
      echo -ne "\n ${R}[?]${N} ${W}Supprimer ${name} ? [o/N] : ${N}"
      read -r CONFIRM
      if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
        rm -rf "$d" && echo -e " ${G}✓${N} ${W}Supprimé.${N}" || echo -e " ${R}✗${N} ${W}Échec.${N}"
        log "Backup supprimé : ${name}"
      fi
      return
    fi
    i=$((i+1))
  done
  echo -e " ${R}[✗] Numéro invalide.${N}"
}

# ─── MENU PRINCIPAL ─────────────────────────────────
main_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Sauvegarder les scripts${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Sauvegarder le home Linux${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Sauvegarder l'historique${N}"
    echo -e " ${R}[${W}4${R}]${N} ${W}Tout sauvegarder${N}"
    echo -e " ${R}[${W}5${R}]${N} ${W}Lister les backups${N}"
    echo -e " ${R}[${W}6${R}]${N} ${W}Supprimer un backup${N}"
    echo -e "\n ${R}[${W}0${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1)
        backup_scripts
        progress_bar "Finalisation..."
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      2)
        backup_linux_home
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      3)
        backup_history
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      4)
        backup_scripts
        backup_linux_home
        backup_history
        progress_bar "Finalisation..."
        echo -e "\n ${G}✓ Backup complet : ${W}${BACKUP_DIR}/${BACKUP_NAME}${N}"
        log "Backup complet : ${BACKUP_NAME}"
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      5)
        list_backups
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      6)
        delete_backup
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      0) clear; exit 0 ;;
      *) sleep 0.5 ;;
    esac
  done
}

# ─── LAUNCH ─────────────────────────────────────────
clear
show_ascii
log "===== Backup lancé ====="
main_menu
