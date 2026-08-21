#!/usr/bin/env python3
"""Print the PUB_HOSTED and PUB_GIT arrays for an ebuild from a pubspec.lock.

dart-pub.eclass turns them into SRC_URI and lays the fetched archives out as a
pub-cache, so the build needs no bundled pub-cache tarball. Hosted packages carry
the sha256 pub records; git packages carry the resolved commit and the package's
path inside the repository.

Usage: pubspec2ebuild.py PUBSPEC_LOCK
"""

import argparse

import yaml

PUB_DEV = "https://pub.dev"


def load_packages(lockfile):
    with open(lockfile) as f:
        return yaml.safe_load(f).get("packages", {})


def hosted_packages(packages):
    """(name, version, sha256) for every package from pub.dev.

    dart-pub.eclass lays the cache out under hosted/pub.dev and fetches from
    pub.dev's archive API, so a package resolved against another registry would
    be written out with the wrong origin and a digest that does not match it.
    """
    result = []
    for info in packages.values():
        if info.get("source") != "hosted":
            continue
        desc = info["description"]
        url = desc.get("url", PUB_DEV)
        if url.rstrip("/") != PUB_DEV:
            raise SystemExit(
                f"{desc['name']}: dart-pub.eclass only supports {PUB_DEV}, got {url}"
            )
        result.append((desc["name"], info["version"], desc["sha256"]))
    return sorted(result)


def git_packages(packages):
    """(name, url, commit, subpath) for every package pinned to a git revision.

    dart-pub.eclass fetches these as GitHub repository archives, so a package
    hosted anywhere else is rejected rather than turned into a wrong SRC_URI.
    """
    result = []
    for name, info in packages.items():
        if info.get("source") == "git":
            desc = info["description"]
            url = desc["url"]
            if not url.startswith("https://github.com/"):
                raise SystemExit(
                    f"{name}: dart-pub.eclass only fetches GitHub archives, got {url}"
                )
            result.append(
                (name, url, desc["resolved-ref"], desc.get("path", "."))
            )
    return sorted(result)


def render(name, entries):
    lines = [f"{name}=("]
    lines += [f'\t"{" ".join(fields)}"' for fields in entries]
    lines.append(")")
    return "\n".join(lines)


def archive_urls(hosted, git):
    """The archive each entry is fetched from, in the order SRC_URI lists them."""
    urls = [f"{PUB_DEV}/api/archives/{n}-{v}.tar.gz" for n, v, _ in hosted]
    urls += [f"{u[:-4] if u.endswith('.git') else u}/archive/{c}.tar.gz"
             for _, u, c, _ in git]
    return urls


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pubspec_lock", help="path to the app's pubspec.lock")
    parser.add_argument("--urls", action="store_true",
                        help="print the archive URLs instead of the arrays")
    args = parser.parse_args()

    packages = load_packages(args.pubspec_lock)
    hosted, git = hosted_packages(packages), git_packages(packages)

    if args.urls:
        print("\n".join(archive_urls(hosted, git)))
        return

    blocks = [render("PUB_HOSTED", hosted)]
    if git:
        blocks.append(render("PUB_GIT", git))
    print("\n\n".join(blocks))


if __name__ == "__main__":
    main()
