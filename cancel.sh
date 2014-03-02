#!/bin/bash

SED=sed

touch `dirname $0`/cancel.cache

#if [ $# -gt 0 ] && [ $1 == '-v' ] ; then VERBOSE=( exit 1 );else VERBOSE=( exit 0);fi

curl -s http://www.c.u-tokyo.ac.jp/zenki/classes/cancel/index.html | grep '</\?t[rd].*' | tr -d ',\t\n' | $SED -e 's:/tr>:/tr>\n:g'| $SED -e 's/<[^>]*>/,/g' | $SED -e 's/[[:blank:]]//g;s/,,*/,/g'| $SED -e 's/^,//g;s/,$//g' | awk -F "," '{
if( NF == 4) for ( t = 3 ; t >=1 ; t-- ) { $(t+3)=$t; $t = L[t];}
else for ( t = 3 ; t >=1 ; t-- ) L[t]=$t;
print;
}' | awk -v verbose=$VERBOSE -v keyfile=`dirname $0`/search.list -v cachefile=`dirname $0`/cancel.cache -v m=`date +"%m"` -v y=`date +"%Y"` '
BEGIN {
	numOfCache=0;
	while ( (getline var < cachefile) > 0) {
               cache[numOfCache++] = var
        }
        close(cachefile)

	numOfKeys=0;
	while ( (getline var < keyfile) > 0) {
               keys[numOfKeys++] = var
        }
        close(keyfile)
}

function matchOr ( key , array, num) {
	for ( t = 0; t < num ; t++)  {
		if ( key ~ array[t] ) {
			return 1;
		}
	}
	return 0;
}

NF > 0 && matchOr( $0 , keys , numOfKeys){
	if ( verbose ) 
		print;
	if ( system("[ $(grep -c \"" $0 "\" `dirname $0`/cancel.cache) -gt 0 ] " ) ){
		print >> cachefile;
	        name = $4 "休講";
	        place = $6;
	        class = $3;
	        month = $1;
		sub(/月.*$/,"",month)
	        date = $1;
		sub(/日.*$/,"",date)
		sub(/^.*月/,"",date)
	        if ( month >= m ) 
	            year = y
	        else
	            year = y+1
#	        system("ruby `dirname $0`/add_schedule.rb" name " " place " " year " " month " " date " " class)
	        if (verbose) 
			print name " " place " " year " " month " " date " " class;
	}
}' 

