#!/bin/bash

GITHUB_KALI="https://github.com/kyaev/kali-termux"
GITHUB_TOOLS="https://github.com/kyaev/kali-tools"

KALI_DIR="$HOME/kali-fs"

declare -A TOOLS
TOOLS["nmap"]="https://github.com/nmap/nmap"
TOOLS["mr-ripper"]=""
TOOLS["sqlmap"]="https://github.com/sqlmapproject/sqlmap"
TOOLS["hydra"]="https://github.com/vanhauser-thc/thc-hydra"
TOOLS["metasploit"]=""
TOOLS["nikto"]="https://github.com/sullo/nikto"
TOOLS["aircrack-ng"]="https://github.com/aircrack-ng/aircrack-ng"
TOOLS["john"]="https://github.com/openwall/john"
TOOLS["hashcat"]="https://github.com/hashcat/hashcat"
TOOLS["beef"]="https://github.com/beefproject/beef"
