## Eclass Discovery

- Prefer the local main tree at `/var/db/repos/gentoo` when present.
- Before inheriting, read each eclass's supported EAPIs, deprecation status, pre-inherit and call-time variables, exports, phases, and defaults.
- On an EAPI bump, re-audit the whole ebuild, including disabled USE branches, generated dependencies, dead helpers, and changed eclass defaults.
- Define phase composition explicitly when eclasses export the same phase.
- An override calls the eclass implementation when its documented behavior must remain. `default` invokes the EAPI default, not an eclass-exported phase.
- Do not inherit an eclass for one helper when clear phase code and current precedent agree.
