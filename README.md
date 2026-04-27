# Proxmox MCP Server

Gives Claude tools to manage a Proxmox VE server — start/stop VMs, check status, manage drives, control Samba shares.

Works with **Claude Code** (primary) and **Claude Desktop** (secondary).

---

## What You Can Ask Claude Once Set Up

- "Show me all my VMs and their status"
- "Start the plex VM"
- "Add /dev/sdd as cage drive C2_D1_TV"
- "Show disk usage on all drives"
- "Restart Samba"
- "What's the CPU and RAM usage on the Proxmox host?"

---

## Prerequisites

- Proxmox VE server running and accessible on your network
- Python 3.10 or later installed on the machine running Claude
- SSH access to your Proxmox server

---

## Step 1 — Get the Files

Clone this repo, or download just the `ProxmoxMCP` folder. The files you need:

```
ProxmoxMCP/
├── server.py
├── config.example.json
├── requirements.txt
└── README.md
```

---

## Step 2 — Install Python Dependencies

Open a terminal (Command Prompt, PowerShell, or bash) in the `ProxmoxMCP` folder.

Create a virtual environment (keeps dependencies isolated):

**Windows:**
```
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

**Linux / Mac:**
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

You should see packages installing. When done, your prompt will show `(.venv)` at the start.

---

## Step 3 — Create a Proxmox API Token

The MCP uses a Proxmox API token for VM operations. You create this in the Proxmox web UI.

1. Open your Proxmox web UI in a browser (e.g. `https://192.168.1.50:8006`)
2. Log in as root
3. In the left panel, click **Datacenter**
4. In the menu that appears, click **Permissions**, then **API Tokens**
5. Click the **Add** button
6. Fill in:
   - **User:** `root@pam`
   - **Token ID:** `mcp`
   - **Privilege Separation:** **uncheck this box** (important — leave it unchecked so the token has full access)
7. Click **Add**
8. A dialog appears showing the token value — **copy it now, it will not be shown again**
   - It looks like: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

---

## Step 4 — Set Up SSH Key Access (Recommended)

The MCP uses SSH for drive and system operations. SSH keys are more secure and don't require a password in the config file.

**On the machine running Claude** (Windows/Mac/Linux), open a terminal:

**Check if you already have a key:**
```bash
# Windows PowerShell:
ls ~/.ssh/id_ed25519.pub

# Linux/Mac:
ls ~/.ssh/id_ed25519.pub
```

**If the file doesn't exist, generate one:**
```bash
ssh-keygen -t ed25519 -C "your-machine-name"
# Press Enter to accept defaults (no passphrase needed for home lab)
```

**Display your public key:**
```bash
# Windows PowerShell:
cat ~/.ssh/id_ed25519.pub

# Linux/Mac:
cat ~/.ssh/id_ed25519.pub
```

Copy the entire output — it starts with `ssh-ed25519`.

**Add it to your Proxmox server** — in a terminal connected to Proxmox (PuTTY/SSH):
```bash
mkdir -p ~/.ssh
echo "paste-your-public-key-here" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

**Test the connection** from your local machine:
```bash
ssh root@192.168.1.50
```

If it connects without asking for a password, SSH keys are working.

> **Alternative — Password Auth:** If you prefer not to use SSH keys, skip this step and use `ssh_password` in config.json instead (see Step 5 note).

---

## Step 5 — Create Your Config File

In the `ProxmoxMCP` folder, copy the example config:

**Windows:**
```
copy config.example.json config.json
```

**Linux/Mac:**
```bash
cp config.example.json config.json
```

Open `config.json` in any text editor and fill in your values:

```json
{
    "proxmox_host": "192.168.1.50",       ← your Proxmox IP address
    "proxmox_port": 8006,                  ← leave as 8006 unless you changed it
    "proxmox_user": "root@pam",            ← leave as-is
    "proxmox_token_name": "mcp",           ← leave as-is
    "proxmox_token_value": "paste-token",  ← paste the token value from Step 3
    "verify_ssl": false,                   ← leave as false (self-signed cert)
    "node_name": "pve",                    ← your node name (check top-left in Proxmox UI)

    "ssh_host": "192.168.1.50",            ← same as proxmox_host usually
    "ssh_port": 22,                        ← leave as 22
    "ssh_user": "root",                    ← leave as root
    "ssh_key_path": "~/.ssh/id_ed25519"   ← path to your SSH private key
}
```

> **Password auth instead of SSH key:** Remove `ssh_key_path` and add `"ssh_password": "yourpassword"` instead. Not recommended — your password would be in a plain text file.

> **config.json is gitignored** — it will never be committed to the repo. Keep your token value and password out of config.example.json.

---

## Step 6 — Find Your Python Path

You need the full path to the Python executable in your virtual environment for the Claude config.

**Windows** (run in the ProxmoxMCP folder):
```
.venv\Scripts\python.exe --version
```
Your path is: `C:\path\to\ProxmoxMCP\.venv\Scripts\python.exe`

**Linux/Mac:**
```bash
.venv/bin/python3 --version
```
Your path is: `/path/to/ProxmoxMCP/.venv/bin/python3`

---

## Step 7 — Register with Claude Code

Claude Code registers MCP servers via the `claude mcp add` command. Open a terminal and run:

**Windows:**
```
claude mcp add proxmox "C:\Users\YourName\path\to\ProxmoxMCP\.venv\Scripts\python.exe" "C:\Users\YourName\path\to\ProxmoxMCP\server.py"
```

**Linux/Mac:**
```bash
claude mcp add proxmox /home/yourname/path/to/ProxmoxMCP/.venv/bin/python3 /home/yourname/path/to/ProxmoxMCP/server.py
```

You should see: `Added stdio MCP server proxmox...`

Restart Claude Code after running the command.

---

## Step 8 — Register with Claude Desktop (Optional)

Claude Desktop config file location:

**Windows:** `C:\Users\YourName\AppData\Roaming\Claude\claude_desktop_config.json`
**Mac:** `~/Library/Application Support/Claude/claude_desktop_config.json`

Add the same `mcpServers` entry as Step 7. Restart Claude Desktop after saving.

---

## Step 9 — Test It

In Claude Code or Claude Desktop, try:

```
Use the proxmox MCP to list my VMs
```

or just:

```
list_vms
```

You should see a table of your VMs. If you get an error, see Troubleshooting below.

---

## Available Tools

| Tool | What it does |
|---|---|
| `list_vms` | All VMs with status, RAM, uptime |
| `vm_status` | Detailed status of one VM |
| `start_vm` | Start a VM by name or ID |
| `stop_vm` | Graceful shutdown of a VM |
| `restart_vm` | Reboot a VM |
| `node_status` | Host CPU, RAM, uptime, storage pools |
| `drive_status` | All drives, mounts, disk usage, fstab |
| `add_drive` | Partition, format, mount, and fstab a new drive |
| `remove_drive` | Unmount, remove from fstab, safe to physically remove |
| `relabel_drive` | Rename a drive label and mount point |
| `samba_status` | Samba service, shares, and users |
| `restart_samba` | Restart Samba file sharing |
| `run_command` | Run any shell command via SSH |

---

## Troubleshooting

**"config.json not found"**
You forgot to copy config.example.json to config.json. See Step 5.

**"Connection refused" or "Authentication failed" (Proxmox API)**
- Check `proxmox_host` and `proxmox_port` are correct
- Check `proxmox_token_name` and `proxmox_token_value` match what's in Proxmox UI
- Make sure "Privilege Separation" was unchecked when creating the token

**"Authentication failed" (SSH)**
- If using SSH key: verify the public key was added to `~/.ssh/authorized_keys` on Proxmox
- If using password: check `ssh_password` in config.json
- Test manually first: `ssh root@your-proxmox-ip`

**"No module named 'mcp'" or similar**
Your virtual environment isn't activated when Claude runs the server. Make sure the `command` in your Claude config points to the `.venv` Python executable (Step 6), not the system Python.

**VM name not found**
VM names are case-insensitive but must match exactly. Use `list_vms` to see exact names.

---

## Drive Naming Convention

Cage drives follow this naming pattern: `C#_D#_Type`

- `C1` = Cage 1, `C2` = Cage 2, etc.
- `D1` = Drive slot 1, `D2` = Drive slot 2, etc.
- `Type` = content type added when known (TV, Movie, etc.)

Examples: `C1_D1_TV`, `C2_D3_Movie`, `C1_D2` (type TBD)

Use underscores — no spaces. Spaces cause problems in Linux paths.
