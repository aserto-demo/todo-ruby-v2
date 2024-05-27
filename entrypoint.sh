#!/bin/bash
echo "Deleting tmp/pids/server.pid"
set -e
rm -f tmp/pids/server.pid
exec "$@"
