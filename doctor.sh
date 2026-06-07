#!/bin/bash

source "$(dirname "$0")/config.sh" 2>/dev/null || {
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

  TOOL_ORDER=("nmap" "sqlmap" "hydra" "nikto" "john" "aircrack-ng" "hashcat"
              "metasploit-framework" "beef-xss" "gobuster" "dirb" "wfuzz"
              "netcat-openbsd" "curl" "wget")
}

R='\033[0;31m'
RB='\033[1;31m'
W='\033[1;37m'
D='\033[2;37m'
G='\033[0;32m'
Y='\033[1;33m'
N='\033[0m'

SCRIPT_DIR="$(dirname "$0")"
LOG_FILE="${SCRIPT_DIR}/update.log"
REPORT_FILE="${SCRIPT_DIR}/doctor_report_$(date '+%Y%m%d_%H%M%S').txt"

trap "echo -e '${N}'; exit" INT TERM

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DOCTOR] $1" >> "$LOG_FILE"
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
  echo -e "${W} K A L I - T E R M U X  —  D O C T O R${N}\n"
}

ok()   { echo -e " ${G}[✓]${N} ${W}$1${N}"; }
warn() { echo -e " ${Y}[!]${N} ${W}$1${N}"; }
fail() { echo -e " ${R}[✗]${N} ${W}$1${N}"; }
info() { echo -e " ${D}[i]${N} ${D}$1${N}"; }

section() {
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -e "${W} $1${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
}

declare -A RESULTS
PASS=0; WARN=0; FAIL=0

record() {
  local label="$1" status="$2"
  RESULTS["$label"]="$status"
  case "$status" in
    OK)   PASS=$((PASS+1)) ;;
    WARN) WARN=$((WARN+1)) ;;
    FAIL) FAIL=$((FAIL+1)) ;;
  esac
}

check_termux() {
  section "ENVIRONNEMENT TERMUX"

  if command -v bash &>/dev/null; then
    ok "bash disponible ($(bash --version | head -1 | cut -d' ' -f4))"
    record "bash" "OK"
  else
    fail "bash introuvable"
    record "bash" "FAIL"
  fi

  if command -v pkg &>/dev/null; then
    ok "pkg disponible"
    record "pkg" "OK"
  else
    fail "pkg introuvable"
    record "pkg" "FAIL"
  fi

  if command -v proot-distro &>/dev/null; then
    local pd_ver
    pd_ver=$(proot-distro --version 2>/dev/null | head -1)
    ok "proot-distro : ${pd_ver:-installé}"
    record "proot-distro" "OK"
  else
    fail "proot-distro manquant — lance : pkg install proot-distro"
    record "proot-distro" "FAIL"
  fi

  local storage_ok=false
  [[ -d ~/storage ]] && storage_ok=true
  if $storage_ok; then
    ok "Accès stockage Termux activé"
    record "storage" "OK"
  else
    warn "Stockage non configuré — lance : termux-setup-storage"
    record "storage" "WARN"
  fi

  local free_mb
  free_mb=$(df -m ~ 2>/dev/null | awk 'NR==2{print $4}')
  if [[ -n "$free_mb" ]]; then
    if [[ $free_mb -ge 500 ]]; then
      ok "Espace disque Termux : ${free_mb} MB libres"
      record "disk_termux" "OK"
    elif [[ $free_mb -ge 100 ]]; then
      warn "Espace disque Termux faible : ${free_mb} MB libres"
      record "disk_termux" "WARN"
    else
      fail "Espace disque Termux critique : ${free_mb} MB libres"
      record "disk_termux" "FAIL"
    fi
  fi
}

check_linux() {
  section "ENVIRONNEMENT LINUX (PROOT)"

  if ! command -v proot-distro &>/dev/null; then
    warn "proot-distro absent, vérification Linux ignorée"
    return
  fi

  if proot-distro list 2>&1 | grep -q "ubuntu"; then
    ok "Ubuntu installé"
    record "ubuntu" "OK"
  else
    fail "Ubuntu non installé"
    record "ubuntu" "FAIL"
    return
  fi

  local linux_os
  linux_os=$(proot-distro login ubuntu -- bash -c "grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'\"' -f2" 2>/dev/null)
  info "OS Linux : ${linux_os:-inconnu}"

  local linux_kernel
  linux_kernel=$(proot-distro login ubuntu -- bash -c "uname -r 2>/dev/null" 2>/dev/null)
  info "Kernel : ${linux_kernel:-inconnu}"

  local linux_free
  linux_free=$(proot-distro login ubuntu -- bash -c "df -m / 2>/dev/null | awk 'NR==2{print \$4}'" 2>/dev/null)
  if [[ -n "$linux_free" ]]; then
    if [[ $linux_free -ge 500 ]]; then
      ok "Espace Linux : ${linux_free} MB libres"
      record "disk_linux" "OK"
    elif [[ $linux_free -ge 100 ]]; then
      warn "Espace Linux faible : ${linux_free} MB libres"
      record "disk_linux" "WARN"
    else
      fail "Espace Linux critique : ${linux_free} MB libres"
      record "disk_linux" "FAIL"
    fi
  fi

  local apt_ok
  apt_ok=$(proot-distro login ubuntu -- bash -c "apt-get check 2>&1 | tail -1" 2>/dev/null)
  if echo "$apt_ok" | grep -qi "error\|broken"; then
    fail "apt signale des erreurs : $apt_ok"
    record "apt_health" "FAIL"
  else
    ok "apt : aucune erreur détectée"
    record "apt_health" "OK"
  fi
}

check_tools() {
  section "OUTILS INSTALLÉS"

  if ! proot-distro list 2>&1 | grep -q "ubuntu"; then
    warn "Linux non installé, vérification des outils ignorée"
    return
  fi

  local installed=0 missing=0
  for tool in "${TOOL_ORDER[@]}"; do
    local bin="${TOOL_BIN[$tool]:-$tool}"
    local found
    found=$(proot-distro login ubuntu -- bash -c "command -v '${bin}' &>/dev/null && echo YES || echo NO" 2>/dev/null)
    if [[ "$found" == "YES" ]]; then
      ok "${tool} (${bin})"
      installed=$((installed+1))
      record "tool_${tool}" "OK"
    else
      warn "${tool} non installé"
      missing=$((missing+1))
      record "tool_${tool}" "WARN"
    fi
  done

  info "Outils : ${installed} installés / ${missing} manquants"
}

check_scripts() {
  section "SCRIPTS DU PROJET"

  local scripts=("kali.sh" "update.sh" "backup.sh" "config.sh" "setup_github.sh"
                 "pass.sh" "clean.sh" "doctor.sh")

  for f in "${scripts[@]}"; do
    local path="${SCRIPT_DIR}/${f}"
    if [[ -f "$path" ]]; then
      if [[ -x "$path" ]]; then
        ok "${f} — présent et exécutable"
        record "script_${f}" "OK"
      else
        warn "${f} — présent mais non exécutable (chmod +x ${f})"
        record "script_${f}" "WARN"
      fi
    else
      info "${f} — absent (optionnel)"
    fi
  done

  if [[ -f "${SCRIPT_DIR}/config.sh" ]]; then
    ok "config.sh chargé"
    record "config" "OK"
  else
    warn "config.sh absent — fallback interne utilisé"
    record "config" "WARN"
  fi
}

check_network() {
  section "CONNECTIVITÉ RÉSEAU"

  if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    ok "Connexion internet active"
    record "internet" "OK"
  else
    fail "Pas de connexion internet"
    record "internet" "FAIL"
  fi

  if ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
    ok "DNS Cloudflare (1.1.1.1) joignable"
    record "dns" "OK"
  else
    warn "DNS Cloudflare non joignable"
    record "dns" "WARN"
  fi

  local ip
  ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  info "IP locale : ${ip:-non disponible}"
}

check_git() {
  section "GIT & GITHUB"

  if command -v git &>/dev/null; then
    ok "git disponible ($(git --version | cut -d' ' -f3))"
    record "git" "OK"
  else
    warn "git non installé — lance : pkg install git"
    record "git" "WARN"
  fi

  if [[ -d "${SCRIPT_DIR}/.git" ]]; then
    ok "Repo git initialisé"
    record "git_repo" "OK"
    local remote
    remote=$(cd "$SCRIPT_DIR" && git remote get-url origin 2>/dev/null)
    if [[ -n "$remote" ]]; then
      ok "Remote origin : ${remote}"
      record "git_remote" "OK"
    else
      warn "Pas de remote configuré — lance setup_github.sh"
      record "git_remote" "WARN"
    fi
  else
    warn "Aucun repo git — lance setup_github.sh pour initialiser"
    record "git_repo" "WARN"
  fi
}

show_report() {
  section "RAPPORT FINAL"

  local total=$((PASS+WARN+FAIL))
  echo -e " ${G}Succès   : ${PASS}${N}"
  echo -e " ${Y}Alertes  : ${WARN}${N}"
  echo -e " ${R}Échecs   : ${FAIL}${N}"
  echo -e " ${D}Total    : ${total}${N}\n"

  if [[ $FAIL -eq 0 && $WARN -eq 0 ]]; then
    echo -e " ${G}[✓] Environnement en parfaite santé.${N}"
  elif [[ $FAIL -eq 0 ]]; then
    echo -e " ${Y}[!] Environnement fonctionnel avec ${WARN} alerte(s).${N}"
  else
    echo -e " ${R}[✗] ${FAIL} problème(s) critique(s) à corriger.${N}"
  fi

  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${W}Sauvegarder le rapport ? [o/N] : ${N}"
  read -r SAVE
  if [[ "$SAVE" =~ ^[oO]$ ]]; then
    {
      echo "=== KaliTermux Doctor Report ==="
      echo "Date : $(date)"
      echo ""
      echo "Succès : $PASS | Alertes : $WARN | Échecs : $FAIL"
      echo ""
      for key in "${!RESULTS[@]}"; do
        printf "%-35s %s\n" "$key" "${RESULTS[$key]}"
      done
    } > "$REPORT_FILE"
    echo -e " ${G}✓${N} ${W}Rapport sauvegardé : ${REPORT_FILE}${N}"
    log "Rapport sauvegardé : $REPORT_FILE"
  fi

  log "Doctor terminé — OK:${PASS} WARN:${WARN} FAIL:${FAIL}"
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

run_full() {
  clear
  show_ascii
  check_termux
  check_linux
  check_tools
  check_scripts
  check_network
  check_git
  show_report
}

main_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}\n"
    echo -e " ${R}[${W}1${R}]${N} ${W}Diagnostic complet${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Termux uniquement${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Linux / proot${N}"
    echo -e " ${R}[${W}4${R}]${N} ${W}Outils installés${N}"
    echo -e " ${R}[${W}5${R}]${N} ${W}Scripts du projet${N}"
    echo -e " ${R}[${W}6${R}]${N} ${W}Réseau${N}"
    echo -e " ${R}[${W}7${R}]${N} ${W}Git & GitHub${N}"
    echo -e "\n ${R}[${W}0${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1) PASS=0; WARN=0; FAIL=0; run_full ;;
      2) PASS=0; WARN=0; FAIL=0; clear; show_ascii; check_termux; show_report ;;
      3) PASS=0; WARN=0; FAIL=0; clear; show_ascii; check_linux;  show_report ;;
      4) PASS=0; WARN=0; FAIL=0; clear; show_ascii; check_tools;  show_report ;;
      5) PASS=0; WARN=0; FAIL=0; clear; show_ascii; check_scripts; show_report ;;
      6) PASS=0; WARN=0; FAIL=0; clear; show_ascii; check_network; show_report ;;
      7) PASS=0; WARN=0; FAIL=0; clear; show_ascii; check_git;    show_report ;;
      0) clear; exit 0 ;;
      *) sleep 0.5 ;;
    esac
  done
}

clear
show_ascii
log "===== doctor.sh lancé ====="
main_menu
