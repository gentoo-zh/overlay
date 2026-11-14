## OpenRC and systemd

Read with: `dependencies.md` for the revbump a changed unit or script needs; `new-packages.md` or `version-bumps.md` for the change itself.

- On OpenRC, use `virtual/udev` and `virtual/tmpfiles` for those helpers; their providers supply neither `systemctl` nor a service manager.
- Require `sys-apps/systemd` only for features absent from `systemd-utils`, such as `systemctl` or `libsystemd`. That blocks the `elogind` and `systemd-utils` an OpenRC install normally has: report the conflict instead of restoring an any-of that `systemd-utils` cannot satisfy.
- Leave the `systemd` USE default to profiles, so optional hooks remain optional on OpenRC.
- Long-running service units include an OpenRC script. Express flag-only variants as conf.d variables.
- A template and plain unit share one plain-named script. Read `${RC_SVCNAME#*.}` for instances; admins symlink `/etc/init.d/<name>.<instance>` to it, as in `net-analyzer/nfdump`. Without a suffix it returns the service name: provide a default or refuse with a message.
- Follow `net-dns/knot-resolver/files/kresd.initd-r2`: conf.d defaults, `command_background` with `pidfile`, `command_user`, `capabilities`, and `checkpath` in `start_pre`.
- Preserve OpenRC's unsupervised default when translating `Restart=`; leave `supervisor` unset for that purpose. `Restart=no` stays without automatic restarts.
- Map `AmbientCapabilities` to `capabilities`, `LimitNOFILE` to `rc_ulimit`, `Environment` to `export`, and `WorkingDirectory` to `directory`.
- Map `RuntimeDirectory` to `checkpath -d` in `start_pre`; use `ewaitfile` in `start_post` for an `ExecStartPost` path wait.
- Remove sockets in `stop_post`, as `sys-apps/dbus` does, so `start_post` mode fixes target the new socket.
- `capabilities` uses cap_iab(3): `^cap_x` grants ambient capabilities; `!cap_x` drops bounding-set capabilities.
- `required_files` lists only startup prerequisites, excluding files the daemon creates on first run. Fix individual path modes directly; `umask` affects all daemon-created files.
- Add `output_log` only when needed. Under `command_user`, its directory belongs to that user because `start-stop-daemon` opens redirection after dropping privilege.
- Installed `ExecStart` paths match ebuild destinations, including `/usr/sbin` for `newsbin`.
- Start the service and exercise its function: a responsive port, CLI socket, or end-to-end traffic. Verify the daemon stays running after startup. Without OpenRC, install the package, report the script untested, and fix reported problems.
