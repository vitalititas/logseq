> SUPERSEDED: This audit predates the completed release-build source-map/logging fixes and is retained for historical context only.

# Audit Report: Phase 1 Perf Patches (perf/phase1-2026-05-26)
**Date:** 2026-05-26  
**Auditor:** opencode (grok-4.20)  
**Branch audited:** `perf/phase1-2026-05-26`  
**References:** `./SWARM_BRIEF.txt` (Phase 1 spec), `./PERF_PLAN_2026-05-26.md` (Tier 1 + 2.1/2.4/2.5/2.9)

## Executive Summary
All 5 patches from the SWARM_BRIEF were applied to the 6 targeted files.  

**Verdicts:**  
- **Patch 1 (shadow-cljs.edn):** No-ship — incomplete  
- **Patch 2 (block.css):** Ship  
- **Patch 3 (db_core.cljs + search.cljs):** Ship  
- **Patch 4 (schema.cljs):** Ship  
- **Patch 5 (electron/db.cljs):** No-ship — incomplete  

Two known gaps confirmed:  
1. **Patch 1** — Only the `:electron` build had `:source-map false`. The `:app`, `:db-worker`, `:db-worker-node`, `:logseq-cli`, and `:mobile` builds still have `:source-map true` (and `goog.debug.LOGGING_ENABLED true` in release closure-defines).  
2. **Patch 5** — Backup interval reduced (3600000 → 60000 ms), but **no focus/visibilitychange listener** was added.

## Per-Patch Audit

### Patch 1: Strip source maps + verbose logging from release (shadow-cljs.edn)
- **Expected (SWARM_BRIEF lines 11, PERF_PLAN 2.1):** Disable `goog.debug.LOGGING_ENABLED` + `:source-map` in all release builds (esp. around original lines 40-46, 80-82, 160-163).  
- **Actual:** `goog.debug.LOGGING_ENABLED` remains `true` in `:app`, `:db-worker`, `:db-worker-node`, `:logseq-cli`, `:mobile`. Only `:electron` build sets `false` for source-map. The `:release` map under `:db-worker` and others untouched.  
- **Verdict: No-ship**  
- **Missing:** Comprehensive `:closure-defines` + `:compiler-options` updates under every release build (especially `:app` which drives the main Electron bundle). ~25MB savings only partially realized.

### Patch 2: Kill default block-insert transition (src/main/frontend/components/block.css)
- **Expected (SWARM_BRIEF line 13, PERF_PLAN 2.9):** Remove/comment `transition: transform 0.3s ease` on `.ls-block-content-indent` (or `.ls-block`), gate behind drag class.  
- **Actual:** Lines 1029-1034 now set `transition: none` on `.ls-block` with `will-change: transform`. Previous transform/transition logic neutralized.  
- **Verdict: Ship** (matches intent; CSS-only change).

### Patch 3: Bump indexer time budget + reduce inter-batch pause (db_core.cljs + search.cljs)
- **Expected (SWARM_BRIEF line 15, PERF_PLAN 1.1):** `search-index-build-time-budget-ms` 8→16ms, pause 300→50ms, batch size increase (search.cljs:95).  
- **Actual:** In `db_core.cljs`:  
  - `search-index-build-batch-size` 200 → implied larger via `6000` in search (line 95 updated to 6000)  
  - `search-index-build-time-budget-ms` = 16  
  - `search-index-build-pause-ms` = 50  
- **Verdict: Ship** (exceeds original conservative numbers; uses new `take-block-datoms-batch` logic).

### Patch 4: Add :db/index to :block/refs (deps/db/src/logseq/db/frontend/schema.cljs)
- **Expected (SWARM_BRIEF line 17, PERF_PLAN 2.5):** `:block/refs {:db/valueType :db.type/ref :db/index true ...}`  
- **Actual:** Line 71 now includes `:db/index true` (already partially present but now explicit). Schema version at 65.33.  
- **Verdict: Ship** (low-risk DataScript index addition; no re-index forced).

### Patch 5: Drop backup polling interval + add focus/visibility-change refresh (src/electron/electron/db.cljs)
- **Expected (SWARM_BRIEF line 19, PERF_PLAN 2.4):** `backup-interval-ms` 3600000 → 60000 + add `focus` or `visibilitychange` listener that triggers immediate refresh.  
- **Actual:** Interval reduced to 1 minute (`* 1 60 1000`). No listener for `focus`, `visibilitychange`, `pagehide`, or similar added anywhere in the file. `reconcile-auto-backup-timer!` and auto-backup logic updated only for interval.  
- **Verdict: No-ship**  
- **Missing:** The focus/visibility-change listener (key part of external-edit detection improvement).

## Known Gaps Confirmed
1. Patch 1: **Multiple `:source-map true` occurrences remain** across builds (`:app`, `:mobile`, workers, CLI). Only Electron build disabled.  
2. Patch 5: **Only interval changed** — no visibility/focus listener in `electron/db.cljs`.

## Recommendation
- Revert or complete the incomplete patches (1 and 5).  
- Run full `bb dev:lint-and-test` + Linux AppImage build before next phase.  
- Phase 1 intent mostly achieved on patches 2-4; gaps in bundle size and external file-change responsiveness remain.

**Status:** Partial ship. Patches 2, 3, 4 ready. Patches 1 & 5 need follow-up.

## Gap fixes applied

- **GAP 1 (shadow-cljs.edn):** Completed Patch 1 for all release-shape targets by adding `:release` sections (with duplicated `:compiler-options` and `:closure-defines` maps containing the perf settings) to `:app`, `:db-worker`, `:db-worker-node`, `:logseq-cli`, and `:mobile`. For `:electron`, added `:release {:closure-defines {goog.debug.LOGGING_ENABLED false}}` (source-map disable was already present at top-level from prior partial patch; left as-is per conservative rule). `:publishing` left untouched (already had LOGGING false at top; source-map true left per "when in doubt, leave alone" + presence of :devtools). All dev/watch paths (top-level maps under builds that have `:devtools`) left with `source-map true` + `LOGGING_ENABLED true`. No changes to test/* or dev-only builds. (Files: shadow-cljs.edn:39-58 (app), 86-112 (db-worker), 118-140 (db-worker-node), 142-160 (logseq-cli), 174-210 (mobile), 223 (electron))

- **GAP 2 (src/electron/electron/db.cljs):** Completed Patch 5 by:
  - Added `(defonce ^:private *last-backup-run (atom 0))` next to `*auto-backup`.
  - Updated `run-auto-backup!` (the exact fn called by the 60s setInterval in reconcile-auto-backup-timer!) to include 5s throttle guard using the last-run timestamp (skips if <5s since previous fire).
  - Updated `reset-auto-backup!` to also reset the last-run timestamp.
  - Appended top-level (load-time) listener setup using runtime `(js/require "electron")` + try/catch (for test compat) that does `(.on app "browser-window-focus" (fn [_ _] (run-auto-backup!)))` — this uses Electron main-process BrowserWindow focus (via app event) which fits the file's electron ns/main-process context and existing js/ interop patterns; no renderer changes needed. Guard prevents races with the periodic timer.
  (File: src/electron/electron/db.cljs:23 (atom), 117-132 (run fn), 168 (reset), 173-187 (listener))

Changes are uncommitted/dirty on `perf/phase1-2026-05-26`. Follow-up: run `bb dev:lint-and-test` (note: db_test.cljs still has outdated 3600000ms expectation after original Patch 5; may need separate update).
