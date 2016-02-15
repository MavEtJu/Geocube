#!/bin/sh

echo "Licenses:"
grep -c GNU *.[mh]  | grep -v 3$

echo
echo "DB_PREPARE / DB_FINISH:"
for fn in db*.m; do
	p=$(grep -c DB_PREPARE $fn)
	f=$(grep -c DB_FINISH $fn)
	if [ "$p" != "$f" ]; then
		echo $fn - $p / $f
	fi
done

echo
echo "Classes:"
grep -h @implementation *.m | sed -e 's/implementation/class/' -e 's/$/;/'| sort > /tmp/a
grep @class Geocube-Classes.h > /tmp/b
diff /tmp/[ab]

echo
echo "Spaces at the end:"
grep -n "[	 ]$" *.m *.h

echo
echo "Empty lines at the end:"
for i in *.m *.h; do if [ -z "$(tail -1 $i)" ]; then echo $i; fi; done

echo
echo "No space between parent class and delegates:"
grep "@interface.*\w<" *.h 

echo
echo "Subclassing space-colon-space:"
grep @interface *.h | grep -v "\w\s:\s\w"

echo
echo "No { after @interface:"
grep @interface *.[mh] | grep \{

echo
echo "MyConfig:"
a=$(grep -c 'CHECK.@' MyConfig.m)
b=$(grep -c 'self .*Update:.*value:value' MyConfig.m)
c=$(grep -c 'dbConfig dbGetByKey:@"' MyConfig.m)
if [ $a -ne $b -o $b -ne $c ]; then
	echo "CHECK: $a"
	echo "dbConfig dbGetByKey: $c"
	echo "self .*Update:.*value:value: $b"
fi
for w in $(grep 'CHECK.@' MyConfig.m | sed -e 's/",.*//' -e 's/.*"//'); do
	if [ $(grep -cw $w MyConfig.m) -ne 3 ]; then
		echo "Incomplete: $w"
	fi
done


echo
