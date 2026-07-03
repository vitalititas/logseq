#!/usr/bin/env bash
export JAVA_HOME="$HOME/.local/opt/jdk-21"; export PATH="$HOME/.local/bin:$JAVA_HOME/bin:$PATH"
cd ~/sovereign/apps/felicitas || exit 1
corepack pnpm exec gulp electronMaker 2>&1
[ $? -eq 0 ] && echo "FELICITAS_REPACK_DONE $(date +%H:%M)" || echo "FELICITAS_REPACK_FAILED $(date +%H:%M)"
