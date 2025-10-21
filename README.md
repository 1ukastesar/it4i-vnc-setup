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
# Right now, these two do not work on login2, if you find any other, just add it here
DISPLAY_BLACKLIST=(10 11)
EOF
```

## Usage

Just use:

```bash
./it4i-vnc start
```

> [!IMPORTANT]
> Upon 1st script execution, the `vncserver` command should ask you to set up a password. Use something strong, but note that only 8 chars are evaluated (yeah...)

Now, connect VNC client of your choice to `localhost:5961` (script should point that out on successful execution). 

> [!NOTE]
> For that purpose, you can use RealVNC Viewer, KRDC, Remmina... generally any client should work

> [!TIP]
The client will ask for vncserver password you set up earlier.

After you're done, just exit VNC client and clean up after yourself:

```bash
./it4i-vnc stop
```

## Docs

These scripts were made according to [IT4I VNC Guide](<https://docs.it4i.cz/en/docs/general/access-services/graphical-user-interface/vnc>).
