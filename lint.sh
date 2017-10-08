#!/bin/sh

MHFILES=$(find . -name '*.[mh]' | grep -Ev '(Geocube/contrib|GeocubeTests|Pods|ContribLibrary)')
MFILES=$(find . -name '*.m' | grep -Ev '(Geocube/contrib|GeocubeTests|Pods|ContribLibrary)')
HFILES=$(find . -name '*.h' | grep -Ev '(Geocube/contrib|GeocubeTests|Pods|ContribLibrary)')
DBFILES=DatabaseLibrary/DatabaseLibrary/db*.m

echo
echo "Licenses:"
grep -c GNU $MHFILES | grep -v PSPDFUIKitMainThreadGuard.m | grep -v 3$ | sed -e 's/:.*$//'

echo
echo "DB_PREPARE / DB_FINISH:"
for fn in ${DBFILES}; do
	p=$(grep -c DB_PREPARE $fn)
	f=$(grep -c DB_FINISH $fn)
	if [ "$p" != "$f" ]; then
		echo $fn - $p / $f
	fi
done

echo
echo "Untranslated strings:"
grep -h "_(" $MFILES | perl findMissingLocalizations.pl

echo
echo "HelpDatabaseViewController:"
for class in $(grep implementation $DBFILES | awk '{ print $2 }' | grep -v dbObject); do
	if [ $(grep -c "$class dbCount" Geocube/Developer/DeveloperDatabaseViewController.m) == 0 ]; then
		echo "Not found: $class"
	fi
done

echo
echo "db*.m - TABLENAME:"
for f in $BDFILES; do
	c=$(grep -wc "TABLENAME" $f)
	if [ $c != 1 ]; then
		echo "Missing TABLENAME: $f"
	fi
done

echo
echo "db*.m - order:"
for f in $DBFILES; do
	for word in init finish dbCount dbCreate dbUpdate dbAll dbGet dbDelete; do
		true
	done
done

echo
echo "Classes:"
grep -h @implementation $MFILES | sed -e 's/implementation/class/' -e 's/$/;/'| sort > /tmp/b
grep @class Geocube/Geocube-Classes.h > /tmp/a
diff /tmp/[ab]

echo
echo "Copyright:"
grep -c "Copyright .*$(date +%Y)" $MFILES | sed -e 's/:/ /' | grep -v " 1$"

echo
echo "Tabs:"
grep -n "[	]$" $MHFILES

echo
echo "Spaces at the end:"
grep -n "[	 ]$" $MHFILES

echo
echo "Spaces before ]:"
grep -n "[^ ] ]" $MFILES

echo
echo "Empty lines at the end:"
for i in $MHFILES; do if [ -z "$(tail -1 $i)" ]; then echo $i; fi; done

echo
echo "No space between parent class and delegates:"
grep "@interface.*\w<" $HFILES

echo
echo "Subclassing space-colon-space:"
grep @interface $HFILES | grep -v "\w\s:\s\w"

echo
echo "No { after @interface:"
grep @interface $MHFILES | grep \{

echo
echo "Method definitions should have the { on the next line:"
grep "^[-+].*{\s*$" $MFILES

echo
echo "Method definitions should have a space between [-+] and name:"
grep "^[-+]\S" $MFILES

echo
echo "enumeration:"
grep -n enumerate $MFILES | grep -v _Nonnull.*_Nonnull | grep -v "(id " | grep ":^"

echo
echo "Make sure that NSArray knows which class it represent:"
grep 'NSArray ' $HFILES
grep 'NSMutableArray ' $HFILES
grep -n "^[-+].*NSArray " $MFILES
grep -n "^[-+].*NSMutableArray " $MFILES
grep -n " NSMutableArray " $MFILES
grep -n " NSArray " $MFILES

echo
echo "Empty lines after beginning of a method:"
grep -n -A 1 ^{ $MFILES | grep -v '^--$' | grep -- '-[	 ]*$'

echo
echo "Empty lines before the end of a method:"
grep -n -B 1 ^} $MFILES | grep -v '^--$' | grep -- '-[	 ]*$'

echo
echo "Double empty lines:"
for i in $MHFILES; do perl -e '$f=$ARGV[0];@a=<>;chomp(@a);$i=-1;$c=0;foreach $l (@a) { $c++; if ($l eq "") { print "$f:$c\n" if ($i==$c-1); $i=$c; }}' $i; done

echo
echo "Double ;;'s:"
grep ";;" $MHFILES

echo
echo "ConfigManager:"
./checkConfigManager.pl ManagersLibrary/ManagersLibrary/ConfigManager

echo
echo "XIB for iPhone/iPad"
a=$(find . -name '*.xib' | grep -v ~ipad)
for f in $a; do
	if [ ! -f $(echo $f | sed -e 's/.xib/~ipad.xib/') ]; then
		echo "iPad XIB not found for $f"
	fi
done
a=$(find . -name '*.xib' | grep ~ipad)
for f in $a; do
	if [ ! -f $(echo $f | sed -e 's/~ipad.xib/.xib/') ]; then
		echo "iPhone XIB not found for $f"
	fi
done

echo
echo "Missing interface()"
for i in $(grep '@class' Geocube/Geocube-Classes.h | awk '{ print $2 }' | sed -e 's/;$//'); do
	if [ -z "$(grep @interface\ $i\  $HFILES)" ]; then
		echo "Missing @interface for $i in .h"
	fi
	if [ -z "$(grep @interface\ $i\  $MFILES)" ]; then
		echo "Missing @interface for $i in .m"
	fi
	if [ -z "$(grep @implementation\ $i\$ $MFILES)" ]; then
		echo "Missing @implementation for $i in .m"
	fi
done

echo
