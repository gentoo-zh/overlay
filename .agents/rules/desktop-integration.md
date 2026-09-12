## Desktop Integration

- A window gets a default icon when its Wayland `app_id` or X11 `WM_CLASS` matches no installed desktop file's basename.
- Measure that `app_id` or `WM_CLASS` on a running instance; KWin reports it through `workspace.windowList()`. Then rename the file or add `StartupWMClass`.
- Toolkits derive it differently: GTK3 sends `g_get_prgname()`, not the `GApplication` id, so `org.example.App.desktop` still reports `app`.
- `--ozone-platform-hint=auto` and `--ozone-platform=wayland` are not interchangeable, and either can be the one that fails. Before changing an ozone switch, launch both ways and check which platform the build took.
- A bundled Chromium silently ignores switches its version predates; confirm each one exists in the shipped binary.
- `wayland` is a desktop-profile default, so a `wayland?`-guarded switch also reaches X11 users. Prefer a switch that resolves the platform at runtime over one that forces it.
