import os
import sys



os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'erp_config.settings')
import django
django.setup()

from django.core.management import call_command
from django.db.migrations.loader import MigrationLoader
from io import StringIO

loader = MigrationLoader(None, ignore_no_migrations=True)
apps = loader.migrated_apps

# Pega as migrations em ordem
from django.db.migrations.graph import MigrationGraph
graph = loader.graph

with open('schema.sql', 'w', encoding='utf-8') as f:
    seen = set()
    for target in graph.leaf_nodes():
        for node in graph.forwards_plan(target):
            if node in seen:
                continue
            seen.add(node)
            app_label, migration_name = node
            out = StringIO()
            call_command('sqlmigrate', app_label, migration_name, stdout=out)
            sql = out.getvalue()
            if sql.strip():
                f.write(f"-- MIGRATION: {app_label} - {migration_name}\\n")
                f.write(sql)
                f.write("\\n\\n")

print("SQL extraído para schema.sql")
