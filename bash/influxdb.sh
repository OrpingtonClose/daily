#https://learning.oreilly.com/library/view/seven-nosql-databases/9781787288867/b6ab5d3a-a473-493a-a4a2-b9af44d02261.xhtml
#https://docs.influxdata.com/influxdb/v1.7/tools/shell/#import-data-from-a-file-with-import
#https://docs.influxdata.com/influxdb/v1.7/supported_protocols/graphite/

curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update
sudo apt-get install influxdb
sudo systemctl unmask influxdb.service
sudo systemctl start influxdb

influxd config
influx -execute 'show databases' -precision rfc3339 
influx
use _internal

show measurements

# name
# ----
# cq
# database
# httpd
# queryExecutor
# runtime
# shard
# subscriber
# tsm1_cache
# tsm1_engine
# tsm1_filestore
# tsm1_wal
# write

SELECT HeapAlloc, HeapIdle, HeapInUse, NumGC, Mallocs, TotalAlloc from runtime limit 3;
SELECT * from runtime limit 3;

create database market;
use market;
insert tickers,ticker=JPM company="JPMorgan Chase & Co",close=98.68,high=98.7,low=98.68,open=98.7,volume=4358 151179804
insert tickers,ticker=JPM company="JPMorgan Chase & Co",close=98.71,high=98.7,low=98.68,open=98.68,volume=1064 151179810
insert tickers,ticker=JJPM company="JPMorgan Chase & Co",volume=1064 151179810
insert tickers,ticker=JJPM company="JPMorgan Chase & Co" 151179810
insert tickers,ticker=JJPM company="JPMorgan Chase & Co",volume=1064 151179810
insert odd,desc=something="yes" 151179810
insert odd,wat=everything="yes"

select * from tickers;
SELECT * FROM /.*/ LIMIT 1

curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"

curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'

curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu_load_short,host=server02 value=0.67
cpu_load_short,host=server02,region=us-west value=0.55 1422568543702900257
cpu_load_short,direction=in,host=server01,region=us-west value=2.0 1422568543702900257'

cat > ticker.data <<EOF
cpu_load_short,host=server02 value=0.67
cpu_load_short,host=server02,region=us-west value=0.55 1422568543702900257
cpu_load_short,direction=in,host=server01,region=us-west value=2.0 1422568543702900257
EOF

curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary @ticker.data

curl -XPOST http://localhost:8086/query?db=mydb --data-urlencode "q=select * from cpu_load_short" | jq '.'

cat > datarrr.txt <<EOF
# DDL
CREATE DATABASE pirates
CREATE RETENTION POLICY oneday ON pirates DURATION 1d REPLICATION 1

# DML
# CONTEXT-DATABASE: pirates
# CONTEXT-RETENTION-POLICY: oneday

treasures,captain_id=dread_pirate_roberts value=801 $(sleep 0.01;date +%s)
treasures,captain_id=flint value=29 $(sleep 0.01;date +%s)
treasures,captain_id=sparrow value=38 $(sleep 0.01;date +%s)
treasures,captain_id=tetra value=47 $(sleep 0.01;date +%s)
treasures,captain_id=crunch value=109 $(sleep 0.01;date +%s)
EOF

influx -import -precision=s -path=datarrr.txt

bash
exec > insertions.data
echo '# DML
# CONTEXT-DATABASE: pirates
# CONTEXT-RETENTION-POLICY: oneday
'
cat /usr/share/dict/words | grep -v "'" | xargs -n 1 -I {} echo "treasures,captain_id={} value=55 $(date +%s)"
exit

influx -import -precision=s -path=insertions.data

influx
use pirates;
show measurements;

select * from treasures;
show queries;

curl -XPOST http://localhost:8086/query?db=mydb --data-urlencode "q=select * from cpu_load_short" | jq '.'