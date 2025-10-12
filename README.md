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
