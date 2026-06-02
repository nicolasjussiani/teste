#!/bin/bash
# Install dependencies
python3 -m pip install -r requirements.txt
# Run collectstatic
python3 manage.py collectstatic --noinput --clear
