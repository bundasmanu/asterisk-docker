#!/bin/bash

set -e

trap "Ok received Exit" HUP INT QUIT TERM

update_vars() {
    SRC_FOLDER="$ASTERISK_TEMP_ETC_DIR"

    # Files to skip
    SKIP_FILES=("extensions.conf")

    mkdir -p "$ASTERISK_ETC_DIR"

    for file in "$SRC_FOLDER"/*.conf; do
        [ -f "$file" ] || continue
        filename=$(basename "$file")

        # Check if the file is in the skip list
        if [[ " ${SKIP_FILES[*]} " == *" $filename "* ]]; then
            echo "Skipping $filename"
            continue
        fi

        tmpfile="$(mktemp)"

        echo "Processing $filename"
        envsubst < "$file" > "$tmpfile" && mv "$tmpfile" "$ASTERISK_ETC_DIR/$filename"
    done
}

add_permissions() {

    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_CACHE_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_ETC_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_MOD_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_VARLIB_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_DB_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_KEY_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_DATA_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_AGI_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_POOL_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_RUN_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_LOG_DIR}
    chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} ${ASTERISK_BIN_DIR}

}

case "$1" in
    shell)
        exec /bin/bash --login
        ;;
    run)
        apt-get install -y gettext
        update_vars
        add_permissions
        asterisk -vvvddd -f -T -U ${ASTERISK_USER} -G ${ASTERISK_GROUP} -p
        ;;
    help)
        asterisk -h
        ;;
    *)
        echo "Executing custom command"
        exec "$@"
        ;;
esac

