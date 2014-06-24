#!/usr/bin/env bash

SED=sed

touch `dirname $0`/cancel.cache

#if [ $# -gt 0 ] && [ $1 == '-v' ] ; then VERBOSE=( exit 1 );else VERBOSE=( exit 0);fi

curl -s http://www.is.s.u-tokyo.ac.jp/no-lec.php | awk 'BEGIN{a=0;b=0}/<\/tbody>/&&b{exit}/<\/tbody>/{a=1}b&&/<\/?t/{print}/<tbody>/&&a{b=1}' | tr '\n' ' ' | $SED -e 's/[[:blank:]]//g' | perl -MEncode -pe 's/<tr><td>//g;s:</td><td>:,:g;s:</td></tr>:\n:g;Encode::from_to($_,"eucjp",utf8)' > `dirname $0`/tmp.csv

for key in $(cat `dirname $0`/search.list) ; do
    echo $key;#fi
    line=$(grep "$key" `dirname $0`/tmp.csv)
    for line2 in $line ; do
        if [ $(grep -c "$line2" `dirname $0`/cancel.cache) -eq 0 ] && [[ ! $line2 =~ ^$ ]]; then
	        echo "$line2" >> `dirname $0`/cancel.cache;
	        name=$(echo $line2 | awk -F "," '{print $3}' )
	        name2=$name"補講" 
	        place=$(echo $line2 |awk -F "," '{print $5 }' )
	        d=$(echo $line2 | awk -F "," '{print $1 }' )
	        class=${d#*)};
	        month=$(echo $d | sed -e 's:月.*$::g')
		if [[ ${#month} -lt 2 ]] ; then
			month2=0$month;
		else
			month2=$month;
		fi
	        date=$(echo $d | sed -e 's:日.*$::g;s:^.*月::g')
		stime=${class%-*};
		etime=${class#*-};
		if [[ ${#date} -lt 2 ]] ; then
			date2=0$date;
		else
			date2=$date;
		fi
	        if [ $month -ge `date +"%m"` ] ; then 
	            Year=`date +"%Y"`;
	        else
	            Year=$((`date +"%Y"` + 1));
	        fi
	        if [ $month -ge `date +"%m"` ] ; then 
	            year=`date +"%y"`;
	        else
	            year=$((`date +"%y"` + 1));
	        fi
	        #echo $year$month2$date2 $name >> ~/sendcancel/sendschedule;
		ruby `dirname $0`/add_schedule.rb $name2 $place $Year $month $date ${stime%:*} ${stime#*:} ${etime%:*} ${etime#*:}
        fi
    done
done
