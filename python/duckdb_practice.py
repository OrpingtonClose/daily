#https://duckdb.org/docs/guides/python/execute_sql

import duckdb
import time
duckdb.sql("SELECT 42").show()
results = duckdb.sql("SELECT 42").fetchall()
print(results)
# [(42,)]

results = duckdb.sql("SELECT 42").df()
print(results)

con = duckdb.connect('file.db')
con.sql('CREATE TABLE integers(i INTEGER)')
[con.sql('INSERT INTO integers VALUES (' + str(i) + ')') for i in range(10000)]
con.sql('SELECT sum(i) FROM integers').show()

c = lambda s: con.sql(s)
for _ in range(10):
    c("insert into integers select * from integers")
    start_time_Guru99 = time.time()
    print(c('SELECT sum(i), count(*) FROM integers').show())
    end_time_Guru99 = time.time()
    print("query: ", end_time_Guru99 - start_time_Guru99)

c("COPY (select * from integers) TO 'INTEGERS.csv' (HEADER, DELIMITER ',');")
