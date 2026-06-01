#!/bin/bash
# Install dependencies
python3.9 -m pip install -r requirements.txt
# Run collectstatic
python3.9 manage.py collectstatic --noinput --clear
