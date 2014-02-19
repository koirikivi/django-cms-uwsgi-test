#!/bin/bash
URL=localhost
PORT=8003
RUNSERVER_PORT=8005
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_DIR=$DIR/venv
PROJECT_DIR=$DIR/test_project

cd $DIR

echo "Remove .pycs"
rm -rf $DIR/cms/**/*.pyc $DIR/menus/**/*.pyc

echo "Clear DB"
rm -f $DIR/db.sqlite3 && \
    $ENV_DIR/bin/python $DIR/manage.py syncdb --noinput && \
    $ENV_DIR/bin/python $DIR/manage.py migrate

# Test runserver
echo "Starting runserver"
$ENV_DIR/bin/python $DIR/manage.py runserver --noreload $RUNSERVER_PORT &

echo "Sleeping"
sleep 10

# Generate request
echo "Generating request"
response=$(curl --silent --write-out "\n%{http_code}\n" $URL:$RUNSERVER_PORT)

# Parse output
status_code=$(echo "$response" | sed -n '$p')
html=$(echo "$response" | sed '$d')

sleep 1
# Kill runserver
kill -9 $!
killall -9 python 2>&1 || true

# Display output and return error if fail
case "$status_code" in
        200) echo -e "\033[32mRUNSERVER OK\033[0m"
             ;;
        *)   echo -e "\033[31mRUNSERVER FAIL\033[0m Status: $status_code"
             exit 1
             ;;
esac


# Launch UWSGI
echo "Starting uwsgi"
$ENV_DIR/bin/uwsgi --http :$PORT --wsgi-file=$PROJECT_DIR/wsgi.py --home=$ENV_DIR &

echo "Sleeping"
sleep 5

# Generate request
echo "Generating request"
response=$(curl --silent --write-out "\n%{http_code}\n" $URL:$PORT)

# Parse output
status_code=$(echo "$response" | sed -n '$p')
html=$(echo "$response" | sed '$d')

# Kill UWSGI
kill $!

# Display output and return error if fail
case "$status_code" in
        200) echo -e "\033[32mUWSGI SUCCESS\033[0m"
             ;;
        *)   echo -e "\033[31mUWSGI FAIL\033[0m Status: $status_code"
             exit 1
             ;;
esac
