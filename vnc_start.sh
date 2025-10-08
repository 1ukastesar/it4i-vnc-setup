#!/bin/bash
#
# Automates setting up an IT4I VNC connection.
#
# 1. Finds a free VNC display on the remote cluster.
# 2. Starts the VNC server on that display.
# 3. Establishes an SSH tunnel from a fixed local port to the remote VNC port.
#

set -e

# --- Configuration ---

source "$(dirname "$0")/.env"

LOCAL_PORT="5961"
VNC_GEOMETRY="1920x1080"
STATE_FILE="/tmp/vnc_session.info"
# --- End Configuration ---

if [ -f "$STATE_FILE" ]; then
    echo "An active VNC session file already exists at ${STATE_FILE}."
    echo "Please run the cleanup script first if you are sure no session is active."
    exit 1
fi

REMOTE_HOST="$(ssh "${REMOTE_USER}@${REMOTE_HOST}" "hostname")"
echo "--> Found fixed hostname for this session: ${REMOTE_HOST}."

echo "--> Connecting to ${REMOTE_HOST} to find a free VNC display..."

# Find the first available display number between 1 and 99
DISPLAY_NUM=-1
for i in $(seq 1 99); do
    if ! ssh "${REMOTE_USER}@${REMOTE_HOST}" "ps aux | grep Xvnc | sed -rn 's/(\s) .*Xvnc (\:[0-9]+) .*/\1 \2/p'" | grep -q ":${i}"; then
        DISPLAY_NUM=$i
        break
    fi
done

if [ "$DISPLAY_NUM" -eq -1 ]; then
    echo "Could not find a free VNC display."
    exit 1
fi

echo "--> Found free display: :${DISPLAY_NUM}"

echo "--> Starting VNC server on ${REMOTE_HOST}..."
# Start the VNC server and capture the hostname of the node it's running on.
# The `vncserver` command prints details, and `hostname` prints the node name.
# We capture the last line of the output, which will be the hostname.
COMPUTE_NODE=$(ssh "${REMOTE_USER}@${REMOTE_HOST}" "vncserver :${DISPLAY_NUM} -geometry ${VNC_GEOMETRY} && hostname")
COMPUTE_NODE=$(echo "$COMPUTE_NODE" | tail -n 1)

if [ -z "$COMPUTE_NODE" ]; then
    echo "Failed to start VNC server or get compute node hostname."
    exit 1
fi

echo "--> VNC server started on compute node: ${COMPUTE_NODE}"

REMOTE_PORT=$((5900 + DISPLAY_NUM))

echo "--> Creating SSH tunnel: localhost:${LOCAL_PORT} -> ${COMPUTE_NODE}:${REMOTE_PORT}"

# Create the SSH tunnel in the background.
# -f: Go into the background.
# -N: Do not execute a remote command.
# -L: The port forwarding specification.
ssh -f -N -L "${LOCAL_PORT}:${COMPUTE_NODE}:${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}"

# Find the PID of the backgrounded SSH tunnel process and save it.
SSH_PID=$(pgrep -f "ssh -f -N -L ${LOCAL_PORT}:${COMPUTE_NODE}:${REMOTE_PORT}")

if [ -z "$SSH_PID" ]; then
    echo "Failed to create SSH tunnel."
    # Attempt to clean up the remote server
    ssh "${REMOTE_USER}@${REMOTE_HOST}" "vncserver -kill :${DISPLAY_NUM}"
    exit 1
fi

# Save session info for the cleanup script
echo "REMOTE_USER=${REMOTE_USER}" > "${STATE_FILE}"
echo "REMOTE_HOST=${COMPUTE_NODE}" >> "${STATE_FILE}"
echo "DISPLAY_NUM=${DISPLAY_NUM}" >> "${STATE_FILE}"
echo "SSH_PID=${SSH_PID}" >> "${STATE_FILE}"

echo ""
echo "✅ VNC setup complete!"
echo ""
echo "   - VNC Server is running on: ${COMPUTE_NODE} (Display :${DISPLAY_NUM})"
echo "   - SSH tunnel is active (PID: ${SSH_PID})."
echo ""
echo "   ➡️ Connect your VNC client to: localhost:${LOCAL_PORT}"
echo ""
echo "   To terminate, run the vnc_stop.sh script."

