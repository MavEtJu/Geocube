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
grep @class Geocube-Classes.h | sort > /tmp/b
diff /tmp/[ab]

echo 
