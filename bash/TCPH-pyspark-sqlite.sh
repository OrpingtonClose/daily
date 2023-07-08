git clone --recursive https://github.com/lovasoa/TPCH-sqlite.git
cd TPCH-sqlite
make

#https://mvnrepository.com/artifact/org.xerial/sqlite-jdbc/3.42.0.0
#pyspark --conf spark.executor.extraClassPath=/home/orpington/Downloads/sqlite-jdbc-3.42.0.0.jar --driver-class-path /home/orpington/Downloads/sqlite-jdbc-3.42.0.0.jar --jars /home/orpington/Downloads/sqlite-jdbc-3.42.0.0.jar

wget https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/3.42.0.0/sqlite-jdbc-3.42.0.0.jar

cat > mypythonfile.py <<EOL
from pyspark.sql import SparkSession
spark = SparkSession.builder.getOrCreate()
df = spark.read.format('jdbc').options(driver='org.sqlite.JDBC', dbtable='CUSTOMER', url='jdbc:sqlite:TPC-H.db').load()
df.write.csv("herp.csv")
EOL

spark-submit --conf spark.executor.extraClassPath=sqlite-jdbc-3.42.0.0.jar --driver-class-path sqlite-jdbc-3.42.0.0.jar --jars sqlite-jdbc-3.42.0.0.jar mypythonfile.py

head herp.csv/part-00000-8aaf01bd-bcad-4fc3-9c23-dff01b241f10-c000.csv


