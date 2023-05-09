rm unfollow.txt 2> /dev/null
t followings -l > t.txt
export OPENAI_API_KEY="..."

t_timeline () { t timeline --decode-uris --long --number=100 --relative-dates $U ; }

for NUM in {120..130}
do
  U=$(cat t.txt | awk '{print $13}' | grep '^@' | sed "${NUM}q;d") 
  t whois $U
  while true
  do
  echo 'more(m) open(o) unfollow(u) ai(a) chart(c) next(none)?'
  read C
  rm temp.txt 2> /dev/null
  case $C in
    m) if [ ! -e $PWD/temp.txt ] ; then t_timeline | sort > temp.txt; fi  
       cat temp.txt ;;
    a) if [ ! -e $PWD/temp.txt ] ; then t_timeline | sort > temp.txt; fi
       cat temp.txt | chatgpt "summarize the above" ;;
    c) if [ ! -e $PWD/temp.txt ] ; then t_timeline | sort > temp.txt; fi
       cat temp.txt | awk '{print "\"" $2 " " $3 " " $4 "\""}' | uniq -c > charts.txt
    gnuplot <<- EOF
        set title "tweet frequency"   
        set term png
        set boxwidth 0.5
        set style fill solid;
        set bmargin 8;  
        set xtics rotate by 90 offset -0.8,-5.0
        set output "charts.png"
        plot "charts.txt" using 1:xtic(2) with boxes
EOF
    xdg-open charts.png ;;
    o) t open $U;;
    u) echo $U >> unfollow.txt
       break ;;
    *) break ;;
  esac
  done
done
cat unfollow.txt | xargs t unfollow
