#!/bin/bash
URL=localhost
PORT=8003
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_DIR=$DIR/venv
PROJECT_DIR=$DIR/test_project

# Launch UWSGI
venv/bin/uwsgi --http :$PORT --wsgi-file=$PROJECT_DIR/wsgi.py --home=$ENV_DIR &

sleep 2

# Generate request
response=$(curl --silent --write-out "\n%{http_code}\n" $URL:$PORT)

# Parse output
status_code=$(echo "$response" | sed -n '$p')
html=$(echo "$response" | sed '$d')

# Kill UWSGI
kill $!

# Display output and return error if fail
case "$status_code" in
        200) echo -e "\033[32mSUCCESS\033[0m"
             ;;
        *)   echo -e "\033[31mFAIL\033[0m Status: $status_code"
             exit 1
             ;;
esac
