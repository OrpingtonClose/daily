echo 'herp merp secret file' > f1

N=10
openssl sha256 -binary -out temp1 <(echo 'hello')
for n in `seq $N`; do openssl sha256 -binary -out temp$(($n+1)) temp$n; done
openssl aes-256-cbc -k "$(cat temp$(($N+1)))" -in f1 -out f2
cat f2
rm temp*

N=10
openssl sha256 -binary -out temp1 <(echo 'hello')
for n in `seq $N`; do openssl sha256 -binary -out temp$(($n+1)) temp$n; done
openssl aes-256-cbc -k "$(cat temp$(($N+1)))" -d -in f2
rm temp*

