## Desktop Integration

Read with: `prebuilt-binaries.md` when the application ships prebuilt; `dependencies.md` for the revbump a changed desktop file or icon needs.

- Match the installed desktop basename to the measured Wayland `app_id` or X11 `WM_CLASS`, or add `StartupWMClass`; an unmatched window gets a default icon. Measure a running instance, using KWin's `workspace.windowList()` where available.
- GTK3 uses `g_get_prgname()` for this identity rather than the `GApplication` id: `org.example.App.desktop` can report `app`.
- Before changing ozone flags, launch with both `--ozone-platform-hint=auto` and `--ozone-platform=wayland` and verify the selected platform; either can fail. Confirm every switch exists in the bundled Chromium version, which silently ignores newer switches.
- Because desktop profiles enable `wayland` by default, a `wayland?` switch reaches X11 users too. Prefer runtime platform selection.
