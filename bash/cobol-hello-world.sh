sudo apt-get install open-cobol -y
cat << EOF > helloworld.cbl
IDENTIFICATION DIVISION.
PROGRAM-ID. HELLO-WORLD.
*> simple hello world program
PROCEDURE DIVISION.
       DISPLAY 'Hello world!'.
       STOP RUN.
EOF
cobc -free -x -o helloworld helloworld.cbl
./helloworld
