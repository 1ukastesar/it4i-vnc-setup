#!/bin/bash
#
# Tears down the IT4I VNC connection established by vnc_start.sh
#
# 1. Reads the session info file.
# 2. Kills the remote VNC server process.
# 3. Kills the local SSH tunnel process.
# 4. Deletes the session file.
#

set -e

# --- Configuration ---
STATE_FILE="/tmp/vnc_session.info"
# --- End Configuration ---

if [ ! -f "$STATE_FILE" ]; then
    echo "No active VNC session file found at ${STATE_FILE}."
    echo "Nothing to do."
    exit 0
fi

echo "--> Found active session file. Reading configuration..."

# Source the file to get the variables
source "$STATE_FILE"

if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_HOST" ] || [ -z "$DISPLAY_NUM" ] || [ -z "$SSH_PID" ]; then
    echo "Session file is corrupted or incomplete. Manual cleanup may be required."
    exit 1
fi

echo "--> Terminating remote VNC server (Display :${DISPLAY_NUM}) on ${REMOTE_HOST}..."

# Kill the VNC server on the remote cluster
ssh "${REMOTE_USER}@${REMOTE_HOST}" "vncserver -kill :${DISPLAY_NUM}"

echo "--> Terminating local SSH tunnel (PID: ${SSH_PID})..."

# Kill the local SSH tunnel process
# Check if the process exists before trying to kill it
if ps -p "$SSH_PID" > /dev/null; then
    kill "$SSH_PID"
    echo "   - SSH tunnel process ${SSH_PID} terminated."
else
    echo "   - Warning: SSH tunnel process with PID ${SSH_PID} not found. It may have already been terminated."
fi


echo "--> Cleaning up session file..."
rm -f "$STATE_FILE"

echo ""
echo "✅ VNC session terminated successfully."

