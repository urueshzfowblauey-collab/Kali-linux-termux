#!/bin/bash

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

TOOL_ORDER=("nmap" "sqlmap" "hydra" "nikto" "john" "aircrack-ng" "hashcat" "metasploit-framework" "beef-xss" "gobuster" "dirb" "wfuzz" "netcat-openbsd" "curl" "wget")
