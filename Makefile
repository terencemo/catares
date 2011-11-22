# Build SQL, graph

graph: sql/catares-Schema-0.001-MySQL.sql
	sqlt-graph -c -f MySQL -o schema.png sql/catares-Schema-0.001-MySQL.sql

sql/catares-Schema-0.001-MySQL.sql: lib/catares/Schema/*.pm lib/catares/Schema.pm
	rm sql/catares-Schema-0.001-*.sql || echo No sql files
	script/create_sql.pl
