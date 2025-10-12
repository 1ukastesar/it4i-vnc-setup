# IT4I VNC session setup scripts

Using SSH port forwarding - should work on common linux distros.

## Setup

> [!IMPORTANT]
> Make sure you have already working SSH setup to IT4I, ideally with no password login (e.g. SSH keys in place)

```bash
git clone https://github.com/1ukastesar/it4i-vnc-setup.git
cd it4i-vnc-setup

cat > .env <<EOF
REMOTE_USER=<USERNAME>
REMOTE_HOST=barbora.it4i.cz
EOF
```

## Usage

Just use:

```bash
./vnc_start.sh
```

Now, connect VNC client of your choice to `localhost:5961` (script should point that out on successful execution). 
It will ask for vncserver password you set up earlier upon 1st script execution.

> [!INFO]
> For that purpose, you can use RealVNC Viewer, KRDC, Remmina... generally any client should work


After you're done, just exit VNC client and clean up after yourself:

```bash
./vnc_stop.sh
```
