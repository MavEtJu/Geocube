#!/bin/sh

LS="nl.lproj Settings.bundle/en.lproj"

for L in ${LS}; do
	printf "\xff\xfe" > $L/Localizable.strings
	echo "/* THIS IS A GENERATED FILE, DO NOT EDIT */" | iconv -f ASCII -t UTF-16LE >> $L/Localizable.strings
	for F in $L/Localizable-*.strings; do
		tail -c +3 $F >> $L/Localizable.strings
	done
done

exit 1
