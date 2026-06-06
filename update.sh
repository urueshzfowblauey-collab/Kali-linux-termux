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
}

TOOL_ORDER=("nmap" "sqlmap" "hydra" "nikto" "john" "aircrack-ng" "hashcat" "metasploit-framework" "beef-xss" "gobuster" "dirb" "wfuzz" "netcat-openbsd" "curl" "wget")

R='\033[0;31m'
RB='\033[1;31m'
W='\033[1;37m'
D='\033[2;37m'
G='\033[0;32m'
N='\033[0m'

LOG_FILE="$(dirname "$0")/update.log"
declare -A REPORT

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
  echo -e "${N}"
  echo -e "${W} K A L I - T E R M U X  —  U P D A T E R${N}\n"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

confirm() {
  local msg="$1"
  echo -ne "\n ${R}[?]${N} ${W}${msg} [o/N] : ${N}"
  read -r ANS
  [[ "$ANS" =~ ^[oO]$ ]]
}

check_internet() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}VÉRIFICATION INTERNET${N}"
  echo -e " ${R}──────────────────────────────────${N}"
  echo -ne " ${D}Test de connexion...${N}"
  if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    echo -e " ${W}[${G}OK${W}]${N}"
    log "Connexion internet : OK"
    return 0
  else
    echo -e " ${W}[${R}FAIL${W}]${N}"
    echo -e "\n ${R}[✗] Pas de connexion internet. Abandon.${N}\n"
    log "Connexion internet : FAIL — abandon"
    exit 1
  fi
}

update_termux() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}MISE À JOUR TERMUX + PROOT-DISTRO${N}"
  echo -e " ${R}──────────────────────────────────${N}"
  confirm "Mettre à jour Termux et proot-distro ?" || {
    echo -e " ${D}Ignoré.${N}"
    log "Termux : ignoré par l'utilisateur"
    REPORT["Termux"]="SKIP"
    return
  }
  echo -e " ${D}apt update + upgrade...${N}"
  if pkg update -y >> "$LOG_FILE" 2>&1 && pkg upgrade -y >> "$LOG_FILE" 2>&1; then
    echo -e " ${W}Termux       [${G}OK${W}]${N}"
    log "Termux pkg update/upgrade : OK"
    REPORT["Termux"]="OK"
  else
    echo -e " ${W}Termux       [${R}FAIL${W}]${N}"
    log "Termux pkg update/upgrade : FAIL"
    REPORT["Termux"]="FAIL"
  fi

  if command -v proot-distro &>/dev/null; then
    if pkg install proot-distro -y >> "$LOG_FILE" 2>&1; then
      echo -e " ${W}proot-distro [${G}OK${W}]${N}"
      log "proot-distro update : OK"
      REPORT["proot-distro"]="OK"
    else
      echo -e " ${W}proot-distro [${R}FAIL${W}]${N}"
      log "proot-distro update : FAIL"
      REPORT["proot-distro"]="FAIL"
    fi
  else
    echo -e " ${D}proot-distro non installé, ignoré.${N}"
    REPORT["proot-distro"]="SKIP"
  fi
}

update_linux() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}MISE À JOUR LINUX (apt)${N}"
  echo -e " ${R}──────────────────────────────────${N}"
  if ! proot-distro list 2>&1 | grep -q "ubuntu"; then
    echo -e " ${D}Linux non installé, ignoré.${N}"
    log "Linux apt update : non installé"
    REPORT["Linux-apt"]="SKIP"
    return
  fi
  confirm "Mettre à jour Linux (apt update + upgrade) ?" || {
    echo -e " ${D}Ignoré.${N}"
    log "Linux apt : ignoré par l'utilisateur"
    REPORT["Linux-apt"]="SKIP"
    return
  }
  if proot-distro login ubuntu -- bash -c "apt update -qq && apt upgrade -y" >> "$LOG_FILE" 2>&1; then
    echo -e " ${W}Linux apt    [${G}OK${W}]${N}"
    log "Linux apt update/upgrade : OK"
    REPORT["Linux-apt"]="OK"
  else
    echo -e " ${W}Linux apt    [${R}FAIL${W}]${N}"
    log "Linux apt update/upgrade : FAIL"
    REPORT["Linux-apt"]="FAIL"
  fi
}

update_tools() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}MISE À JOUR DES OUTILS${N}"
  echo -e " ${R}──────────────────────────────────${N}"
  if ! proot-distro list 2>&1 | grep -q "ubuntu"; then
    echo -e " ${D}Linux non installé, outils ignorés.${N}"
    log "Outils : Linux non installé"
    return
  fi
  confirm "Mettre à jour tous les outils Kali ?" || {
    echo -e " ${D}Ignoré.${N}"
    log "Outils : ignorés par l'utilisateur"
    for tool in "${TOOL_ORDER[@]}"; do REPORT["$tool"]="SKIP"; done
    return
  }
  for tool in "${TOOL_ORDER[@]}"; do
    echo -ne " ${D}${tool}...${N}"
    if proot-distro login ubuntu -- bash -c "apt install -y --only-upgrade ${tool} -qq" >> "$LOG_FILE" 2>&1; then
      echo -e "\r ${W}${tool} $(printf '%0.s ' $(seq 1 $((25-${#tool}))))[${G}OK${W}]${N}"
      log "Outil ${tool} : OK"
      REPORT["$tool"]="OK"
    else
      echo -e "\r ${W}${tool} $(printf '%0.s ' $(seq 1 $((25-${#tool}))))[${R}FAIL${W}]${N}"
      log "Outil ${tool} : FAIL"
      REPORT["$tool"]="FAIL"
    fi
  done
}

update_github() {
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${W}SYNCHRONISATION GITHUB${N}"
  echo -e " ${R}──────────────────────────────────${N}"
  local SCRIPT_DIR
  SCRIPT_DIR="$(dirname "$0")"
  if [ ! -d "${SCRIPT_DIR}/.git" ]; then
    echo -e " ${D}Repo Git non détecté, ignoré.${N}"
    log "GitHub sync : pas de repo git"
    REPORT["GitHub"]="SKIP"
    return
  fi
  confirm "Faire un git pull (récupérer les mises à jour du repo) ?" && {
    cd "$SCRIPT_DIR" || return
    if git pull >> "$LOG_FILE" 2>&1; then
      echo -e " ${W}git pull     [${G}OK${W}]${N}"
      log "GitHub git pull : OK"
      REPORT["GitHub-pull"]="OK"
    else
      echo -e " ${W}git pull     [${R}FAIL${W}]${N}"
      log "GitHub git pull : FAIL"
      REPORT["GitHub-pull"]="FAIL"
    fi
  }
  confirm "Faire un git push (envoyer tes modifs sur GitHub) ?" && {
    cd "$SCRIPT_DIR" || return
    git add -A >> "$LOG_FILE" 2>&1
    git commit -m "auto-update $(date '+%Y-%m-%d %H:%M')" >> "$LOG_FILE" 2>&1
    if git push >> "$LOG_FILE" 2>&1; then
      echo -e " ${W}git push     [${G}OK${W}]${N}"
      log "GitHub git push : OK"
      REPORT["GitHub-push"]="OK"
    else
      echo -e " ${W}git push     [${R}FAIL${W}]${N}"
      log "GitHub git push : FAIL (token ?) "
      REPORT["GitHub-push"]="FAIL"
    fi
  }
}

show_report() {
  echo -e "\n ${R}══════════════════════════════════${N}"
  echo -e " ${W}RAPPORT FINAL${N}"
  echo -e " ${R}══════════════════════════════════${N}\n"
  local ok=0 fail=0 skip=0
  for key in "${!REPORT[@]}"; do
    local val="${REPORT[$key]}"
    local col="${D}"
    [[ "$val" == "OK" ]]   && col="${G}" && ok=$((ok+1))
    [[ "$val" == "FAIL" ]] && col="${R}" && fail=$((fail+1))
    [[ "$val" == "SKIP" ]] && col="${D}" && skip=$((skip+1))
    printf " ${W}%-22s${N}[${col}%s${N}]\n" "$key" "$val"
  done
  echo -e "\n ${R}──────────────────────────────────${N}"
  echo -e " ${G}OK : ${ok}${N}  ${R}FAIL : ${fail}${N}  ${D}SKIP : ${skip}${N}"
  echo -e " ${R}──────────────────────────────────${N}"
  echo -e " ${D}Log complet : ${W}${LOG_FILE}${N}\n"
  log "Rapport — OK:${ok} FAIL:${fail} SKIP:${skip}"
}

# ─── MAIN ───────────────────────────────────────────
clear
show_ascii
log "===== Début de la mise à jour ====="

check_internet
update_termux
update_linux
update_tools
update_github
show_report

log "===== Fin de la mise à jour ====="
