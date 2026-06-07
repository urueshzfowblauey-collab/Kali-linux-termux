#!/bin/bash

source "$(dirname "$0")/config.sh" 2>/dev/null

R='\033[0;31m'
RB='\033[1;31m'
W='\033[1;37m'
D='\033[2;37m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
N='\033[0m'

SCRIPT_DIR="$(dirname "$0")"
LOG_FILE="${SCRIPT_DIR}/update.log"
SCORE_FILE="${SCRIPT_DIR}/.osint_scores"

trap "echo -e '${N}'; exit" INT TERM

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [OSINT] $1" >> "$LOG_FILE"
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
  echo -e "${W} K A L I - T E R M U X  —  O S I N T${N}\n"
}

# ─── SCORE ──────────────────────────────────────────
load_scores() {
  declare -gA SCORES
  if [[ -f "$SCORE_FILE" ]]; then
    while IFS='=' read -r k v; do
      SCORES["$k"]="$v"
    done < "$SCORE_FILE"
  fi
}

save_score() {
  local key="$1" val="$2"
  SCORES["$key"]="$val"
  > "$SCORE_FILE"
  for k in "${!SCORES[@]}"; do
    echo "${k}=${SCORES[$k]}" >> "$SCORE_FILE"
  done
}

show_scores() {
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} SCORES & PROGRESSION${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  load_scores
  local total=0 done_count=0
  local exercises=("ex01" "ex02" "ex03" "ex04" "ex05" "ex06" "ex07" "ex08" "ex09" "ex10" "ex11" "ex12")
  for ex in "${exercises[@]}"; do
    local sc="${SCORES[$ex]:-0}"
    total=$((total+sc))
    [[ $sc -gt 0 ]] && done_count=$((done_count+1))
    local bar=""
    for ((i=0; i<sc; i++)); do bar+="█"; done
    for ((i=sc; i<5; i++)); do bar+="░"; done
    printf " ${R}%-6s${N} ${W}%s${N} ${D}%d/5${N}\n" "$ex" "$bar" "$sc"
  done
  echo -e "\n${R} ──────────────────────────────────${N}"
  echo -e " ${D}Exercices complétés :${N} ${W}${done_count}/${#exercises[@]}${N}"
  echo -e " ${D}Score total         :${N} ${W}${total} pts${N}"
  echo -e "${R} ──────────────────────────────────${N}"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

# ─── UTILITAIRES ────────────────────────────────────
check_tool() {
  local tool="$1"
  if ! proot-distro list 2>&1 | grep -q "ubuntu"; then
    echo -e "\n ${R}[✗] Linux non installé.${N}"; sleep 2; return 1
  fi
  local found
  found=$(proot-distro login ubuntu -- bash -c "command -v '${tool}' &>/dev/null && echo YES || echo NO" 2>/dev/null)
  if [[ "$found" != "YES" ]]; then
    echo -e "\n ${Y}[!] ${tool} non installé. Installation...${N}"
    proot-distro login ubuntu -- bash -c "apt install -y ${tool} -qq" 2>/dev/null
  fi
  return 0
}

ask_question() {
  local question="$1" answer="$2" hint="$3"
  local attempts=0 max=3 score=5

  while [[ $attempts -lt $max ]]; do
    echo -ne "\n ${C}?${N} ${W}${question}${N}\n ${R}» ${W}"
    read -r USER_ANS
    echo -ne "${N}"
    if echo "$USER_ANS" | grep -iq "^${answer}$"; then
      echo -e "\n ${G}[✓] Correct ! (+${score} pts)${N}"
      echo "$score"
      return 0
    else
      attempts=$((attempts+1))
      score=$((score-1))
      if [[ $attempts -lt $max ]]; then
        echo -e " ${R}[✗] Incorrect.${N} ${D}Indice : ${hint}${N}"
      fi
    fi
  done
  echo -e " ${R}[✗] Réponse : ${G}${answer}${N}"
  echo "0"
  return 1
}

intro_ex() {
  local num="$1" titre="$2" diff="$3" desc="$4"
  clear
  show_ascii
  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} EXERCICE ${num} — ${titre}${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -e " ${D}Difficulté :${N} ${Y}${diff}${N}"
  echo -e " ${D}Objectif   :${N} ${W}${desc}${N}\n"
  echo -e "${R} ──────────────────────────────────${N}"
}

# ═══════════════════════════════════════════════════
# EXERCICES
# ═══════════════════════════════════════════════════

ex01_whois() {
  load_scores
  intro_ex "01" "WHOIS — Infos domaine" "★☆☆☆☆" \
    "Utiliser whois pour obtenir des informations sur un domaine public."
  echo -e "\n ${W}Un domaine t'est donné. Utilise ${G}whois${W} pour répondre.${N}\n"
  echo -e " ${D}Domaine cible :${N} ${G}example.com${N}\n"

  check_tool "whois" || return

  echo -e " ${Y}Lance la commande suivante dans le shell Linux :${N}"
  echo -e " ${G}whois example.com${N}\n"
  echo -ne " ${D}Appuie sur Entrée quand tu es prêt...${N}"; read -r

  proot-distro login ubuntu -- bash -c "whois example.com 2>/dev/null | head -40"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Quel est le registrar de example.com ?" \
    "RESERVED-Internet Assigned Numbers Authority|IANA" \
    "Cherche 'Registrar:' dans la sortie whois")

  save_score "ex01" "$sc"
  log "EX01 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex02_nslookup() {
  load_scores
  intro_ex "02" "DNS — Résolution d'adresses" "★☆☆☆☆" \
    "Utiliser nslookup/dig pour résoudre des enregistrements DNS."
  echo -e "\n ${D}Domaine cible :${N} ${G}github.com${N}\n"

  check_tool "dnsutils" || return

  echo -e " ${Y}Commande suggérée :${N} ${G}nslookup github.com${N}\n"
  echo -ne " ${D}Entrée pour lancer...${N}"; read -r

  proot-distro login ubuntu -- bash -c "nslookup github.com 2>/dev/null | head -20"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Quel type d'enregistrement donne l'adresse IPv4 d'un domaine ?" \
    "A" \
    "C'est la première lettre de l'alphabet")

  save_score "ex02" "$sc"
  log "EX02 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex03_traceroute() {
  load_scores
  intro_ex "03" "TRACEROUTE — Cartographie réseau" "★★☆☆☆" \
    "Analyser le chemin réseau vers une cible et identifier les hops."
  echo -e "\n ${D}Cible :${N} ${G}8.8.8.8 (Google DNS)${N}\n"

  check_tool "traceroute" || return

  echo -e " ${Y}Commande :${N} ${G}traceroute -m 10 8.8.8.8${N}\n"
  echo -ne " ${D}Entrée pour lancer (peut prendre 30s)...${N}"; read -r

  proot-distro login ubuntu -- bash -c "traceroute -m 10 8.8.8.8 2>/dev/null"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Que signifie '* * *' dans une sortie traceroute ?" \
    "paquet perdu|timeout|pas de réponse|icmp bloqué|filtré" \
    "Les paquets ICMP sont parfois bloqués par les routeurs")

  save_score "ex03" "$sc"
  log "EX03 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex04_nmap_basics() {
  load_scores
  intro_ex "04" "NMAP — Scan de base" "★★☆☆☆" \
    "Utiliser nmap pour scanner les ports ouverts d'une cible locale."
  echo -e "\n ${Y}[!] Scanne uniquement des machines que tu possèdes ou autorises.${N}\n"
  echo -e " ${D}Cible suggérée :${N} ${G}127.0.0.1 (localhost)${N}\n"

  check_tool "nmap" || return

  echo -e " ${Y}Commande :${N} ${G}nmap -sV 127.0.0.1${N}\n"
  echo -ne " ${D}Entrée pour lancer...${N}"; read -r

  proot-distro login ubuntu -- bash -c "nmap -sV 127.0.0.1 2>/dev/null"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Que fait l'option -sV dans nmap ?" \
    "détecte les versions|version detection|détection de version|service version" \
    "C'est le V de 'Version'")

  save_score "ex04" "$sc"
  log "EX04 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex05_headers_http() {
  load_scores
  intro_ex "05" "HTTP HEADERS — Fingerprinting serveur" "★★☆☆☆" \
    "Analyser les entêtes HTTP pour identifier la technologie d'un serveur."
  echo -e "\n ${D}Cible :${N} ${G}http://example.com${N}\n"

  check_tool "curl" || return

  echo -e " ${Y}Commande :${N} ${G}curl -I http://example.com${N}\n"
  echo -ne " ${D}Entrée pour lancer...${N}"; read -r

  proot-distro login ubuntu -- bash -c "curl -I http://example.com 2>/dev/null"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Quel header HTTP révèle souvent le serveur web utilisé ?" \
    "Server" \
    "C'est le nom anglais du mot 'serveur'")

  save_score "ex05" "$sc"
  log "EX05 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex06_robots_txt() {
  load_scores
  intro_ex "06" "ROBOTS.TXT — Reconnaissance web" "★★☆☆☆" \
    "Trouver des chemins cachés via le fichier robots.txt d'un site."
  echo -e "\n ${D}Cible :${N} ${G}http://example.com/robots.txt${N}\n"

  check_tool "curl" || return

  echo -e " ${Y}Commande :${N} ${G}curl http://example.com/robots.txt${N}\n"
  echo -ne " ${D}Entrée pour lancer...${N}"; read -r

  proot-distro login ubuntu -- bash -c "curl -s http://example.com/robots.txt 2>/dev/null || echo 'Fichier introuvable (404)'"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Quelle directive dans robots.txt interdit l'indexation d'un chemin ?" \
    "Disallow" \
    "Le contraire de 'Allow'")

  save_score "ex06" "$sc"
  log "EX06 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex07_geo_ip() {
  load_scores
  intro_ex "07" "GEO-IP — Localisation d'adresses" "★★★☆☆" \
    "Utiliser une API publique pour géolocaliser une adresse IP."
  echo -e "\n ${D}IP cible :${N} ${G}8.8.8.8${N}\n"

  check_tool "curl" || return

  echo -e " ${Y}Commande :${N} ${G}curl https://ipinfo.io/8.8.8.8${N}\n"
  echo -ne " ${D}Entrée pour lancer...${N}"; read -r

  proot-distro login ubuntu -- bash -c "curl -s https://ipinfo.io/8.8.8.8 2>/dev/null"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "À quel pays appartient l'IP 8.8.8.8 ?" \
    "US|États-Unis|United States|USA" \
    "C'est le pays du moteur de recherche Google")

  save_score "ex07" "$sc"
  log "EX07 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex08_metadata() {
  load_scores
  intro_ex "08" "MÉTADONNÉES — Extraction EXIF" "★★★☆☆" \
    "Extraire les métadonnées d'un fichier pour obtenir des infos cachées."
  echo -e "\n ${D}Outil :${N} ${G}exiftool${N}\n"

  check_tool "libimage-exiftool-perl" || return

  echo -e " ${Y}Crée un fichier test et extrait ses métadonnées :${N}"
  echo -e " ${G}touch /tmp/test.txt && exiftool /tmp/test.txt${N}\n"
  echo -ne " ${D}Entrée pour lancer...${N}"; read -r

  proot-distro login ubuntu -- bash -c \
    "apt install -y libimage-exiftool-perl -qq 2>/dev/null; touch /tmp/test.txt; exiftool /tmp/test.txt 2>/dev/null"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Quel type de fichier contient le plus souvent des métadonnées GPS révélatrices ?" \
    "JPEG|JPG|photo|image|jpg" \
    "C'est le format d'image le plus courant sur les smartphones")

  save_score "ex08" "$sc"
  log "EX08 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex09_gobuster() {
  load_scores
  intro_ex "09" "GOBUSTER — Énumération de répertoires" "★★★★☆" \
    "Utiliser gobuster pour découvrir des répertoires cachés sur un serveur web."
  echo -e "\n ${Y}[!] Utilise uniquement sur tes propres serveurs.${N}"
  echo -e " ${D}Mode théorique — analyse de la syntaxe.${N}\n"

  check_tool "gobuster" || return

  echo -e " ${Y}Syntaxe de base :${N}"
  echo -e " ${G}gobuster dir -u http://cible.com -w /usr/share/wordlists/dirb/common.txt${N}\n"
  echo -e " ${D}Options utiles :${N}"
  echo -e "  ${W}-t 50${N}  ${D}→ 50 threads${N}"
  echo -e "  ${W}-x php,html${N}  ${D}→ extensions à tester${N}"
  echo -e "  ${W}-o output.txt${N}  ${D}→ sauvegarder résultats${N}\n"

  echo -ne " ${D}Entrée pour continuer...${N}"; read -r

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Quel mode gobuster utilise-t-on pour énumérer les sous-domaines ?" \
    "dns" \
    "C'est le protocole de résolution de noms")

  save_score "ex09" "$sc"
  log "EX09 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex10_shodan_dorks() {
  load_scores
  intro_ex "10" "GOOGLE DORKS — Recherche avancée" "★★★★☆" \
    "Maîtriser les opérateurs de recherche Google pour trouver des infos sensibles."
  echo -e "\n ${D}Théorie et pratique des dorks OSINT.${N}\n"

  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} OPÉRATEURS GOOGLE DORKS${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -e " ${G}site:${N}${W}example.com${N}        ${D}→ résultats d'un seul site${N}"
  echo -e " ${G}inurl:${N}${W}admin${N}              ${D}→ URL contenant 'admin'${N}"
  echo -e " ${G}intitle:${N}${W}\"index of\"${N}       ${D}→ pages de listage de fichiers${N}"
  echo -e " ${G}filetype:${N}${W}pdf${N}              ${D}→ fichiers PDF uniquement${N}"
  echo -e " ${G}intext:${N}${W}\"mot de passe\"${N}    ${D}→ texte dans la page${N}"
  echo -e " ${G}cache:${N}${W}example.com${N}         ${D}→ version cache Google${N}"
  echo -e " ${G}link:${N}${W}example.com${N}          ${D}→ pages qui pointent vers le site${N}\n"

  echo -e " ${Y}Exemple :${N} ${G}site:github.com inurl:\"config\" filetype:env${N}"
  echo -e " ${D}(cherche des fichiers .env mal exposés sur GitHub)${N}\n"

  echo -ne " ${D}Entrée pour continuer...${N}"; read -r

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Quel opérateur Google restreint les résultats à un seul site web ?" \
    "site:" \
    "C'est le nom anglais du mot 'site' suivi de deux-points")

  save_score "ex10" "$sc"
  log "EX10 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex11_subdomain() {
  load_scores
  intro_ex "11" "SOUS-DOMAINES — Énumération DNS" "★★★★☆" \
    "Trouver les sous-domaines d'un domaine cible avec des outils OSINT."
  echo -e "\n ${D}Cible :${N} ${G}example.com${N}\n"

  check_tool "dnsutils" || return

  echo -e " ${Y}Méthode 1 — Brute force DNS :${N}"
  echo -e " ${G}for sub in www mail ftp admin api dev; do host \$sub.example.com; done${N}\n"
  echo -ne " ${D}Entrée pour lancer...${N}"; read -r

  proot-distro login ubuntu -- bash -c \
    "for sub in www mail ftp admin api dev vpn smtp pop3; do
       result=\$(host \$sub.example.com 2>/dev/null | grep 'has address')
       if [[ -n \"\$result\" ]]; then echo \"[✓] \$sub.example.com → \$result\"
       else echo \"[✗] \$sub.example.com — non résolu\"; fi
     done"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc
  sc=$(ask_question \
    "Quel enregistrement DNS pointe un sous-domaine vers un autre nom de domaine ?" \
    "CNAME" \
    "C'est le 'Canonical NAME'")

  save_score "ex11" "$sc"
  log "EX11 score=$sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

ex12_ctf() {
  load_scores
  intro_ex "12" "CTF — Challenge final OSINT" "★★★★★" \
    "Résoudre un mini-CTF OSINT en trouvant des informations cachées."
  echo -e "\n ${Y}[!] Challenge avancé — tous les exercices précédents recommandés.${N}\n"

  echo -e "${R} ──────────────────────────────────${N}"
  echo -e "${W} SCÉNARIO${N}"
  echo -e "${R} ──────────────────────────────────${N}\n"
  echo -e " ${D}Tu es chargé d'auditer la présence en ligne d'une organisation.${N}"
  echo -e " ${D}Domaine cible :${N} ${G}iana.org${N}\n"
  echo -e " ${D}Outils autorisés : whois, nslookup, curl, nmap (localhost uniquement)${N}\n"
  echo -e "${R} ──────────────────────────────────${N}"

  echo -e "\n ${W}Étape 1 — WHOIS${N}"
  echo -ne " ${D}Lance whois iana.org et trouve l'organisation. Entrée...${N}"; read -r
  proot-distro login ubuntu -- bash -c "whois iana.org 2>/dev/null | grep -i 'org\|registrar\|name' | head -10"

  echo -e "\n ${W}Étape 2 — DNS${N}"
  echo -ne " ${D}Entrée pour résoudre les enregistrements MX...${N}"; read -r
  proot-distro login ubuntu -- bash -c "nslookup -type=MX iana.org 2>/dev/null"

  echo -e "\n ${W}Étape 3 — Headers HTTP${N}"
  echo -ne " ${D}Entrée pour analyser les headers...${N}"; read -r
  proot-distro login ubuntu -- bash -c "curl -sI https://www.iana.org 2>/dev/null | head -15"

  echo -e "\n${R} ──────────────────────────────────${N}"
  local sc total_sc=0
  sc=$(ask_question \
    "Quel protocole sécurise le site iana.org (visible dans le header) ?" \
    "HTTPS|TLS|SSL|https" \
    "Regarde le header 'Strict-Transport-Security'")
  total_sc=$((total_sc+sc))

  sc=$(ask_question \
    "Quel type d'enregistrement DNS gère la réception des emails ?" \
    "MX" \
    "MX = Mail eXchanger")
  total_sc=$((total_sc+sc))

  [[ $total_sc -gt 5 ]] && total_sc=5
  save_score "ex12" "$total_sc"
  log "EX12 score=$total_sc"
  echo -ne "\n ${D}Entrée...${N}"; read -r
}

# ─── MENU PRINCIPAL ─────────────────────────────────
main_menu() {
  while true; do
    load_scores
    local done_count=0
    for ex in ex01 ex02 ex03 ex04 ex05 ex06 ex07 ex08 ex09 ex10 ex11 ex12; do
      [[ "${SCORES[$ex]:-0}" -gt 0 ]] && done_count=$((done_count+1))
    done

    clear
    show_ascii
    echo -e "${R} ──────────────────────────────────${N}"
    echo -e "${W} EXERCICES OSINT${N}  ${D}(${done_count}/12 complétés)${N}"
    echo -e "${R} ──────────────────────────────────${N}\n"

    local exercises=(
      "01|WHOIS — Infos domaine|★☆☆☆☆|ex01"
      "02|DNS — Résolution d'adresses|★☆☆☆☆|ex02"
      "03|TRACEROUTE — Cartographie réseau|★★☆☆☆|ex03"
      "04|NMAP — Scan de base|★★☆☆☆|ex04"
      "05|HTTP HEADERS — Fingerprinting|★★☆☆☆|ex05"
      "06|ROBOTS.TXT — Recon web|★★☆☆☆|ex06"
      "07|GEO-IP — Localisation IP|★★★☆☆|ex07"
      "08|MÉTADONNÉES — Exif|★★★☆☆|ex08"
      "09|GOBUSTER — Énumération|★★★★☆|ex09"
      "10|GOOGLE DORKS — Recon avancée|★★★★☆|ex10"
      "11|SOUS-DOMAINES — DNS enum|★★★★☆|ex11"
      "12|CTF — Challenge final|★★★★★|ex12"
    )

    local idx=1
    for entry in "${exercises[@]}"; do
      IFS='|' read -r num titre diff key <<< "$entry"
      local sc="${SCORES[$key]:-0}"
      local done_mark="${D}○${N}"
      [[ $sc -gt 0 ]] && done_mark="${G}●${N}"
      echo -e " ${R}[${W}${idx}${R}]${N} ${done_mark} ${W}${titre}${N} ${D}${diff}${N} ${D}[${sc}/5]${N}"
      idx=$((idx+1))
    done

    echo -e "\n ${R}[${W}s${R}]${N} ${W}Scores & progression${N}"
    echo -e " ${R}[${W}r${R}]${N} ${W}Réinitialiser scores${N}"
    echo -e "\n ${R}[${W}0${R}]${N} ${W}Quitter${N}"
    echo -e "\n${R} ──────────────────────────────────${N}"
    echo -ne "\n ${R}» ${W}"
    read -r OPT
    echo -ne "${N}"

    case "$OPT" in
      1)  ex01_whois ;;
      2)  ex02_nslookup ;;
      3)  ex03_traceroute ;;
      4)  ex04_nmap_basics ;;
      5)  ex05_headers_http ;;
      6)  ex06_robots_txt ;;
      7)  ex07_geo_ip ;;
      8)  ex08_metadata ;;
      9)  ex09_gobuster ;;
      10) ex10_shodan_dorks ;;
      11) ex11_subdomain ;;
      12) ex12_ctf ;;
      s|S) show_scores ;;
      r|R)
        echo -ne "\n ${R}[?]${N} ${W}Réinitialiser tous les scores ? [o/N] : ${N}"
        read -r CONFIRM
        if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
          rm -f "$SCORE_FILE"
          echo -e " ${G}✓${N} ${W}Scores réinitialisés.${N}"
          sleep 1
        fi
        ;;
      0) clear; exit 0 ;;
      *) sleep 0.5 ;;
    esac
  done
}

clear
show_ascii
log "===== exercice.sh lancé ====="
main_menu
