#!/bin/bash
set -eo pipefail

API_PORT=3003

echo "Prepare configuration...."
case "$OSTYPE" in
linux*)
	sudo rm -rf tmp/pids/*.pid
	;;
*)
	rm -rf tmp/pids/*.pid
	;;
esac

if [ ! -d tmp ]; then
	mkdir tmp
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
	if ! grep :cached docker-compose.yml >/dev/null; then
		if ! sed -i '' '/- \.:\/app/s/$/:cached/g' docker-compose.yml >/dev/null; then
			sed -i '/- \.:\/app/s/$/:cached/g' docker-compose.yml
		fi
	fi
fi

echo "Start Services....."
docker compose up -d
