#!/bin/bash
set -euo pipefail

# --- Configuration ---
ANSIBLE_USER="ansible"
ANSIBLE_REPO="git@github.com:tfehler/ansible-pull.git"   # SSH URL
ANSIBLE_REPO_URL="git@github.com" # Base URL for SSH access
ANSIBLE_BRANCH="main"
LOG_DIR="/var/log/ansible-pull"
PULL_INTERVAL="30min"   # systemd time format (can be '1h', '10min', etc.)

# --- Ensure dependencies ---
apt-get update
apt-get install -y ansible git sudo openssh-client

# --- Create ansible user ---
if ! id "$ANSIBLE_USER" >/dev/null 2>&1; then
    useradd --system --create-home --shell /bin/bash "$ANSIBLE_USER"
    echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/$ANSIBLE_USER
fi

# --- Prepare log directory ---
mkdir -p "$LOG_DIR"
chown $ANSIBLE_USER:$ANSIBLE_USER "$LOG_DIR"

# --- Generate SSH key if not exists ---
sudo -u $ANSIBLE_USER bash <<'EOF'
if [ ! -f ~/.ssh/id_ed25519 ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
    echo -e "\n New SSH key generated for ansible user:"
    cat ~/.ssh/id_ed25519.pub
    echo -e "\n Add this public key to your Git server before the first pull."
fi
EOF

# --- Create systemd service for ansible-pull ---
SERVICE_FILE="/etc/systemd/system/ansible-pull.service"
cat >"$SERVICE_FILE" <<EOF
[Unit]
Description=Ansible Pull configuration management
Wants=network-online.target
After=network-online.target

[Service]
User=$ANSIBLE_USER
WorkingDirectory=/home/$ANSIBLE_USER
ExecStart=/usr/bin/ansible-pull \\
  --url $ANSIBLE_REPO \\
  --checkout $ANSIBLE_BRANCH \\
  --directory /home/$ANSIBLE_USER/ansible \\
  --logfile $LOG_DIR/ansible-pull.log \\
  -i localhost,
ExecStartPost=/usr/bin/bash -c 'echo "Run completed at \$(date)" >> $LOG_DIR/ansible-pull.log'
Environment=ANSIBLE_NOCOWS=1
Restart=on-failure
EOF

# --- Create systemd timer ---
TIMER_FILE="/etc/systemd/system/ansible-pull.timer"
cat >"$TIMER_FILE" <<EOF
[Unit]
Description=Run ansible-pull every $PULL_INTERVAL

[Timer]
OnBootSec=5min
OnUnitActiveSec=$PULL_INTERVAL
AccuracySec=1min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# --- Reload and enable systemd units ---
systemctl daemon-reload
systemctl enable --now ansible-pull.timer

echo "Ansible-pull bootstrap complete."
echo "-> Check logs in $LOG_DIR/ansible-pull.log"
echo "-> Run 'sudo -u $ANSIBLE_USER ssh -T $ANSIBLE_REPO_URL' once to accept the host key."