#!/usr/bin/env python3
"""
Proxmox MCP Server
Gives Claude tools to manage a Proxmox VE server.
VM operations use the Proxmox API. Drive/system operations use SSH.
"""

import json
import os
import sys
from pathlib import Path
from typing import Optional

import paramiko
from mcp.server.fastmcp import FastMCP
from proxmoxer import ProxmoxAPI

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

CONFIG_FILE = Path(__file__).parent / "config.json"

def load_config() -> dict:
    if not CONFIG_FILE.exists():
        print(f"ERROR: config.json not found at {CONFIG_FILE}", file=sys.stderr)
        print("Copy config.example.json to config.json and fill in your settings.", file=sys.stderr)
        sys.exit(1)
    with open(CONFIG_FILE) as f:
        return json.load(f)

config = load_config()

# ---------------------------------------------------------------------------
# MCP Server
# ---------------------------------------------------------------------------

mcp = FastMCP("Proxmox")

# ---------------------------------------------------------------------------
# Connection helpers
# ---------------------------------------------------------------------------

def get_proxmox() -> ProxmoxAPI:
    return ProxmoxAPI(
        config["proxmox_host"],
        port=config.get("proxmox_port", 8006),
        user=config["proxmox_user"],
        token_name=config["proxmox_token_name"],
        token_value=config["proxmox_token_value"],
        verify_ssl=config.get("verify_ssl", False),
    )


def get_ssh() -> paramiko.SSHClient:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    kwargs = dict(
        hostname=config.get("ssh_host", config["proxmox_host"]),
        port=config.get("ssh_port", 22),
        username=config.get("ssh_user", "root"),
    )
    key_path = config.get("ssh_key_path")
    if key_path:
        kwargs["key_filename"] = os.path.expanduser(key_path)
    else:
        kwargs["password"] = config.get("ssh_password", "")
    client.connect(**kwargs)
    return client


def ssh_run(command: str) -> str:
    """Run a shell command or multi-line script on the Proxmox host via SSH."""
    client = get_ssh()
    try:
        stdin, stdout, stderr = client.exec_command("bash")
        stdin.write(command)
        stdin.close()
        out = stdout.read().decode().strip()
        err = stderr.read().decode().strip()
        exit_code = stdout.channel.recv_exit_status()
        if exit_code != 0:
            return f"Command failed (exit {exit_code}):\n{err}\n{out}".strip()
        return out if out else err
    finally:
        client.close()


def find_vm(px: ProxmoxAPI, name_or_id: str) -> Optional[dict]:
    """Find a VM by name or numeric ID. Case-insensitive name match."""
    node = config.get("node_name", "pve")
    vms = px.nodes(node).qemu.get()
    for vm in vms:
        if str(vm["vmid"]) == name_or_id or vm.get("name", "").lower() == name_or_id.lower():
            return vm
    return None


# ---------------------------------------------------------------------------
# VM Tools
# ---------------------------------------------------------------------------

@mcp.tool()
def list_vms() -> str:
    """List all virtual machines on the Proxmox server with their current status."""
    try:
        px = get_proxmox()
        node = config.get("node_name", "pve")
        vms = px.nodes(node).qemu.get()
        if not vms:
            return "No VMs found."
        lines = [f"{'ID':<6} {'Name':<20} {'Status':<10} {'RAM (MB)':<10} {'Uptime'}"]
        lines.append("-" * 60)
        for vm in sorted(vms, key=lambda v: v["vmid"]):
            uptime = ""
            if vm.get("uptime"):
                h, rem = divmod(vm["uptime"], 3600)
                m = rem // 60
                uptime = f"{h}h {m}m"
            mem_mb = round(vm.get("maxmem", 0) / 1024 / 1024)
            lines.append(
                f"{vm['vmid']:<6} {vm.get('name', 'unknown'):<20} "
                f"{vm['status']:<10} {mem_mb:<10} {uptime}"
            )
        return "\n".join(lines)
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def vm_status(name_or_id: str) -> str:
    """Get detailed status of a specific VM. Pass the VM name or its numeric ID."""
    try:
        px = get_proxmox()
        node = config.get("node_name", "pve")
        vm = find_vm(px, name_or_id)
        if not vm:
            return f"VM '{name_or_id}' not found. Use list_vms() to see available VMs."
        detail = px.nodes(node).qemu(vm["vmid"]).status.current.get()
        mem_mb = round(detail.get("maxmem", 0) / 1024 / 1024)
        mem_used = round(detail.get("mem", 0) / 1024 / 1024)
        cpu_pct = round(detail.get("cpu", 0) * 100, 1)
        disk_gb = round(detail.get("maxdisk", 0) / 1024 / 1024 / 1024, 1)
        uptime = ""
        if detail.get("uptime"):
            h, rem = divmod(detail["uptime"], 3600)
            m = rem // 60
            uptime = f"{h}h {m}m"
        return (
            f"VM: {vm.get('name')} (ID: {vm['vmid']})\n"
            f"Status:  {detail['status']}\n"
            f"CPU:     {cpu_pct}%\n"
            f"RAM:     {mem_used} / {mem_mb} MB\n"
            f"Disk:    {disk_gb} GB\n"
            f"Uptime:  {uptime or 'not running'}"
        )
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def start_vm(name_or_id: str) -> str:
    """Start a virtual machine. Pass the VM name or its numeric ID."""
    try:
        px = get_proxmox()
        node = config.get("node_name", "pve")
        vm = find_vm(px, name_or_id)
        if not vm:
            return f"VM '{name_or_id}' not found."
        if vm["status"] == "running":
            return f"{vm.get('name')} is already running."
        px.nodes(node).qemu(vm["vmid"]).status.start.post()
        return f"Started {vm.get('name')} (ID: {vm['vmid']})."
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def stop_vm(name_or_id: str) -> str:
    """Gracefully shut down a virtual machine. Pass the VM name or its numeric ID."""
    try:
        px = get_proxmox()
        node = config.get("node_name", "pve")
        vm = find_vm(px, name_or_id)
        if not vm:
            return f"VM '{name_or_id}' not found."
        if vm["status"] == "stopped":
            return f"{vm.get('name')} is already stopped."
        px.nodes(node).qemu(vm["vmid"]).status.shutdown.post()
        return f"Shutdown initiated for {vm.get('name')} (ID: {vm['vmid']})."
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def restart_vm(name_or_id: str) -> str:
    """Restart a virtual machine. Pass the VM name or its numeric ID."""
    try:
        px = get_proxmox()
        node = config.get("node_name", "pve")
        vm = find_vm(px, name_or_id)
        if not vm:
            return f"VM '{name_or_id}' not found."
        px.nodes(node).qemu(vm["vmid"]).status.reboot.post()
        return f"Reboot initiated for {vm.get('name')} (ID: {vm['vmid']})."
    except Exception as e:
        return f"Error: {e}"


# ---------------------------------------------------------------------------
# System / Node Tools
# ---------------------------------------------------------------------------

@mcp.tool()
def node_status() -> str:
    """Get Proxmox host status: CPU usage, RAM, uptime, and storage pool summary."""
    try:
        px = get_proxmox()
        node = config.get("node_name", "pve")
        status = px.nodes(node).status.get()
        cpu_pct = round(status.get("cpu", 0) * 100, 1)
        mem = status.get("memory", {})
        mem_total = round(mem.get("total", 0) / 1024 / 1024 / 1024, 1)
        mem_used = round(mem.get("used", 0) / 1024 / 1024 / 1024, 1)
        days, rem = divmod(status.get("uptime", 0), 86400)
        hours = rem // 3600
        storage_lines = []
        for s in px.nodes(node).storage.get():
            if s.get("active"):
                total_gb = round(s.get("total", 0) / 1024 / 1024 / 1024, 1)
                used_gb = round(s.get("used", 0) / 1024 / 1024 / 1024, 1)
                pct = round(used_gb / total_gb * 100) if total_gb else 0
                storage_lines.append(f"  {s['storage']:<20} {used_gb} / {total_gb} GB ({pct}%)")
        return (
            f"Node: {node}\n"
            f"CPU:     {cpu_pct}%\n"
            f"RAM:     {mem_used} / {mem_total} GB\n"
            f"Uptime:  {days}d {hours}h\n"
            f"Storage:\n" + "\n".join(storage_lines)
        )
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def run_command(command: str) -> str:
    """
    Run a raw shell command on the Proxmox host via SSH.
    Use for anything not covered by the other tools. Be careful with destructive commands.
    """
    try:
        return ssh_run(command)
    except Exception as e:
        return f"Error: {e}"


# ---------------------------------------------------------------------------
# Storage / Drive Tools
# ---------------------------------------------------------------------------

@mcp.tool()
def drive_status() -> str:
    """Show all drives, filesystems, mount points, disk usage, and fstab entries."""
    try:
        return ssh_run("""
echo '=== Drive Layout ==='
lsblk -f
echo ''
echo '=== Mounted Drives Under /mnt ==='
df -h | grep /mnt | sort -k6 || echo 'None mounted'
echo ''
echo '=== fstab (external drives) ==='
grep -v '^#' /etc/fstab | grep -v '^$' | grep '/mnt/' || echo 'No /mnt entries in fstab'
""")
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def add_drive(
    device: str,
    label: str,
    mount: str,
    fstype: str = "ntfs",
    wipe: bool = True,
) -> str:
    """
    Add a drive to Proxmox: partition, format, mount, and add to fstab.

    Args:
        device: Block device path, e.g. /dev/sdd — verify first with drive_status()
        label:  Volume label, e.g. C2_D1_TV — use C#_D#_Type naming convention
        mount:  Mount point path, e.g. /mnt/C2_D1_TV
        fstype: 'ntfs' for cage/portable drives (Windows-readable), 'ext4' for internal only
        wipe:   True  = partition + format a new or blank drive
                False = mount existing filesystem (drive moved between cages)
    """
    try:
        partition = f"{device}1"
        fstab_opts = "ntfs-3g defaults,nofail 0 0" if fstype == "ntfs" else f"{fstype} defaults,nofail 0 2"

        if wipe:
            format_cmd = (
                f"mkfs.ntfs -f -L '{label}' {partition}"
                if fstype == "ntfs"
                else f"mkfs.ext4 -L '{label}' {partition}"
            )
            script = f"""
set -e
echo "[1/6] Partitioning {device}..."
parted -s {device} mklabel gpt mkpart primary {fstype} 0% 100%
echo "[2/6] Reloading partition table..."
partprobe {device}
sleep 2
echo "[3/6] Formatting as {fstype} with label '{label}'..."
{format_cmd}
echo "[4/6] Getting UUID..."
UUID=$(blkid -s UUID -o value {partition})
echo "  UUID: $UUID"
echo "[5/6] Creating mount point and updating fstab..."
mkdir -p {mount}
if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID {mount} {fstab_opts}" >> /etc/fstab
    echo "  Added to fstab"
fi
echo "[6/6] Mounting..."
systemctl daemon-reload && mount -a
df -h {mount}
echo "Done. Tip: relabel later with: ntfslabel {partition} {label}_TV"
"""
        else:
            script = f"""
set -e
echo "[1/4] Clearing dirty bit (if NTFS)..."
{"ntfsfix " + partition + " || true" if fstype == "ntfs" else "echo 'Skipping (not NTFS)'"}
echo "[2/4] Getting UUID..."
UUID=$(blkid -s UUID -o value {partition})
if [ -z "$UUID" ]; then
    echo "ERROR: No UUID found on {partition}. Verify device name with drive_status()."
    exit 1
fi
echo "  UUID: $UUID"
echo "[3/4] Creating mount point and updating fstab..."
mkdir -p {mount}
if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID {mount} {fstab_opts}" >> /etc/fstab
    echo "  Added to fstab"
else
    echo "  UUID already in fstab"
fi
echo "[4/4] Mounting..."
systemctl daemon-reload && mount -a
df -h {mount}
"""
        return ssh_run(script)
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def remove_drive(mount: str) -> str:
    """
    Remove a drive from Proxmox: stops Samba, unmounts, removes from fstab, restarts Samba.
    The mount point directory is left in place. The drive can be physically removed after.

    Args:
        mount: Mount point to remove, e.g. /mnt/C2_D1_TV
    """
    try:
        script = f"""
set -e
echo "[1/4] Stopping Samba..."
systemctl stop smbd
echo "[2/4] Unmounting {mount}..."
if mountpoint -q {mount}; then
    umount {mount} || umount -l {mount}
    echo "  Unmounted"
else
    echo "  Not currently mounted"
fi
echo "[3/4] Removing fstab entry..."
sed -i '\\| {mount} |d' /etc/fstab
systemctl daemon-reload
echo "  Removed from fstab"
echo "[4/4] Restarting Samba..."
systemctl start smbd
echo ""
echo "Done. {mount} removed. Drive can be physically removed."
"""
        return ssh_run(script)
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def relabel_drive(old_mount: str, new_label: str, new_mount: str) -> str:
    """
    Rename a drive's label and mount point when content type becomes known.
    Example: C1_D1 -> C1_D1_TV once you know what's going on it.
    UUID does not change, so the fstab UUID entry stays valid.

    Args:
        old_mount:  Current mount point, e.g. /mnt/C1_D1
        new_label:  New volume label, e.g. C1_D1_TV
        new_mount:  New mount point path, e.g. /mnt/C1_D1_TV
    """
    try:
        script = f"""
set -e
DEVICE=$(findmnt -n -o SOURCE {old_mount})
if [ -z "$DEVICE" ]; then
    echo "ERROR: {old_mount} is not currently mounted."
    exit 1
fi
echo "Device: $DEVICE"
echo "[1/5] Stopping Samba..."
systemctl stop smbd
echo "[2/5] Unmounting {old_mount}..."
umount {old_mount}
echo "[3/5] Relabeling to '{new_label}'..."
ntfslabel --force $DEVICE {new_label}
echo "[4/5] Updating mount point and fstab..."
mkdir -p {new_mount}
sed -i 's| {old_mount} | {new_mount} |g' /etc/fstab
systemctl daemon-reload
echo "[5/5] Remounting and restarting Samba..."
mount -a
systemctl start smbd
echo ""
echo "Done. Now mounted at {new_mount}"
df -h {new_mount}
echo "Old directory {old_mount} left in place — rmdir {old_mount} to remove it"
"""
        return ssh_run(script)
    except Exception as e:
        return f"Error: {e}"


# ---------------------------------------------------------------------------
# Samba Tools
# ---------------------------------------------------------------------------

@mcp.tool()
def samba_status() -> str:
    """Show Samba service status, configured shares, valid users, and Samba user list."""
    try:
        return ssh_run("""
echo '=== Samba Service ==='
systemctl is-active smbd && echo 'Running' || echo 'Stopped'
echo ''
echo '=== Shares ==='
grep -E '^\\[|path|valid users|veto' /etc/samba/smb.conf | grep -v -i 'print\\|Printer'
echo ''
echo '=== Samba Users ==='
pdbedit -L 2>/dev/null || echo 'pdbedit not available'
""")
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def restart_samba() -> str:
    """Restart the Samba file sharing service."""
    try:
        result = ssh_run("systemctl restart smbd && systemctl is-active smbd")
        return f"Samba restarted. Status: {result}"
    except Exception as e:
        return f"Error: {e}"


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    mcp.run()
