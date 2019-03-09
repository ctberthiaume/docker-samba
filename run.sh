#!/bin/bash

# Taken from postgres docker startup script to handle
# docker secrets from file.
# https://github.com/docker-library/postgres/blob/ef04f3055bab11b10d3d5c41a659acfacf2c850b/10/docker-entrypoint.sh
#
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

# SAMBA_PASSWORD_FILE will be converted to SAMBA_PASSWORD
file_env "SAMBA_PASSWORD" "password"
file_env "SAMBA_SHARE_NAME" "data"

sed \
    -e "s/SAMBA_USER/${SAMBA_USER}/" \
    -e "s/SAMBA_SHARE_NAME/${SAMBA_SHARE_NAME}/" \
    /smb_share_template.txt >> /etc/samba/smb.conf

id -u "$SAMBA_USER" >/dev/null 2>&1 || adduser --disabled-password --gecos "" "$SAMBA_USER"
chown -R "${SAMBA_USER}:${SAMBA_USER}" /data
echo -e "${SAMBA_PASSWORD}\n${SAMBA_PASSWORD}" | smbpasswd -sa "$SAMBA_USER"

# Run Samba in the foreground
/usr/sbin/smbd -FS
