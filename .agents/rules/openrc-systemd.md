## OpenRC and systemd

- On OpenRC, depend on `virtual/udev` or `virtual/tmpfiles` for those helpers. Neither provider ships `systemctl` or a service manager.
- Depend on `sys-apps/systemd` only for what `systemd-utils` does not ship, such as `systemctl` or `libsystemd`.
- That dependency blocks `elogind` and `systemd-utils`, which an OpenRC install normally has. Say so instead of restoring an any-of that `systemd-utils` cannot satisfy.
- Do not default a `systemd` USE flag on; the profile decides, and forcing it drags systemd into an OpenRC install for an optional hook.
- A package that installs a unit for a long-running service installs an OpenRC script too. A variant that only differs by a flag becomes a conf.d variable.
- A template unit is one script, not one per instance: install it under the plain name and read the instance from `${RC_SVCNAME#*.}`. The admin symlinks `/etc/init.d/<name>.<instance>` to it, as `net-analyzer/nfdump` documents in its own script.
- That one script also serves the plain unit of the same name. Without a suffix `${RC_SVCNAME#*.}` returns the service name itself, so give that case a default or refuse it with a message.
- Take the script's shape from `net-dns/knot-resolver/files/kresd.initd-r2`: conf.d variables with defaults, `command_background` with a `pidfile`, `command_user`, `capabilities`, and `checkpath` in `start_pre`.
- Do not add `supervisor=supervise-daemon` to emulate `Restart=`. OpenRC does not supervise by default, and a unit that says `Restart=no` must not be restarted automatically.
- Map the unit's fields: `AmbientCapabilities` to `capabilities`, `LimitNOFILE` to `rc_ulimit`, `Environment` to `export`, `WorkingDirectory` to `directory`.
- `RuntimeDirectory` becomes `checkpath -d` in `start_pre`; an `ExecStartPost` that waits for a path becomes `ewaitfile` in `start_post`.
- Remove the socket in `stop_post`, as `sys-apps/dbus` does. A `start_post` that fixes its mode otherwise lands on a stale file the daemon then replaces.
- `capabilities` takes cap_iab(3) text: `^cap_x` grants it in the ambient set and `!cap_x` drops it from the bounding set.
- Use `required_files` for a config the daemon cannot start without. Do not require one the daemon creates itself on first run.
- Do not set `umask` to fix one file's mode; it applies to everything the daemon creates. Fix the specific path instead.
- `output_log` is not the default. Under `command_user`, put the file in a directory that user owns, because `start-stop-daemon` opens the redirection after dropping privilege.
- An installed unit's `ExecStart` must name the path the ebuild installs to. `newsbin` puts the program in `/usr/sbin` while the upstream unit still says `/usr/bin`.
- Start the service and exercise what it does: a port that answers, a socket the CLI talks to, traffic that reaches the far end. `rc-service start` returning `[ ok ]` says nothing about whether the daemon stayed up. Without an OpenRC system, install the package, record the script as untested in the completion report, and fix problems reported back against it.
