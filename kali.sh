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
HIDE='\033[?25l'
SHOW='\033[?25h'

trap "echo -e '${SHOW}${N}'; exit" INT TERM

matrix_rain() {
  echo -e "${HIDE}"
  local cols lines start
  cols=$(tput cols 2>/dev/null || echo 80)
  lines=$(tput lines 2>/dev/null || echo 24)
  start=$(date +%s)
  local chars="ｱｲｳｴｵｶｷｸｹｺ0123456789ABCDEF"
  local clen=${#chars}
  tput clear
  while true; do
    local now; now=$(date +%s)
    [ $((now - start)) -ge 2 ] && break
    for ((i=0; i<6; i++)); do
      local col=$((RANDOM % cols))
      local row=$((RANDOM % lines))
      local idx=$((RANDOM % clen))
      local c="${chars:$idx:1}"
      tput cup $row $col
      [ $((RANDOM % 4)) -eq 0 ] && echo -ne "${W}${c}${N}" || echo -ne "${G}${c}${N}"
    done
    sleep 0.03
  done
  tput clear
  echo -e "${SHOW}"
}

show_ascii() {
  echo -e "${RB}⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣦⣤⣄⣈⡑⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮⣷⣤⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯⣧⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢷⡤⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣯⡛⠻⢦⡀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣆⠀⠙⢆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣆⠀⠈⢣
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⡆⠀⠈
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀${N}"
  echo
  echo -e "${W}        K A L I - T E R M U X   T O O L S${N}"
  echo -e "${D}              by LinuxKyaev  •  v2.0${N}\n"
}

progress_bar() {
  local label="$1"
  local total=30
  echo -ne "\n  ${W}${label}${N}\n  ${R}["
  for ((i=0; i<total; i++)); do
    sleep 0.04
    echo -ne "${R}█"
  done
  echo -e "${W}]  ${R}OK${N}"
  sleep 0.2
}

install_deps() {
  echo -e "\n${R}  [*]${W} Vérification des dépendances...${N}\n"
  local deps=("proot" "wget" "curl" "tar" "git")
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
  echo -e "${R}  [*]${W} Téléchargement de Kali Linux...${N}\n"
  install_deps
  local ARCH; ARCH=$(uname -m)
  local URL=""
  case "$ARCH" in
    aarch64) URL="https://kali.download/nethunter-images/current/rootfs/kalifs-arm64-minimal.tar.xz" ;;
    armv7l)  URL="https://kali.download/nethunter-images/current/rootfs/kalifs-armhf-minimal.tar.xz" ;;
    x86_64)  URL="https://kali.download/nethunter-images/current/rootfs/kalifs-amd64-minimal.tar.xz" ;;
    *)
      echo -e "${W}  [!] Architecture non supportée: ${R}$ARCH${N}"
      sleep 2; return 1 ;;
  esac
  mkdir -p "$KALI_DIR"
  echo -e "  ${R}[*]${W} Architecture : ${R}${ARCH}${N}"
  echo -e "  ${R}[*]${W} Téléchargement en cours...${N}\n"
  wget -q --show-progress -O "$KALI_DIR/rootfs.tar.xz" "$URL"
  echo -e "\n  ${R}[✓]${W} Téléchargement terminé${N}"
  progress_bar "Extraction du rootfs"
  cd "$KALI_DIR" && tar -xf rootfs.tar.xz 2>/dev/null
  rm -f rootfs.tar.xz
  progress_bar "Configuration"
  echo -e "\n  ${R}[✓]${W} Kali Linux installé !${N}\n"
  sleep 1
}

get_rootfs() {
  find "$KALI_DIR" -maxdepth 1 -type d -name "kali-*" 2>/dev/null | head -1
}

launch_kali() {
  local ROOTFS; ROOTFS=$(get_rootfs)
  if [ -z "$ROOTFS" ]; then
    echo -e "\n  ${W}[!]${R} Kali non installé.${N}"
    sleep 1; return
  fi

  clear
  show_ascii

  echo -ne "  ${R}Pseudo : ${W}"
  read -r USERNAME
  [ -z "$USERNAME" ] && USERNAME="user"
  echo -e "${N}"

  local frames=("▓░░░░░░░░░" "▓▓░░░░░░░░" "▓▓▓░░░░░░░" "▓▓▓▓░░░░░░" "▓▓▓▓▓░░░░░" "▓▓▓▓▓▓░░░░" "▓▓▓▓▓▓▓░░░" "▓▓▓▓▓▓▓▓░░" "▓▓▓▓▓▓▓▓▓░" "▓▓▓▓▓▓▓▓▓▓")
  for f in "${frames[@]}"; do
    echo -ne "\r  ${R}Boot  [${W}${f}${R}]${N}"
    sleep 0.08
  done
  echo -e "\r  ${R}Boot  [${W}▓▓▓▓▓▓▓▓▓▓${R}]  ${W}OK${N}\n"

  proot \
    --link2symlink \
    -0 \
    -r "$ROOTFS" \
    -b /dev \
    -b /proc \
    -b /sys \
    -b "$HOME:/root/LinuxUser" \
    -w "/root" \
    /usr/bin/env -i \
      HOME="/root" \
      KALI_USER="$USERNAME" \
      TERM="$TERM" \
      LANG=C.UTF-8 \
      PS1="\[\033[1;31m\]┌──(\[\033[1;37m\]LinuxKyaev\[\033[1;31m\])-[\[\033[1;37m\]${USERNAME}@\w\[\033[1;31m\]]\n\[\033[1;31m\]└─# \[\033[0m\]" \
      PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    /bin/bash --login 2>/dev/null

  echo -e "\n  ${R}[*]${W} Session terminée.${N}"
  sleep 1
}

update_kali() {
  local ROOTFS; ROOTFS=$(get_rootfs)
  if [ -z "$ROOTFS" ]; then
    echo -e "\n  ${W}[!]${R} Kali non installé.${N}"
    sleep 2; return
  fi
  clear
  show_ascii
  echo -e "${R}  [*]${W} Mise à jour de Kali Linux...${N}\n"
  proot \
    --link2symlink -0 -r "$ROOTFS" \
    -b /dev -b /proc -b /sys -w "/root" \
    /usr/bin/env -i HOME="/root" TERM="$TERM" LANG=C.UTF-8 \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    /bin/bash -c "apt update && apt upgrade -y && apt autoremove -y" 2>/dev/null
  echo -e "\n  ${R}[✓]${W} Mise à jour terminée.${N}"
  sleep 2
}

tools_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R}  ──────────────────────${N}"
    echo -e "${W}    TOOLS${N}"
    echo -e "${R}  ──────────────────────${N}\n"
    local idx=1
    local tool_keys=()
    for tool in "${!TOOLS[@]}"; do tool_keys+=("$tool"); done
    for tool in "${tool_keys[@]}"; do
      sleep 0.05
      echo -e "  ${R}[${W}${idx}${R}]${N} ${W}${tool}${N}"
      idx=$((idx+1))
    done
    sleep 0.05
    echo -e "  ${R}[${W}b${R}]${N} ${D}Retour${N}"
    echo -e "\n${R}  ──────────────────────${N}"
    echo -ne "\n  ${R}» ${W}"
    read -r CHOICE
    echo -ne "${N}"
    [ "$CHOICE" = "b" ] || [ "$CHOICE" = "B" ] && return
    local idx=1
    for tool in "${tool_keys[@]}"; do
      if [ "$idx" -eq "$CHOICE" ] 2>/dev/null; then
        local url="${TOOLS[$tool]}"
        echo -e "\n  ${R}[*]${W} Installation de ${R}${tool}${N}..."
        if [ -n "$url" ]; then
          mkdir -p "$HOME/tools"
          git clone "$url" "$HOME/tools/$tool" 2>&1 | while IFS= read -r line; do echo "  ${D}$line${N}"; done
          echo -e "\n  ${R}[✓]${W} ${tool} → ${R}~/tools/${tool}${N}"
        else
          echo -e "  ${W}[!]${R} Aucun dépôt pour ${tool}. Modifie config.sh${N}"
        fi
        echo -ne "\n  ${D}[Entrée]${N}"; read -r
        break
      fi
      idx=$((idx+1))
    done
  done
}

help_cmd() {
  echo -e "\n${R}  ──────────────────────${N}"
  echo -e "  ${R}help${N}   → cette aide"
  echo -e "  ${R}tools${N}  → menu tools"
  echo -e "  ${R}update${N} → màj kali"
  echo -e "  ${R}clear${N}  → effacer"
  echo -e "  ${R}exit${N}   → quitter"
  echo -e "${R}  ──────────────────────${N}\n"
}

main_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R}  ──────────────────────${N}\n"
    sleep 0.08; echo -e "  ${R}[${W}1${R}]${N} ${W}Lancer Kali Linux${N}"
    sleep 0.08; echo -e "  ${R}[${W}2${R}]${N} ${W}Mettre à jour Kali${N}"
    sleep 0.08; echo -e "  ${R}[${W}3${R}]${N} ${W}Sortir${N}"
    echo -e "\n${R}  ──────────────────────${N}"
    echo -ne "\n  ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1) launch_kali ;;
      2) update_kali ;;
      3) clear; show_ascii; echo -e "\n  ${D}À bientôt.${N}\n"; sleep 0.8; exit 0 ;;
      help) help_cmd; echo -ne "  ${D}[Entrée]${N}"; read -r ;;
      tools) tools_menu ;;
      update) update_kali ;;
      clear) clear ;;
      exit) exit 0 ;;
      *) echo -e "\n  ${W}[!]${R} Invalide.${N}"; sleep 0.5 ;;
    esac
  done
}

install_menu() {
  clear
  show_ascii
  echo -e "${R}  ──────────────────────${N}\n"
  sleep 0.08; echo -e "  ${R}[${W}1${R}]${N} ${W}Télécharger Kali Linux${N}"
  echo -e "\n${R}  ──────────────────────${N}"
  echo -ne "\n  ${R}» ${W}"
  read -r OPT
  echo -ne "${N}"
  case "$OPT" in
    1) download_kali ;;
    exit) exit 0 ;;
    *) echo -e "\n  ${W}[!]${R} Invalide.${N}"; sleep 0.5; install_menu ;;
  esac
}

clear
matrix_rain
clear
show_ascii
sleep 0.3

ROOTFS=$(get_rootfs)
if [ -z "$ROOTFS" ]; then
  install_menu
fi

main_menu
