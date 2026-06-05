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

tput_cols()  { tput cols  2>/dev/null || echo 80; }
tput_lines() { tput lines 2>/dev/null || echo 24; }

matrix_rain() {
  echo -e "${HIDE}"
  local cols lines duration=3 start
  cols=$(tput_cols)
  lines=$(tput_lines)
  start=$(date +%s)
  local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
  local clen=${#chars}
  tput clear
  while true; do
    local now; now=$(date +%s)
    [ $((now - start)) -ge $duration ] && break
    local col=$((RANDOM % cols))
    local row=$((RANDOM % lines))
    local idx=$((RANDOM % clen))
    local c="${chars:$idx:1}"
    tput cup $row $col
    if [ $((RANDOM % 5)) -eq 0 ]; then
      echo -ne "${W}${c}${N}"
    else
      echo -ne "${G}${c}${N}"
    fi
    sleep 0.01
  done
  tput clear
  echo -e "${SHOW}"
}

typewriter() {
  local text="$1"
  local delay="${2:-0.01}"
  local i=0
  while [ $i -lt ${#text} ]; do
    echo -ne "${text:$i:1}"
    i=$((i+1))
    sleep "$delay"
  done
}

show_ascii() {
  echo -e "${RB}"
  local lines=(
"⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣦⣤⣄⣈⡑⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮⣷⣤⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯⣧⡀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢷⡤⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣯⡛⠻⢦⡀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣆⠀⠙⢆⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣆⠀⠈⢣"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⡆⠀⠈"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀"
  )
  for line in "${lines[@]}"; do
    typewriter "$line" 0.003
    echo
  done
  echo -e "${N}"
  sleep 0.2
  echo -e "${W}"
  typewriter "        K A L I - T E R M U X   T O O L S" 0.04
  echo -e "${N}"
  echo -e "${D}"
  typewriter "              by LinuxKyaev  •  v2.0" 0.03
  echo -e "${N}\n"
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
  sleep 0.4
  local deps=("proot" "wget" "curl" "tar" "git")
  for dep in "${deps[@]}"; do
    echo -ne "  ${R}+${N} ${W}${dep}${D}..."
    sleep 0.2
    if command -v "$dep" &>/dev/null; then
      echo -e " ${R}ok${N}"
    else
      pkg install -y "$dep" &>/dev/null 2>&1
      command -v "$dep" &>/dev/null && echo -e " ${R}installé${N}" || echo -e " ${W}échec${N}"
    fi
    sleep 0.1
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
  echo -e "  ${R}[*]${W} Source       : ${D}${URL}${N}\n"
  sleep 0.5

  wget -q --show-progress -O "$KALI_DIR/rootfs.tar.xz" "$URL"
  echo -e "\n  ${R}[✓]${W} Téléchargement terminé${N}"

  progress_bar "Extraction du rootfs"
  # --no-same-owner évite les erreurs de permission sous Termux
  cd "$KALI_DIR" && tar --no-same-owner -xf rootfs.tar.xz
  local TAR_EXIT=$?
  rm -f rootfs.tar.xz

  if [ $TAR_EXIT -ne 0 ]; then
    echo -e "\n  ${W}[!]${R} Extraction échouée (code $TAR_EXIT). Réessaie.${N}"
    sleep 2; return 1
  fi

  progress_bar "Configuration de l'environnement"
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

  # Vérifie que bash existe dans le rootfs
  if [ ! -f "$ROOTFS/bin/bash" ]; then
    echo -e "\n  ${W}[!]${R} Rootfs corrompu : /bin/bash introuvable dans${N}"
    echo -e "  ${D}${ROOTFS}${N}"
    echo -e "  ${W}Supprime ~/kali-fs et réinstalle.${N}"
    sleep 3; return
  fi

  clear
  show_ascii

  local frames=("▓░░░░░░░░░" "▓▓░░░░░░░░" "▓▓▓░░░░░░░" "▓▓▓▓░░░░░░" "▓▓▓▓▓░░░░░" "▓▓▓▓▓▓░░░░" "▓▓▓▓▓▓▓░░░" "▓▓▓▓▓▓▓▓░░" "▓▓▓▓▓▓▓▓▓░" "▓▓▓▓▓▓▓▓▓▓")
  echo -ne "\n  ${R}Démarrage  "
  for f in "${frames[@]}"; do
    echo -ne "\r  ${R}Démarrage  [${W}${f}${R}]${N}"
    sleep 0.12
  done
  echo -e "\r  ${R}Démarrage  [${W}▓▓▓▓▓▓▓▓▓▓${R}]  ${W}PRÊT${N}\n"
  sleep 0.3

  echo -ne "  ${R}Pseudo : ${W}"
  read -r USERNAME
  [ -z "$USERNAME" ] && USERNAME="user"
  echo -e "${N}"
  sleep 0.4
  echo -e "  ${D}Connexion en cours...${N}"
  sleep 0.6

  # FIX PRINCIPAL : on appelle /bin/bash directement au lieu de passer
  # par /usr/bin/env qui peut être absent dans certains rootfs Kali minimal
  proot \
    --link2symlink \
    -0 \
    -r "$ROOTFS" \
    -b /dev \
    -b /proc \
    -b /sys \
    -b "$HOME:/root/LinuxUser" \
    -w "/root" \
    /bin/bash --login

  local EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ]; then
    echo -e "\n  ${W}[!]${R} proot a quitté avec le code : ${EXIT_CODE}${N}"
    echo -e "  ${D}Essaie : pkg update && pkg upgrade proot${N}"
  fi

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
  sleep 0.5
  proot \
    --link2symlink \
    -0 \
    -r "$ROOTFS" \
    -b /dev -b /proc -b /sys \
    -w "/root" \
    /bin/bash -c "apt update && apt upgrade -y && apt autoremove -y"

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
      sleep 0.07
      echo -e "  ${R}[${W}${idx}${R}]${N}  ${W}${tool}${N}"
      idx=$((idx+1))
    done
    sleep 0.07
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
        echo -e "\n  ${R}[*]${W} Installation de ${R}${tool}${N}..."
        sleep 0.3
        if [ -n "$url" ]; then
          mkdir -p "$HOME/tools"
          git clone "$url" "$HOME/tools/$tool" 2>&1 | \
            while IFS= read -r line; do echo "  ${D}  $line${N}"; done
          echo -e "\n  ${R}[✓]${W} ${tool} → ${R}~/tools/${tool}${N}"
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
  echo -e "  ${R}update${N}  ${D}→${N}  mettre à jour kali"
  echo -e "  ${R}clear${N}   ${D}→${N}  effacer l'écran"
  echo -e "  ${R}exit${N}    ${D}→${N}  quitter"
  echo -e "${R}  ──────────────────────────────────${N}\n"
}

main_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R}  ──────────────────────────────────${N}\n"
    sleep 0.1; echo -e "  ${R}[${W}1${R}]${N}  ${W}Lancer Kali Linux${N}"
    sleep 0.1; echo -e "  ${R}[${W}2${R}]${N}  ${W}Mettre à jour Kali${N}"
    sleep 0.1; echo -e "  ${R}[${W}3${R}]${N}  ${W}Sortir${N}"
    echo -e "\n${R}  ──────────────────────────────────${N}"
    echo -ne "\n  ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"

    case "$OPT" in
      1) launch_kali ;;
      2) update_kali ;;
      3)
        clear
        show_ascii
        echo -ne "\n  ${R}"
        typewriter "Fermeture de KaliTermux..." 0.04
        echo -e "${N}\n  ${D}À bientôt.${N}\n"
        sleep 1
        exit 0
        ;;
      help)   help_cmd; echo -ne "  ${D}[Entrée]${N}"; read -r ;;
      tools)  tools_menu ;;
      update) update_kali ;;
      clear)  clear ;;
      exit)   exit 0 ;;
      *)      echo -e "\n  ${W}[!]${R} Commande invalide.${N}"; sleep 0.8 ;;
    esac
  done
}

# ── Démarrage ──────────────────────────────────────────
clear
matrix_rain
clear
show_ascii
sleep 0.5

ROOTFS=$(get_rootfs)
if [ -z "$ROOTFS" ]; then
  install_menu
fi

main_menu
