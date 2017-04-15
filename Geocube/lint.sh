#!/bin/sh

echo "Licenses:"
grep -c GNU $(ls -1 *.[mh] | grep -v PSPDFUIKitMainThreadGuard.m) | grep -v 3$

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
echo "Copyright:"
grep -c "2015, 2016, 2017" $(ls -1 *.m | grep -v PSPDFUIKitMainThreadGuard.m) | sed -e 's/:/ /' | grep -v " 1$"

echo
echo "Spaces at the end:"
grep -n "[	 ]$" *.m *.h

echo
echo "Spaces before ]:"
grep -n "[^ ] ]" *.m

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
echo "Missing interface()"
for i in $(grep '@class' Geocube-Classes.h | awk '{ print $2 }' | sed -e 's/;$//'); do
	if [ -z "$(grep @interface\ $i\  *.h)" ]; then
		echo "Missing @interface for $i in .h"
	fi
	if [ -z "$(grep @interface\ $i\  *.m)" ]; then
		echo "Missing @interface for $i in .m"
	fi
	if [ -z "$(grep @implementation\ $i\$ *.m)" ]; then
		echo "Missing @implementation for $i in .m"
	fi
done

echo
echo "No { after @interface:"
grep @interface *.[mh] | grep \{

echo
echo "Method definitions should have the { on the next line:"
grep "^[-+].*{\s*$" *.m

echo
echo "Method definitions should have a space between [-+] and name:"
grep "^[-+]\S" *.m

echo
echo "Make sure that NSArray knows which class it represent:"
grep 'NSArray ' $(ls -1 *.h | grep -v GCArray.h)
grep 'NSMutableArray ' $(ls -1 *.h | grep -v GCArray.h)
grep -n "^[-+].*NSArray " $(ls -1 *.m | grep -v GCArray.m)
grep -n "^[-+].*NSMutableArray " $(ls -1 *.m | grep -v GCArray.m)
grep -n " NSMutableArray " $(ls -1 *.m | grep -v GCArray.m)
grep -n " NSArray " $(ls -1 *.m | grep -v GCArray.m)


echo
echo "Empty lines after beginning of a function:"
grep -n -A 1 ^{ *.m  | grep -v '^--$' | grep -- -$

echo
echo "Double ;;'s:"
grep ";;" *.m *.h

echo
echo "ConfigManager:"
a=$(grep -c 'CHECK.@' ConfigManager.m)
b=$(grep -c 'self .*Update:.*value:value' ConfigManager.m)
c=$(grep -c 'dbConfig dbGetByKey:@"' ConfigManager.m)
if [ $a -ne $b -o $b -ne $c ]; then
	echo "CHECK: $a"
	echo "dbConfig dbGetByKey: $c"
	echo "self .*Update:.*value:value: $b"
fi
for w in $(grep 'CHECK.@' ConfigManager.m | sed -e 's/",.*//' -e 's/.*"//'); do
	if [ $(grep -cw $w ConfigManager.m) -ne 3 ]; then
		echo "Incomplete: $w"
	fi
done


echo
