#!/bin/sh
fileaction="$(date +%j%H%M%s)"
gitdiff=$fileaction".temp"

git log -U0 --diff-filter=AMD --reverse --pretty="%at000:%cn" $1 | \
	grep -v "^\(-\{3\}\|+\{3\}\) " | \
	grep -v "^[+-][ \\t]*$" | \
	grep -v "^[+-]$" | \
	grep -v "^[ \\t]*$" | \
	sed -e "s/diff .* b\//\&/g" \
		-e "s/^+[ \\t]\+/+/g" \
		-e "s/^-[ \\t]\+/-/g" \
		-e "s/[ \\t]\+$//g" \
		-e "s/^$//g" \
		-e 's/\\/\\\\/g' \
		-e "s/[\"\`<>$]//g" > $gitdiff

allline=`sed -n $= $gitdiff`

curline=1
echo '<?xml version="1.0"?><file_events>'
while read s
do
	case ${s:0:1} in
		[0-9])
			datec=${s%:*}
			user=${s#*:}
			;;
		'&')
			filename=${s#*&}
			;;
		['+''-'])
			ext="D"
			if [[ "${s:0:1}" == '+' ]]; then
				ext="A"
			fi
			str=${s#*[+-]}

			# str=`echo $s | sed -e "s/^[+-]//" | md5sum | cut -f1 -d ' '`
			# str=`C:/Perl/bin/perl.exe -e 'print crypt($ARGV[0], $ARGV[1])' "$str" "longcode0123"`

			rest=""
			for ((i = 0; i < ${#str}; i++)); do
				rest=$rest`printf '%x' "'${str:$i:1}'";`
			done
			str=`echo $rest | sed -e "s/20/\/sd/g;s/\(..\)$/.\1/"`

			echo -ne '<event date="'$datec'"  author="'$filename'"  filename="'$str'" action="'$ext'"  comment=""/>\n'
			;;
	esac
	echo -ne "\r\t\t\t\r"$(( curline++ ))"/$allline" >&2
done < $gitdiff

echo "</file_events>"
rm $gitdiff
