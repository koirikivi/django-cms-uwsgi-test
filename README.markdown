Quick and ugly uwsgi test scaffold for django-cms

Usage
=====

    $ virtualenv venv
    $ venv/bin/pip install -r requirements.txt
    $ git clone <django-cms-repo-url>
    $ ln -s django-cms/cms cms
    $ ln -s django-cms/menus menus
    $ ./test_uwsgi.sh

(Vagrantfile provided for easier environment setup for Mac / Windows devs -- totally optional)

git bisect in repo
==================

    $ cd django-cms
    $ git bisect start
    $ git bisect good <some old commit that is not broken>
    $ git bisect bad <a newer, broken commit>
    $ git bisect run ../test_uwsgi.sh
