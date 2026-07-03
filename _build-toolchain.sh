#!/usr/bin/env bash
# Felicitas (Logseq fork) build toolchain — all USER-SPACE, no root.
# JDK (Temurin 21) + Clojure CLI + babashka + corepack pnpm, then pnpm install.
set -uo pipefail
LOG(){ echo "=== $* === $(date +%H:%M:%S)"; }
mkdir -p ~/.local/bin ~/.local/opt
export PATH="$HOME/.local/bin:$PATH"

LOG "1/5 babashka"
if ! command -v bb >/dev/null; then
  curl -sL https://raw.githubusercontent.com/babashka/babashka/master/install -o /tmp/bb-install.sh \
    && bash /tmp/bb-install.sh --dir ~/.local/bin >/dev/null 2>&1 && echo "bb $(bb --version)" || echo "bb FAILED"
else echo "bb present"; fi

LOG "2/5 Temurin JDK 21 (user-space)"
if [ ! -x ~/.local/opt/jdk-21/bin/java ]; then
  curl -sL "https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jdk/hotspot/normal/eclipse" -o /tmp/jdk21.tgz \
    && mkdir -p ~/.local/opt/jdk-21 \
    && tar xzf /tmp/jdk21.tgz -C ~/.local/opt/jdk-21 --strip-components=1 \
    && echo "java $(~/.local/opt/jdk-21/bin/java -version 2>&1 | head -1)" || echo "JDK FAILED"
else echo "jdk present"; fi
export JAVA_HOME="$HOME/.local/opt/jdk-21"; export PATH="$JAVA_HOME/bin:$PATH"

LOG "3/5 Clojure CLI (user-space prefix ~/.local)"
if ! command -v clojure >/dev/null; then
  curl -sL https://github.com/clojure/brew-install/releases/latest/download/posix-install.sh -o /tmp/clj-install.sh \
    && bash /tmp/clj-install.sh --prefix ~/.local >/dev/null 2>&1 && echo "clojure $(~/.local/bin/clojure --version 2>&1)" || echo "CLOJURE FAILED"
else echo "clojure present"; fi

LOG "4/5 corepack pnpm@10.33.0"
corepack prepare pnpm@10.33.0 --activate >/dev/null 2>&1 && corepack enable >/dev/null 2>&1
echo "pnpm $(corepack pnpm --version 2>&1 || pnpm --version 2>&1)"

LOG "5/5 pnpm install (deps)"
cd ~/sovereign/apps/felicitas || exit 1
corepack pnpm install 2>&1 | tail -15
echo "TOOLCHAIN_DONE deps=$([ -d node_modules ] && du -sh node_modules 2>/dev/null|cut -f1 || echo MISSING) $(date +%H:%M:%S)"
