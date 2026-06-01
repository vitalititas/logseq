# Asymmetric AI

Asymmetric AI is a privacy-first knowledge workspace for notes, research, tasks,
PDF annotation, whiteboards, and connected thinking.

This repository is a branded fork of Logseq maintained for the Asymmetric AI
workspace. The visible product, mobile app, desktop package, store metadata, and
launcher surfaces use the Asymmetric AI brand. Internal `logseq` namespaces,
protocols, graph files, and plugin compatibility surfaces are intentionally kept
where changing them would break existing graphs or extensions.

## Android

The Android app label is `Asymmetric AI`. Build outputs are named with the
`Asymmetric-AI` prefix.

```bash
pnpm install --frozen-lockfile
pnpm sync-android-release
cd android
./gradlew assembleDebug
```

## Compatibility

Asymmetric AI keeps Logseq-compatible graph storage and plugin APIs so existing
workflows continue to load. Rebranding should stay focused on user-visible text,
metadata, icons, and package artifacts.

## License

AGPL-3.0. Upstream Logseq remains the original open-source foundation for this
fork.
