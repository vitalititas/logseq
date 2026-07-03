#!/usr/bin/env bash
export JAVA_HOME="$HOME/.local/opt/jdk-21"
export PATH="$HOME/.local/bin:$JAVA_HOME/bin:$PATH"
cd ~/sovereign/apps/felicitas || exit 1
echo "=== build env: java=$(java -version 2>&1|head -1) clj=$(command -v clojure) $(date +%H:%M) ==="
echo "=== running release-electron ==="
corepack pnpm release-electron 2>&1
rc=$?
if [ $rc -eq 0 ]; then echo "FELICITAS_BUILD_DONE $(date +%H:%M)"; else echo "FELICITAS_BUILD_FAILED rc=$rc $(date +%H:%M)"; fi
