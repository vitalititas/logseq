#!/usr/bin/env bash
export JAVA_HOME="$HOME/.local/opt/jdk-21"
export PATH="$HOME/.local/bin:$JAVA_HOME/bin:$PATH"
cd ~/sovereign/apps/felicitas || exit 1
echo "=== CORRECTED build chain $(date +%H:%M) ==="
echo "--- 1/4 cljs:release-electron (produces target/db-worker.js + all targets) ---"
corepack pnpm cljs:release-electron 2>&1 || { echo "FELICITAS_BUILD_FAILED stage=cljs $(date +%H:%M)"; exit 1; }
echo "--- 2/4 db-worker-node:bundle ---"
corepack pnpm db-worker-node:bundle 2>&1 || { echo "FELICITAS_BUILD_FAILED stage=nodebundle $(date +%H:%M)"; exit 1; }
echo "--- 3/4 webpack-app-build ---"
corepack pnpm webpack-app-build 2>&1 || { echo "FELICITAS_BUILD_FAILED stage=webpack $(date +%H:%M)"; exit 1; }
echo "--- 4/4 gulp electronMaker (package desktop app) ---"
corepack pnpm exec gulp electronMaker 2>&1 || { echo "FELICITAS_BUILD_FAILED stage=electronMaker $(date +%H:%M)"; exit 1; }
echo "FELICITAS_BUILD_DONE $(date +%H:%M)"
