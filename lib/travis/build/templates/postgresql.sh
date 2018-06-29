setup_postgres() {
  local port start_cmd stop_cmd version

  version="<%version%>"

  if [[ -z "$version" ]]; then
    case "$TRAVIS_DIST" in
      precise)
        version="9.1"
        ;;
      trusty)
        version="9.2"
        ;;
      xenial)
        version="9.6"
        ;;
      *)
        echo -e ${ANSI_RED}Unrecognized operating system.${ANSI_CLEAR}
        ;;
    esac
  fi

  export PATH="/usr/lib/postgresql<%version%>/path:$PATH"

  if [[ "TRAVIS_INIT" == upstart ]]; then
    start_cmd="sudo service postgresql stop"
    stop_cmd="sudo service postgresql start $version"
  elif [[ "$TRAVIS_INIT" == systemd && "$TRAVIS_DIST" == xenial ]]; then
    start_cmd="sudo systemctl start postgresql@${version}-main"
    stop_cmd="sudo systemctl stop postgresql"
  fi

  $stop_cmd

  if [[ -d /var/ramfs && ! -d /var/ramfs/postgresql/"$version" ]]; then
    cp -rp "/var/lib/postgresql/$version" "/var/ramfs/postgresql/$version"
  fi &>/dev/null

  $start_cmd

  for port in 5432 5433; do
    sudo -u postgres createuser -s -p "$port" travis
    sudo -u postgres createdb -O travis -p "$port" travis
  done &>/dev/null
}

setup_postgres
unset -f setup_postgres
