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
PASS_FILE="${SCRIPT_DIR}/passwords.gpg"
LOG_FILE="${SCRIPT_DIR}/update.log"

trap "echo -e '${N}'; exit" INT TERM

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PASS] $1" >> "$LOG_FILE"
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
  echo -e "${W} K A L I - T E R M U X  —  P A S S W O R D${N}\n"
}

generate_password() {
  local length="$1"
  local mode="$2"
  local charset=""

  case "$mode" in
    1) charset='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' ;;
    2) charset='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?' ;;
    3) charset='0123456789' ;;
    4) charset='abcdefghijklmnopqrstuvwxyz' ;;
    5) charset='ABCDEFGHIJKLMNOPQRSTUVWXYZ' ;;
    *) charset='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()' ;;
  esac

  local charlen=${#charset}
  local password=""
  for ((i=0; i<length; i++)); do
    password+="${charset:$((RANDOM % charlen)):1}"
  done
  echo "$password"
}

check_strength() {
  local pass="$1"
  local len=${#pass}
  local score=0
  local label=""

  [[ $len -ge 8 ]]  && score=$((score+1))
  [[ $len -ge 12 ]] && score=$((score+1))
  [[ $len -ge 16 ]] && score=$((score+1))
  [[ "$pass" =~ [a-z] ]] && score=$((score+1))
  [[ "$pass" =~ [A-Z] ]] && score=$((score+1))
  [[ "$pass" =~ [0-9] ]] && score=$((score+1))
  [[ "$pass" =~ [^a-zA-Z0-9] ]] && score=$((score+1))

  if   [[ $score -le 2 ]]; then label="${R}Faible${N}"
  elif [[ $score -le 4 ]]; then label="${Y}Moyen${N}"
  elif [[ $score -le 6 ]]; then label="${G}Fort${N}"
  else label="${G}Très fort${N}"
  fi

  echo -e "$label (score : $score/7)"
}

generator_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} GÉNÉRER UN MOT DE PASSE${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Alphanumérique${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Alphanumérique + symboles${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Numérique uniquement${N}"
    echo -e " ${R}[${W}4${R}]${N} ${W}Lettres minuscules${N}"
    echo -e " ${R}[${W}5${R}]${N} ${W}Lettres majuscules${N}"
    echo -e "\n ${R}[${W}b${R}]${N} ${D}Retour${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r MODE
    echo -ne "${N}"
    [[ "$MODE" == "b" || "$MODE" == "B" ]] && return
    [[ ! "$MODE" =~ ^[1-5]$ ]] && continue

    echo -ne "\n ${W}Longueur (défaut=16) : ${N}"
    read -r LEN
    [[ -z "$LEN" || ! "$LEN" =~ ^[0-9]+$ ]] && LEN=16
    [[ $LEN -lt 4 ]] && LEN=4
    [[ $LEN -gt 128 ]] && LEN=128

    echo -ne "\n ${W}Combien de mots de passe (défaut=1) : ${N}"
    read -r COUNT
    [[ -z "$COUNT" || ! "$COUNT" =~ ^[0-9]+$ ]] && COUNT=1
    [[ $COUNT -lt 1 ]] && COUNT=1
    [[ $COUNT -gt 20 ]] && COUNT=20

    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -e "${W} RÉSULTATS${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"

    for ((i=1; i<=COUNT; i++)); do
      local pass
      pass=$(generate_password "$LEN" "$MODE")
      local strength
      strength=$(check_strength "$pass")
      echo -e " ${G}${pass}${N}"
      echo -e " ${D}Force : ${strength}${N}\n"
      log "Mot de passe généré : longueur=${LEN} mode=${MODE}"
    done

    echo -e "${R} ──────────────────────────────────${N}"
    echo -ne "\n ${D}Entrée...${N}"
    read -r
  done
}

check_menu() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} VÉRIFIER UN MOT DE PASSE${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -ne " ${W}Mot de passe à analyser : ${N}"
  read -rs PASS
  echo
  if [[ -z "$PASS" ]]; then
    echo -e " ${R}[✗] Vide.${N}"
    sleep 1; return
  fi
  local len=${#PASS}
  local strength
  strength=$(check_strength "$PASS")
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${D}Longueur    :${N} ${W}${len} caractères${N}"
  echo -e " ${D}Force       :${N} ${strength}"
  [[ "$PASS" =~ [a-z] ]] && echo -e " ${G}✓${N} ${D}Minuscules${N}" || echo -e " ${R}✗${N} ${D}Minuscules manquantes${N}"
  [[ "$PASS" =~ [A-Z] ]] && echo -e " ${G}✓${N} ${D}Majuscules${N}" || echo -e " ${R}✗${N} ${D}Majuscules manquantes${N}"
  [[ "$PASS" =~ [0-9] ]] && echo -e " ${G}✓${N} ${D}Chiffres${N}" || echo -e " ${R}✗${N} ${D}Chiffres manquants${N}"
  [[ "$PASS" =~ [^a-zA-Z0-9] ]] && echo -e " ${G}✓${N} ${D}Symboles${N}" || echo -e " ${R}✗${N} ${D}Symboles manquants${N}"
  echo -e " ${R}──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

passphrase_menu() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} GÉNÉRER UNE PASSPHRASE${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  local WORDLIST=("cheval" "rouge" "montagne" "étoile" "rivière" "forêt" "nuage" "soleil"
    "lune" "pierre" "feuille" "ombre" "flamme" "vague" "vent" "tonnerre"
    "aigle" "renard" "tigre" "loup" "corbeau" "dragon" "phénix" "serpent"
    "acier" "cristal" "saphir" "rubis" "onyx" "jade" "ambre" "quartz"
    "delta" "sigma" "omega" "alpha" "zéro" "nexus" "cyber" "ghost")

  echo -ne " ${W}Nombre de mots (défaut=4) : ${N}"
  read -r WCOUNT
  [[ -z "$WCOUNT" || ! "$WCOUNT" =~ ^[0-9]+$ ]] && WCOUNT=4
  [[ $WCOUNT -lt 2 ]] && WCOUNT=2
  [[ $WCOUNT -gt 8 ]] && WCOUNT=8

  echo -ne " ${W}Séparateur (défaut=-) : ${N}"
  read -r SEP
  [[ -z "$SEP" ]] && SEP="-"

  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -e "${W} RÉSULTATS${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  for ((i=1; i<=3; i++)); do
    local phrase=""
    for ((j=0; j<WCOUNT; j++)); do
      local word="${WORDLIST[$((RANDOM % ${#WORDLIST[@]}))]}"
      [[ $j -gt 0 ]] && phrase+="$SEP"
      phrase+="$word"
    done
    local num=$((RANDOM % 900 + 100))
    phrase+="${SEP}${num}"
    echo -e " ${G}${phrase}${N}"
  done

  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

main_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Générer un mot de passe${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Vérifier la force${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Générer une passphrase${N}"
    echo -e "\n ${R}[${W}0${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1) generator_menu ;;
      2) check_menu ;;
      3) passphrase_menu ;;
      0) clear; exit 0 ;;
      *) sleep 0.5 ;;
    esac
  done
}

clear
show_ascii
log "===== pass.sh lancé ====="
main_menu
