#!/bin/sh -l

set -eu

# Configure SSH path
SSH_PATH="$HOME/.ssh"
mkdir -p "$SSH_PATH"
chmod 700 "$SSH_PATH"

# Set up known_hosts file
touch "$SSH_PATH/known_hosts"
chmod 600 "$SSH_PATH/known_hosts"

# Set up the deploy key
echo "$INPUT_DEPLOY_KEY" > "$SSH_PATH/deploy_key"
chmod 600 "$SSH_PATH/deploy_key"

eval "$(ssh-agent -s)"
ssh-add "$SSH_PATH/deploy_key"


# Do the deployment
sh -c "rsync $INPUT_FLAGS -e 'ssh -i $SSH_PATH/deploy_key -o StrictHostKeyChecking=no' $INPUT_OPTIONS $GITHUB_WORKSPACE/${INPUT_LOCAL_PATH#/} $INPUT_USER@$INPUT_HOST:$INPUT_REMOTE_PATH"