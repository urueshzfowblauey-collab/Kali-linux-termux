#!/bin/bash

source "$(dirname "$0")/config.sh" 2>/dev/null || {
  GITHUB_KALI="https://github.com/kyaev/kali-termux"
  GITHUB_TOOLS="https://github.com/kyaev/kali-tools"
  KALI_DIR="$HOME/kali-fs"
}

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
W='\033[1;37m'
D='\033[2;37m'
B='\033[0;34m'
M='\033[0;35m'
N='\033[0m'
BOLD='\033[1m'
BLINK='\033[5m'

clear

ASCII="
${R}⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
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

show_ascii() {
  echo -e "$ASCII"
  echo -e "${R}${BOLD}  ╔══════════════════════════════════════════╗${N}"
  echo -e "${R}${BOLD}  ║     ${W}K A L I - T E R M U X   T O O L S${R}     ║${N}"
  echo -e "${R}${BOLD}  ║         ${D}by LinuxKyaev  •  v1.0${R}             ║${N}"
  echo -e "${R}${BOLD}  ╚══════════════════════════════════════════╝${N}"
  echo
}

loading_vfx() {
  local msg="$1"
  local chars="⣾⣽⣻⢿⡿⣟⣯⣷"
  local i=0
  echo -ne "${C}"
  while true; do
    local c="${chars:$i:1}"
    echo -ne "\r  ${c}  ${msg}..."
    i=$(( (i+1) % 8 ))
    sleep 0.08
  done
}

progress_bar() {
  local label="$1"
  local total=40
  echo -ne "\n  ${Y}${label}${N}\n  ${R}["
  for ((i=0; i<total; i++)); do
    sleep 0.04
    echo -ne "${R}█"
  done
  echo -e "${R}] ${G}DONE${N}"
}

install_deps() {
  echo -e "\n${Y}  [*] Vérification des dépendances...${N}\n"
  sleep 0.5

  local deps=("proot" "wget" "curl" "tar" "bzip2" "nmap" "python" "git")
  for dep in "${deps[@]}"; do
    echo -ne "  ${C}[+] ${dep}${N}"
    if command -v "$dep" &>/dev/null; then
      echo -e " ${G}✓ déjà installé${N}"
    else
      echo -ne " ${Y}installation...${N}"
      pkg install -y "$dep" &>/dev/null 2>&1 && echo -e " ${G}✓${N}" || echo -e " ${R}✗ échec${N}"
    fi
    sleep 0.15
  done
  echo
}

setup_kali() {
  clear
  show_ascii
  echo -e "${R}  [*] Initialisation de Kali Linux...${N}\n"

  loading_vfx "Téléchargement du rootfs Kali" &
  local LOAD_PID=$!

  mkdir -p "$KALI_DIR"
  local ARCH
  ARCH=$(uname -m)
  local URL=""
  case "$ARCH" in
    aarch64) URL="https://kali.download/nethunter-images/current/rootfs/kalifs-arm64-minimal.tar.xz" ;;
    armv7l)  URL="https://kali.download/nethunter-images/current/rootfs/kalifs-armhf-minimal.tar.xz" ;;
    x86_64)  URL="https://kali.download/nethunter-images/current/rootfs/kalifs-amd64-minimal.tar.xz" ;;
    *)       kill $LOAD_PID 2>/dev/null; echo -e "\n${R}  [!] Architecture non supportée: $ARCH${N}"; return 1 ;;
  esac

  wget -q --show-progress -O "$KALI_DIR/rootfs.tar.xz" "$URL" 2>&1 | \
    grep -o '[0-9]*%' | tail -1
  kill $LOAD_PID 2>/dev/null
  echo -e "\n  ${G}[✓] Téléchargement terminé${N}"

  progress_bar "Extraction du système de fichiers"
  cd "$KALI_DIR" && tar -xf rootfs.tar.xz 2>/dev/null
  rm -f rootfs.tar.xz

  progress_bar "Configuration de l'environnement"
  mkdir -p "$KALI_DIR/kali-arm64" 2>/dev/null || \
    mkdir -p "$KALI_DIR/kali-amd64" 2>/dev/null

  echo -e "\n  ${G}[✓] Kali Linux installé avec succès !${N}\n"
  sleep 1
}

launch_kali() {
  clear
  show_ascii

  local ROOTFS
  ROOTFS=$(find "$KALI_DIR" -maxdepth 1 -type d -name "kali-*" 2>/dev/null | head -1)

  if [ -z "$ROOTFS" ]; then
    echo -e "${Y}  [!] Kali non installé. Lancement de l'installation...${N}"
    sleep 1
    install_deps
    setup_kali
    ROOTFS=$(find "$KALI_DIR" -maxdepth 1 -type d -name "kali-*" 2>/dev/null | head -1)
  fi

  if [ -z "$ROOTFS" ]; then
    echo -e "${R}  [✗] Erreur: Impossible de trouver le rootfs Kali.${N}"
    sleep 2
    return
  fi

  echo -e "${R}  [*] Démarrage de Kali Linux...${N}"

  local i=0
  local frames=("[ ·· ]" "[ ··· ]" "[ ···· ]" "[ ····· ]" "[ ···· ]" "[ ··· ]")
  for ((t=0; t<20; t++)); do
    echo -ne "\r  ${R}${frames[$((i % 6))]}${N}"
    i=$((i+1))
    sleep 0.1
  done
  echo -e "\n"

  echo -ne "${W}  Entrez votre pseudo : ${G}"
  read -r USERNAME
  echo -ne "${N}"
  [ -z "$USERNAME" ] && USERNAME="user"

  echo -e "\n${R}  ╔══════════════════════════════════╗${N}"
  echo -e "${R}  ║  ${G}Bienvenue, ${W}${USERNAME}${G} !${R}                  ║${N}"
  echo -e "${R}  ║  ${D}LinuxKyaev shell actif${R}            ║${N}"
  echo -e "${R}  ╚══════════════════════════════════╝${N}\n"
  sleep 0.5

  proot \
    --link2symlink \
    -0 \
    -r "$ROOTFS" \
    -b /dev \
    -b /proc \
    -b /sys \
    -b "$HOME:/LinuxUser/$USERNAME" \
    -w "/LinuxUser/$USERNAME" \
    /usr/bin/env -i \
      HOME="/LinuxUser/$USERNAME" \
      TERM="$TERM" \
      LANG=C.UTF-8 \
      PS1="${R}┌──(${G}LinuxKyaev${R})-[${W}\w${R}]\n└─${G}[\u]${W}\$ ${N}" \
      PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    /bin/bash --login 2>/dev/null

  echo -e "\n${Y}  [*] Session Kali terminée.${N}"
  sleep 1
}

update_kali() {
  clear
  show_ascii

  local ROOTFS
  ROOTFS=$(find "$KALI_DIR" -maxdepth 1 -type d -name "kali-*" 2>/dev/null | head -1)

  if [ -z "$ROOTFS" ]; then
    echo -e "${R}  [!] Kali non installé. Installez d'abord.${N}"
    sleep 2
    return
  fi

  echo -e "${R}  [*] Mise à jour de Kali Linux...${N}\n"

  loading_vfx "Connexion aux serveurs Kali" &
  local LOAD_PID=$!
  sleep 2
  kill $LOAD_PID 2>/dev/null
  echo -e "\n"

  proot \
    --link2symlink \
    -0 \
    -r "$ROOTFS" \
    -b /dev \
    -b /proc \
    -b /sys \
    -w "/root" \
    /usr/bin/env -i \
      HOME="/root" \
      TERM="$TERM" \
      LANG=C.UTF-8 \
      PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    /bin/bash -c "apt update && apt upgrade -y && apt autoremove -y" 2>/dev/null

  echo -e "\n  ${G}[✓] Mise à jour terminée.${N}"
  sleep 2
}

kali_menu() {
  while true; do
    clear
    show_ascii
    echo -e "${R}  ╔══════════════════════════════════════════╗${N}"
    echo -e "${R}  ║            ${W}MENU PRINCIPAL${R}                 ║${N}"
    echo -e "${R}  ╠══════════════════════════════════════════╣${N}"
    echo -e "${R}  ║  ${G}[1]${W} Lancer Kali Linux                   ${R}║${N}"
    echo -e "${R}  ║  ${Y}[2]${W} Mettre à jour Kali                  ${R}║${N}"
    echo -e "${R}  ║  ${B}[3]${W} Quitter                             ${R}║${N}"
    echo -e "${R}  ╚══════════════════════════════════════════╝${N}"
    echo
    echo -ne "  ${R}»${W} Option : ${N}"
    read -r OPT
    case "$OPT" in
      1) launch_kali ;;
      2) update_kali ;;
      3)
        clear
        show_ascii
        echo -e "${R}  [*] Fermeture de KaliTermux...${N}\n"
        for ((i=3; i>=1; i--)); do
          echo -ne "\r  ${Y}Fermeture dans ${i}s...${N}"
          sleep 1
        done
        echo -e "\n\n  ${G}À bientôt !${N}\n"
        exit 0
        ;;
      *) echo -e "\n  ${R}[!] Option invalide.${N}"; sleep 1 ;;
    esac
  done
}

tools_menu() {
  source "$(dirname "$0")/config.sh" 2>/dev/null
  while true; do
    clear
    show_ascii
    echo -e "${R}  ╔══════════════════════════════════════════╗${N}"
    echo -e "${R}  ║              ${W}TOOLS MENU${R}                   ║${N}"
    echo -e "${R}  ╠══════════════════════════════════════════╣${N}"
    local idx=1
    for tool in "${!TOOLS[@]}"; do
      printf "${R}  ║  ${G}[%d]${W} %-38s${R}║${N}\n" "$idx" "$tool"
      idx=$((idx+1))
    done
    echo -e "${R}  ║  ${Y}[h]${W} Help                                ${R}║${N}"
    echo -e "${R}  ║  ${B}[b]${W} Retour                              ${R}║${N}"
    echo -e "${R}  ╚══════════════════════════════════════════╝${N}"
    echo
    echo -ne "  ${R}»${W} Choix : ${N}"
    read -r CHOICE

    case "$CHOICE" in
      h|H)
        clear
        show_ascii
        echo -e "${R}  ╔══════════════════════════════════════════╗${N}"
        echo -e "${R}  ║              ${W}COMMANDES${R}                    ║${N}"
        echo -e "${R}  ╠══════════════════════════════════════════╣${N}"
        echo -e "${R}  ║  ${G}help${W}    - Afficher cette aide          ${R}║${N}"
        echo -e "${R}  ║  ${G}tools${W}   - Menu des outils              ${R}║${N}"
        echo -e "${R}  ║  ${G}update${W}  - Mettre à jour les tools      ${R}║${N}"
        echo -e "${R}  ║  ${G}clear${W}   - Effacer l'écran              ${R}║${N}"
        echo -e "${R}  ║  ${G}exit${W}    - Quitter                      ${R}║${N}"
        echo -e "${R}  ╚══════════════════════════════════════════╝${N}"
        echo
        echo -ne "  ${D}[Entrée pour continuer]${N}"
        read -r
        ;;
      b|B) return ;;
      [0-9]*)
        local idx=1
        for tool in "${!TOOLS[@]}"; do
          if [ "$idx" -eq "$CHOICE" ]; then
            local url="${TOOLS[$tool]}"
            echo -e "\n  ${C}[*] Installation de ${W}${tool}${N}..."
            if [ -n "$url" ]; then
              git clone "$url" "$HOME/tools/$tool" 2>&1 | \
                while IFS= read -r line; do echo "  ${D}$line${N}"; done
              echo -e "  ${G}[✓] ${tool} installé dans ~/tools/${tool}${N}"
            else
              echo -e "  ${Y}[!] Pas de dépôt configuré pour ${tool}.${N}"
            fi
            echo -ne "\n  ${D}[Entrée pour continuer]${N}"
            read -r
            break
          fi
          idx=$((idx+1))
        done
        ;;
    esac
  done
}

main() {
  clear
  show_ascii

  loading_vfx "Initialisation de KaliTermux" &
  LOAD_PID=$!
  install_deps
  kill $LOAD_PID 2>/dev/null
  echo -e "\n  ${G}[✓] Système prêt.${N}\n"
  sleep 0.5

  if command -v proot &>/dev/null; then
    kali_menu
  else
    echo -e "${R}  [!] proot non disponible. Certaines fonctions limitées.${N}"
    sleep 2
    kali_menu
  fi
}

case "$1" in
  tools) tools_menu ;;
  help)
    show_ascii
    echo -e "${W}  Usage: bash kali.sh [commande]${N}"
    echo -e "  ${G}tools${N}   - Accès direct au menu tools"
    echo -e "  ${G}help${N}    - Afficher cette aide"
    echo -e "  ${G}(rien)${N}  - Lancer le menu principal"
    ;;
  exit) exit 0 ;;
  *) main ;;
esac
