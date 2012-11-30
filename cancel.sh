#!/bin/sh

touch cancel.cache

rm index.html

wget http://www.c.u-tokyo.ac.jp/zenki/classes/cancel/index.html

grep '</\?t.*' index.html | tr '\n\t' ' '|sed -e 's:/tr>:/tr>\n:g'| sed -e 's/<[^>]*>/,/g' | sed -e 's/[[:blank:]]*//g'|sed -e 's/,,*/,/g'|sed -e 's/^,//g;s/,$//g' >tmp.html

awk -F "," '{
if( NF == 4)
{
$7=$4;
$6=$3;
$5 = $2;
$4 = $1;
$3 = L3;
$2 = L2;
$1 = L1;
}
else
{
L3 = $3;
L2 = $2;
L1 = $1;
}
print;
}' tmp.html |sed -e 's/ /,/g' > tmp
mv  tmp tmp.html

for key in $(cat search.list) ; do
    line=$(grep "$key" tmp.html)
    if [ $(grep -c "$line" cancel.cache) -eq 0 ] && [[ ! $line =~ ^$ ]]; then
	echo "$line" >> cancel.cache;
	name=$(echo $line | awk -F "," '{print $4 "休講" }' )
	place=$(echo $line |awk -F "," '{print $6 }' )
	d=$(echo $line | awk -F "," '{print $1 }' )
	class=$(echo $line | awk -F "," '{print $3 }' )
	month=$(echo $d | sed -e 's:月.*$::g')
	date=$(echo $d | sed -e 's:日.*$::g' |sed -e 's:^.*月::g')
	if [ $month > 4 ] ; then 
	    year=2012;
	else
	    year=2013;
	fi
	#ruby add_schedule.rb 
	echo $name $place $year $month $day $class
    fi
done