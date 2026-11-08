ARG PROFILE
FROM gentoo/stage3:${PROFILE} AS update
ARG PROFILE IMAGE BASE RUN

# stage3 has no world file: @world covers only @system, and depclean would drop the rest
RUN emerge-webrsync --no-pgp-verify \
 && getuto \
 && FEATURES="getbinpkg" emerge --quiet --update --deep --newuse --with-bdeps=y @installed \
 && FEATURES="getbinpkg" emerge --quiet @preserved-rebuild \
 && printf 'image: %s\nbase: gentoo/stage3:%s@%s\nimage gentoo: %s\nimage run: %s\n' \
    "$IMAGE" "$PROFILE" "$BASE" "$(cat /var/db/repos/gentoo/metadata/timestamp.commit)" "$RUN" \
    > /etc/gentoo-zh-ci-image \
 && rm -rf /var/db/repos/gentoo /var/cache/distfiles/* /var/cache/binpkgs/*

# one layer, as gentoo/stage3 itself is built: the update layer would duplicate every replaced file
FROM scratch
COPY --from=update / /
CMD ["/bin/bash"]
