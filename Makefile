# Build SQL, graph

graph: sql/catares-Schema-latest-MySQL.sql
	sqlt-graph -c -f MySQL -o schema.png sql/catares-Schema-latest-MySQL.sql

sql/catares-Schema-latest-MySQL.sql: lib/catares/Schema/*.pm lib/catares/Schema.pm
	script/create_sql.pl
