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
VPN_DIR="${SCRIPT_DIR}/vpn_profiles"
LOG_FILE="${SCRIPT_DIR}/update.log"
PID_FILE="/tmp/openvpn_kt.pid"

trap "echo -e '${N}'; exit" INT TERM

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VPN] $1" >> "$LOG_FILE"
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
  echo -e "${W} K A L I - T E R M U X  —  V P N${N}\n"
}

# ─── STATUT VPN ─────────────────────────────────────
vpn_status() {
  local running=false
  local pid=""
  local iface=""
  local ip_vpn=""
  local ip_pub=""

  if [[ -f "$PID_FILE" ]]; then
    pid=$(cat "$PID_FILE" 2>/dev/null)
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      running=true
    else
      rm -f "$PID_FILE"
    fi
  fi

  if proot-distro list 2>&1 | grep -q "ubuntu"; then
    iface=$(proot-distro login ubuntu -- bash -c "ip link show tun0 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' '" 2>/dev/null)
    if [[ -n "$iface" ]]; then
      running=true
      ip_vpn=$(proot-distro login ubuntu -- bash -c "ip addr show tun0 2>/dev/null | grep 'inet ' | awk '{print \$2}'" 2>/dev/null)
    fi
  fi

  ip_pub=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "non disponible")

  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} STATUT VPN${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  if $running; then
    echo -e " ${G}[●] VPN ACTIF${N}"
    [[ -n "$ip_vpn" ]] && echo -e " ${D}Interface :${N} ${W}tun0 (${ip_vpn})${N}"
    [[ -n "$pid" ]]    && echo -e " ${D}PID       :${N} ${W}${pid}${N}"
  else
    echo -e " ${R}[○] VPN INACTIF${N}"
  fi

  echo -e " ${D}IP publique :${N} ${W}${ip_pub}${N}"
  echo -e "\n${R} ──────────────────────────────────${N}"
}

# ─── INSTALLER OPENVPN ──────────────────────────────
install_openvpn() {
  if ! proot-distro list 2>&1 | grep -q "ubuntu"; then
    echo -e "\n ${R}[✗] Linux non installé.${N}"; sleep 2; return 1
  fi

  local installed
  installed=$(proot-distro login ubuntu -- bash -c "command -v openvpn &>/dev/null && echo YES || echo NO" 2>/dev/null)

  if [[ "$installed" == "YES" ]]; then
    echo -e "\n ${G}[✓] OpenVPN déjà installé.${N}"
    return 0
  fi

  echo -e "\n ${D}Installation d'OpenVPN...${N}"
  proot-distro login ubuntu -- bash -c "apt update -qq && apt install -y openvpn -qq" 2>/dev/null && \
    echo -e " ${G}[✓] OpenVPN installé.${N}" || \
    echo -e " ${R}[✗] Échec installation.${N}"
}

# ─── GESTION PROFILS ────────────────────────────────
list_profiles() {
  mkdir -p "$VPN_DIR"
  local profiles=("$VPN_DIR"/*.ovpn 2>/dev/null)
  if [[ ! -f "${profiles[0]}" ]]; then
    echo -e "\n ${D}Aucun profil .ovpn trouvé dans :${N}"
    echo -e " ${W}${VPN_DIR}/${N}\n"
    return 1
  fi

  echo -e "\n ${D}Profils disponibles :${N}\n"
  local idx=1
  for f in "$VPN_DIR"/*.ovpn; do
    local name
    name=$(basename "$f" .ovpn)
    echo -e " ${R}[${W}${idx}${R}]${N} ${W}${name}${N}"
    idx=$((idx+1))
  done
  return 0
}

add_profile_menu() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} AJOUTER UN PROFIL VPN${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  mkdir -p "$VPN_DIR"
  echo -e " ${D}Dossier des profils :${N} ${W}${VPN_DIR}/${N}\n"
  echo -e " ${Y}[1]${N} ${W}Colle manuellement le contenu d'un fichier .ovpn${N}"
  echo -e " ${Y}[2]${N} ${W}Copier un .ovpn depuis Termux (chemin)${N}"
  echo -e " ${Y}[3]${N} ${W}Télécharger depuis une URL${N}"
  echo -e "\n ${R}[b]${N} ${D}Retour${N}"
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${R}» ${W}"
  read -r OPT
  echo -ne "${N}"

  case "$OPT" in
    1)
      echo -ne "\n ${W}Nom du profil (sans .ovpn) : ${N}"
      read -r PNAME
      [[ -z "$PNAME" ]] && return
      echo -e " ${D}Colle le contenu .ovpn, termine avec CTRL+D :${N}"
      cat > "${VPN_DIR}/${PNAME}.ovpn"
      echo -e "\n ${G}✓${N} ${W}Profil '${PNAME}' sauvegardé.${N}"
      log "Profil ajouté : $PNAME"
      ;;
    2)
      echo -ne "\n ${W}Chemin du fichier .ovpn : ${N}"
      read -r FPATH
      if [[ -f "$FPATH" ]]; then
        local fname
        fname=$(basename "$FPATH")
        cp "$FPATH" "${VPN_DIR}/${fname}"
        echo -e " ${G}✓${N} ${W}${fname} copié.${N}"
        log "Profil copié : $fname"
      else
        echo -e " ${R}[✗] Fichier introuvable.${N}"
      fi
      ;;
    3)
      echo -ne "\n ${W}URL du fichier .ovpn : ${N}"
      read -r URL
      echo -ne " ${W}Nom du profil (sans .ovpn) : ${N}"
      read -r PNAME
      [[ -z "$PNAME" || -z "$URL" ]] && return
      curl -sL "$URL" -o "${VPN_DIR}/${PNAME}.ovpn" && {
        echo -e " ${G}✓${N} ${W}Profil téléchargé.${N}"
        log "Profil téléchargé : $PNAME"
      } || echo -e " ${R}[✗] Échec du téléchargement.${N}"
      ;;
    b|B) return ;;
  esac
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

delete_profile_menu() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} SUPPRIMER UN PROFIL${N}"
  echo -e "${R} ──────────────────────────────────${N}"
  list_profiles || { echo -ne "\n ${D}Entrée...${N}"; read -r; return; }

  echo -ne "\n ${W}Numéro à supprimer (vide = annuler) : ${N}"
  read -r CHOICE
  [[ -z "$CHOICE" ]] && return

  local profiles=("$VPN_DIR"/*.ovpn)
  local idx=$((CHOICE-1))
  if [[ -f "${profiles[$idx]}" ]]; then
    local name
    name=$(basename "${profiles[$idx]}")
    echo -ne " ${R}[?]${N} ${W}Supprimer ${name} ? [o/N] : ${N}"
    read -r CONFIRM
    if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
      rm -f "${profiles[$idx]}"
      echo -e " ${G}✓${N} ${W}Supprimé.${N}"
      log "Profil supprimé : $name"
    fi
  else
    echo -e " ${R}[✗] Numéro invalide.${N}"
  fi
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

# ─── CONNEXION ──────────────────────────────────────
connect_vpn() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} CONNEXION VPN${N}"
  echo -e "${R} ──────────────────────────────────${N}"

  install_openvpn || return

  list_profiles || {
    echo -e "\n ${Y}[!]${N} ${W}Ajoute d'abord un profil .ovpn.${N}"
    echo -ne "\n ${D}Entrée...${N}"; read -r; return
  }

  echo -ne "\n ${W}Numéro du profil : ${N}"
  read -r CHOICE
  [[ -z "$CHOICE" ]] && return

  local profiles=("$VPN_DIR"/*.ovpn)
  local idx=$((CHOICE-1))
  if [[ ! -f "${profiles[$idx]}" ]]; then
    echo -e " ${R}[✗] Profil invalide.${N}"
    sleep 2; return
  fi

  local profile="${profiles[$idx]}"
  local pname
  pname=$(basename "$profile" .ovpn)

  # Copie le profil dans le rootfs Linux
  local ROOTFS_TMP
  ROOTFS_TMP=$(find ~/.local/share/proot-distro/installed-rootfs/ubuntu/tmp 2>/dev/null | head -1)
  if [[ -d "$ROOTFS_TMP" ]]; then
    cp "$profile" "${ROOTFS_TMP}/${pname}.ovpn"
  fi

  echo -e "\n ${Y}[!] Connexion en cours (background)...${N}"
  echo -e " ${D}Profil : ${W}${pname}${N}\n"

  echo -ne " ${W}Authentification requise ? [o/N] : ${N}"
  read -r NEED_AUTH

  local auth_opt=""
  if [[ "$NEED_AUTH" =~ ^[oO]$ ]]; then
    echo -ne " ${W}Fichier auth (user:pass) ou vide = interactif : ${N}"
    read -r AUTH_FILE
    if [[ -n "$AUTH_FILE" && -f "$AUTH_FILE" ]]; then
      local auth_dest="${ROOTFS_TMP}/vpn_auth.txt"
      cp "$AUTH_FILE" "$auth_dest"
      auth_opt="--auth-user-pass /tmp/vpn_auth.txt"
    else
      auth_opt="--auth-user-pass"
    fi
  fi

  proot-distro login ubuntu -- bash -c \
    "openvpn --config /tmp/${pname}.ovpn ${auth_opt} --daemon --log /tmp/openvpn.log --writepid /tmp/openvpn.pid && echo OK" 2>/dev/null | grep -q "OK"

  sleep 3

  local tun_up
  tun_up=$(proot-distro login ubuntu -- bash -c "ip link show tun0 2>/dev/null | grep -c UP" 2>/dev/null)

  if [[ "$tun_up" -ge 1 ]]; then
    echo -e " ${G}[✓] VPN connecté sur tun0.${N}"
    log "VPN connecté : $pname"
  else
    echo -e " ${Y}[!] Connexion en cours, vérifie le log :${N}"
    echo -e " ${G}proot-distro login ubuntu -- bash -c 'cat /tmp/openvpn.log'${N}"
    log "VPN connexion tentée : $pname"
  fi

  echo -ne "\n ${D}Entrée...${N}"; read -r
}

# ─── DÉCONNEXION ────────────────────────────────────
disconnect_vpn() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} DÉCONNEXION VPN${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"

  proot-distro login ubuntu -- bash -c \
    "pid=\$(cat /tmp/openvpn.pid 2>/dev/null); [[ -n \"\$pid\" ]] && kill \$pid && echo KILLED || pkill openvpn && echo KILLED" 2>/dev/null | grep -q "KILLED"

  sleep 1

  local tun_up
  tun_up=$(proot-distro login ubuntu -- bash -c "ip link show tun0 2>/dev/null" 2>/dev/null)

  if [[ -z "$tun_up" ]]; then
    echo -e " ${G}[✓] VPN déconnecté.${N}"
    rm -f "$PID_FILE"
    log "VPN déconnecté"
  else
    echo -e " ${Y}[!] tun0 toujours actif — essaie manuellement :${N}"
    echo -e " ${G}proot-distro login ubuntu -- bash -c 'pkill openvpn'${N}"
    log "VPN déconnexion — tun0 encore actif"
  fi

  echo -ne "\n ${D}Entrée...${N}"; read -r
}

# ─── LOG VPN ────────────────────────────────────────
show_vpn_log() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} LOG OPENVPN${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  proot-distro login ubuntu -- bash -c "cat /tmp/openvpn.log 2>/dev/null | tail -30 || echo 'Aucun log disponible.'"
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

# ─── TEST IP AVANT/APRÈS ────────────────────────────
test_ip() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} TEST IP PUBLIQUE${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -e " ${D}Récupération IP publique...${N}"
  local ip
  ip=$(curl -s --max-time 8 https://api.ipify.org 2>/dev/null || \
       curl -s --max-time 8 https://ifconfig.me 2>/dev/null || \
       echo "non disponible")
  echo -e " ${D}IP publique actuelle :${N} ${G}${ip}${N}"

  local geo
  geo=$(curl -s --max-time 5 "https://ipinfo.io/${ip}" 2>/dev/null | \
        grep -E '"city"|"country"|"org"' | tr -d '",' | sed 's/^[ \t]*//')
  if [[ -n "$geo" ]]; then
    echo -e "\n ${D}Infos :${N}"
    while IFS= read -r line; do
      echo -e "  ${W}${line}${N}"
    done <<< "$geo"
  fi

  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

# ─── MENU PRINCIPAL ─────────────────────────────────
main_menu() {
  while true; do
    clear
    show_ascii
    vpn_status

    echo -e "\n ${R}[${W}1${R}]${N} ${W}Connecter un profil VPN${N}"
    echo -e " ${R}[${W}2${R}]${N} ${W}Déconnecter le VPN${N}"
    echo -e " ${R}[${W}3${R}]${N} ${W}Ajouter un profil .ovpn${N}"
    echo -e " ${R}[${W}4${R}]${N} ${W}Supprimer un profil${N}"
    echo -e " ${R}[${W}5${R}]${N} ${W}Voir les logs OpenVPN${N}"
    echo -e " ${R}[${W}6${R}]${N} ${W}Tester mon IP publique${N}"
    echo -e " ${R}[${W}7${R}]${N} ${W}Installer OpenVPN${N}"
    echo -e "\n ${R}[${W}0${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"
    case "$OPT" in
      1) connect_vpn ;;
      2) disconnect_vpn ;;
      3) add_profile_menu ;;
      4) delete_profile_menu ;;
      5) show_vpn_log ;;
      6) test_ip ;;
      7)
        install_openvpn
        echo -ne "\n ${D}Entrée...${N}"; read -r ;;
      0) clear; exit 0 ;;
      *) sleep 0.5 ;;
    esac
  done
}

clear
show_ascii
log "===== vpn.sh lancé ====="
main_menu
