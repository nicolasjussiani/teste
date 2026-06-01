#!/bin/bash
# Install dependencies
python -m pip install -r requirements.txt
# Run collectstatic
python manage.py collectstatic --noinput --clear
