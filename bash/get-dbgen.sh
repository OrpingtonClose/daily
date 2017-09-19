# http://www.sqlservercentral.com/blogs/sqlservernotesfromthefield/2012/01/24/generate-test-data-using-dbgen/
git clone https://github.com/electrum/tpch-dbgen.git
cd tpch-dbgen
make
./dbgen
mkdir ~/dbgen-data
mv *.tbl ~/dbgen-data
