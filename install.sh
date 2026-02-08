#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  🐧 LINUX INSTALLATION LAB - Ultimate Installer v3.3
#  
#  Features:
#  - NEW: Smart Retry (Auto-fixes internet fails)
#  - FIXED: Wine & Hydra installation loop
#  - Personalized for: Yash
#  
#  Author: Yash
#  YouTube: https://youtube.com/@Yash
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=14
CURRENT_STEP=0

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============== PROGRESS FUNCTIONS ==============
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    if [ $PERCENT -gt 100 ]; then PERCENT=100; fi
    FILLED=$((PERCENT / 5))
    EMPTY=$((20 - FILLED))
    BAR="${GREEN}"
    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    BAR+="${GRAY}"
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
    BAR+="${NC}"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC}  "
        sleep 0.1
    done
    wait $pid
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} ${message}                    \n"
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(retrying...)${NC}     \n"
    fi
    return $exit_code
}

# Smart Install Function (Retries 3 times if fails)
install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    local attempt=1
    local max_attempts=3
    
    while [ $attempt -le $max_attempts ]; do
        (yes | pkg install $pkg -y > /dev/null 2>&1) &
        spinner $! "Installing ${name} (Attempt $attempt/$max_attempts)..."
        
        # Check if installed
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            return 0
        else
            if [ $attempt -lt $max_attempts ]; then
                echo -e "  ${YELLOW}⚠${NC} Connection failed, waiting 3s..."
                sleep 3
                # Refresh connection
                pkg update -y >/dev/null 2>&1
            fi
            attempt=$((attempt + 1))
        fi
    done
    echo -e "  ${RED}✗${NC} Failed to install ${name}."
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════╗
    ║                                      ║
    ║   🐧  LINUX INSTALLATION LAB v3.3    ║
    ║        (Smart Retry Edition)         ║
    ║         Created By: Yash             ║
    ║                                      ║
    ╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${WHITE}         Welcome Yash!${NC}"
    echo ""
}

# ============== MAIN STEPS ==============

step_repair() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Attempting Auto-Repair...${NC}"
    echo -e "  ${YELLOW}ℹ${NC} Fixing broken packages/SSL issues..."
    
    dpkg --configure -a > /dev/null 2>&1
    (pkg update -y -o Dpkg::Options::="--force-confnew" && pkg upgrade -y -o Dpkg::Options::="--force-confnew") > /dev/null 2>&1 &
    spinner $! "System Repair & Update..."
}

step_base() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Essentials...${NC}"
    install_pkg "git" "Git"
    install_pkg "wget" "Wget"
    install_pkg "python" "Python"
    install_pkg "curl" "Curl"
}

step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Fixing Repositories...${NC}"
    install_pkg "root-repo" "Root Repo"
    install_pkg "x11-repo" "X11 Repo"
    install_pkg "tur-repo" "TUR Repo"
    
    (pkg update -y) > /dev/null 2>&1 &
    spinner $! "Refreshing Repo List..."
}

step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11...${NC}"
    install_pkg "termux-x11-nightly" "Termux-X11 Server"
    install_pkg "xorg-xrandr" "Display Settings"
}

step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing XFCE4 Desktop...${NC}"
    install_pkg "xfce4" "XFCE4 Desktop"
    install_pkg "xfce4-terminal" "Terminal"
    install_pkg "thunar" "File Manager"
}

step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU Drivers...${NC}"
    install_pkg "mesa-zink" "Mesa Zink"
    install_pkg "mesa-vulkan-icd-freedreno" "Adreno Drivers"
    install_pkg "vulkan-loader-android" "Vulkan Loader"
}

step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Audio...${NC}"
    install_pkg "pulseaudio" "PulseAudio"
}

step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Firefox & Code...${NC}"
    install_pkg "firefox" "Firefox"
    # VS Code check
    if ! pkg install code-oss -y > /dev/null 2>&1; then
         echo -e "  ${YELLOW}⚠${NC} VS Code failed (Architecture mismatch?)"
    else
         echo -e "  ${GREEN}✓${NC} VS Code installed"
    fi
}

step_network_tools() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Network Tools...${NC}"
    install_pkg "nmap" "Nmap"
    install_pkg "netcat-openbsd" "Netcat"
}

# ============== FIXED YASH TOOLS ==============
step_security_tools() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Yash Tools...${NC}"
    echo ""
    
    # Create a dedicated folder "Yash"
    mkdir -p ~/Yash
    echo -e "  ${CYAN}📂${NC} Created 'Yash' folder..."

    # 1. SQLMap (Using Git Clone -> ~/Yash/sqlmap)
    echo -e "  ${YELLOW}⏳${NC} Downloading SQLMap (Git)..."
    rm -rf ~/Yash/sqlmap > /dev/null 2>&1
    git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git ~/Yash/sqlmap > /dev/null 2>&1
    echo -e "  ${GREEN}✓${NC} SQLMap installed in ~/Yash/sqlmap"
    
    # 2. Python Dependencies
    echo -e "  ${YELLOW}⏳${NC} Installing Python Libraries..."
    pip install requests > /dev/null 2>&1
    echo -e "  ${GREEN}✓${NC} Python Libs Ready"
}

step_hydra_fix() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Hydra...${NC}"
    # Force update before installing Hydra
    (pkg update -y) > /dev/null 2>&1
    install_pkg "hydra" "Hydra"
}

# ============== FIXED METASPLOIT ==============
step_metasploit() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Setting up Metasploit...${NC}"
    echo -e "  ${YELLOW}⚠${NC} Note: Metasploit is large, downloading installer script..."
    
    # Download the automated installer script
    cd ~
    rm -f metasploit.sh
    wget https://raw.githubusercontent.com/gushmazuko/metasploit_in_termux/master/metasploit.sh > /dev/null 2>&1
    chmod +x metasploit.sh
    
    echo -e "  ${GREEN}✓${NC} Installer downloaded as 'metasploit.sh'"
    echo -e "  ${WHITE}ℹ To install Metasploit later, type: ./metasploit.sh${NC}"
}

step_wine() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Wine...${NC}"
    # Force update before installing Wine
    (pkg update -y) > /dev/null 2>&1
    install_pkg "wine" "Wine (Standard)"
}

step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Configs...${NC}"
    
    mkdir -p ~/.config
    # GPU Config
    cat > ~/.config/linuxlab-gpu.sh << 'GPUEOF'
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
GPUEOF
    
    # Start Script
    cat > ~/start-linux.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
source ~/.config/linuxlab-gpu.sh 2>/dev/null
pkill -9 -f "termux.x11" 2>/dev/null
pulseaudio --start --exit-idle-time=-1 2>/dev/null &
termux-x11 :0 -ac &
sleep 2
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
echo "🚀 Starting Yash's Linux Lab..."
exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-linux.sh
    
    # Tool Menu (Updated with new paths)
    cat > ~/linux-tools.sh << 'TOOLSEOF'
#!/data/data/com.termux/files/usr/bin/bash
while true; do
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║   🔧 Yash Linux Tools (Fixed)        ║"
    echo "╠══════════════════════════════════════╣"
    echo "║  1) 💉 SQLMap (Run Python)           ║"
    echo "║  2) 🌐 Nmap Scan                     ║"
    echo "║  3) 💀 Install Metasploit (Script)   ║"
    echo "║  4) 🖥️  Start Desktop                ║"
    echo "║  0) ❌ Exit                          ║"
    echo "╚══════════════════════════════════════╝"
    read -p " Select: " choice
    case $choice in
        1) cd ~/Yash/sqlmap && python sqlmap.py --wizard ;;
        2) read -p "IP: " ip; nmap $ip; read -p "Done..." ;;
        3) bash ~/metasploit.sh ;;
        4) bash ~/start-linux.sh ;;
        0) exit 0 ;;
    esac
done
TOOLSEOF
    chmod +x ~/linux-tools.sh
}

step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Shortcuts...${NC}"
    mkdir -p ~/Desktop
    
    # Firefox
    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Exec=firefox
Icon=firefox
Type=Application
EOF

    # Tools Menu
    cat > ~/Desktop/YashTools.desktop << 'EOF'
[Desktop Entry]
Name=Yash Tools
Exec=xfce4-terminal -e "bash ~/linux-tools.sh"
Icon=utilities-terminal
Type=Application
EOF
}

show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
    ╔══════════════════════════════════════════╗
    ║      ✅  INSTALLATION COMPLETE!  ✅      ║
    ║      🐧 Linux Lab by Yash Ready 🐧       ║
    ╚══════════════════════════════════════════╝
COMPLETE
    echo -e "${WHITE}🚀 START DESKTOP:  ${GREEN}bash ~/start-linux.sh${NC}"
    echo -e "${WHITE}🔧 TOOLS MENU:     ${GREEN}bash ~/linux-tools.sh${NC}"
    echo -e "${WHITE}📂 NEW FOLDER:     ${GREEN}~/Yash${NC} (Check here for SQLMap)"
    echo ""
}

# ============== RUN ==============
main() {
    show_banner
    echo -e "${YELLOW}Press Enter to start installation...${NC}"
    read
    
    echo -e "${PURPLE}[*] Checking System...${NC}"
    
    step_repair
    step_base
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_apps
    step_network_tools
    step_security_tools
    step_hydra_fix
    step_metasploit
    step_wine
    step_launchers
    step_shortcuts
    
    show_completion
}

main
