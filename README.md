# ansible_workstation

Ansible playbooks to provision a consistent workstation configuration for personal use. Currently this assumes a Ubuntu system, as this is mostly for personal use.

Since I have not found that many good resources regarding the Ansible pull workflow, I have created this repository to share my learning experience and help others.

## Bootstrap

Run the following command to bootstrap the workstation:

```bash
sudo ansible-pull -U https://github.com/TimFehler/ansible_workstation.git -d $HOME/.ansible_pull -i localhost, -e ansible_hostname=$(hostname) pull.yml
```

## Anacron job for consistent provisioning

Ensuring a consistent workstations configuration can be a tedious task if done manually. Using an Anacron job can help automate this process.

`/etc/cron.daily/ansible_pull`:
```bash
#!/bin/bash
# ansible_pull.sh - Run ansible-pull command daily

# Define the environment variable for the ansible directory
ANSIBLE_DIR="/opt/ansible_pull"
LOG_FILE="/var/log/ansible_pull.log"

# Ensure the ansible directory exists
mkdir -p "$ANSIBLE_DIR"

# Ensure the log file is writable
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Run the ansible-pull command and log output
{
    echo "Starting ansible-pull at $(date)"
    ansible-pull -U https://github.com/TimFehler/ansible_workstation.git \
        -d "$ANSIBLE_DIR" \
        -i localhost, \
        -e ansible_hostname=$(hostname) pull.yml
    echo "Completed ansible-pull at $(date)"
} >> "$LOG_FILE" 2>&1
```

To remove any existing files and directories of this anacron job, run the following commands:

```bash
sudo rm -rf /etc/cron.daily/ansible_pull
sudo rm -rf /opt/ansible_pull
```

## Dependencies

You need to have Python3 and Ansible installed on your system. You can install them using the following commands:

```bash
sudo apt-get install python3 ansible
```

## Author

Tim Fehler
