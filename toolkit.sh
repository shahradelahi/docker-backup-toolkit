#!/bin/bash

set -e

has_args() { [[ "$1" == *=* ]] && [[ -n "${1#*=}" ]] || [[ ! -z "$2" && "$2" != -* ]]; }

arg_exists() {
  for arg in $2; do
    if [ "$arg" == "$1" ]; then
      return 0
    fi
  done
  return 1
}

read_arg() {
  IFS='|' read -ra FS <<< "$1"
  shift
  while (("$#")); do
    if [[ " ${FS[*]} " =~ " $1 " ]]; then
      echo "$2"
      break
    fi
    shift
  done
}

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

usage() {
  case $1 in
    backup)
      echo "Usage: $(basename "$0") backup [options]"
      echo ""
      echo "backup from volume or volumes of a container"
      echo ""
      echo "Options:"
      echo "  -c, --container <container-name>      backup all volumes of a container"
      echo "  -v, --volume <volume-name>            backup a single volume"
      echo "  -h, --help                            display help for command"
      ;;
    *)
      echo "Usage: $(basename "$0") [options] [command]"
      echo ""
      echo "Docker volume backup and restore utility"
      echo "Author: @shahradelahi, https://github.com/shahradelahi"
      echo ""
      echo "Options:"
      echo "  -V, --version                         output the version number"
      echo "  -h, --help                            display help for command"
      echo ""
      echo "Commands:"
      echo "  backup [options]                      backup from volume or volumes of a container"
      echo "  restore [options]                     restore backup to volume"
      echo "  help [command]                        display help for command"
      ;;
  esac
}

if arg_exists "--help" "$@" || arg_exists "-h" "$@"; then
  usage
  exit 0
fi

check_volume() {
  VOLUME=$1
  if [ -z "$VOLUME" ]; then
    log "ERR: Volume name is required"
    exit 1
  fi
  LIST=$(sudo docker volume ls -q --filter name="$VOLUME")
  if [ -z "$LIST" ]; then
    log "ERR: Volume $VOLUME not found"
    exit 1
  fi
}

backup_volume() {
  local VOLUME=$1
  check_volume "$VOLUME"
  local NOW="$(date +%Y%m%d%H%M%S)"
  local BACKUP="backup-$NOW"
  local TAR_FILE="$VOLUME-$NOW.tar.gz"
  sudo docker run --name "$BACKUP" -v "$VOLUME:/backup" ubuntu:latest \
    tar -C /backup -czvf "$TAR_FILE" .
  sudo docker cp "$BACKUP:/$TAR_FILE" .
  sudo docker rm -f "$BACKUP"
}

list_volumes() {
  CONTAINER_NAME=$1
  sudo docker inspect -f '{{ range .Mounts }}{{ printf "\n" }}{{ .Type }} {{ if eq .Type "bind" }}{{ .Source }}{{ end }}{{ .Name }} => {{ .Destination }}{{ end }}{{ printf "\n" }}' "$CONTAINER_NAME" | grep volume
}

check_container() {
  LIST=$(sudo docker ps -a -q --filter name="$CONTAINER_NAME")
  if [ -z "$LIST" ]; then
    log "ERR: Container $CONTAINER_NAME not found"
    exit 1
  fi
}

case $1 in
  backup)
    if arg_exists "--volume" "$*" || arg_exists "-v" "$*"; then
      _VOLUME_NAME=$(read_arg "-v|--volume" $*)
      backup_volume "$_VOLUME_NAME"
      exit 0
    fi

    if arg_exists "--container" "$*" || arg_exists "-c" "$*"; then
      CONTAINER_NAME=$(read_arg "-c|--container" $*)
    else
      read -r -p "Container name: " CONTAINER_NAME
    fi

    check_container

    for VOLUME in $(list_volumes "$CONTAINER_NAME" | awk '{print $2}'); do
      if [ -z "$VOLUME" ]; then
        log "ERR: Volume name is required"
        continue
      fi
      backup_volume "$VOLUME"
    done
    ;;
  stop)
    log "ERR: Not implemented yet"
    exit 1
    ;;
  help)
    usage "$2"
    ;;
  *)
    usage
    exit 1
    ;;
esac

exit 0
