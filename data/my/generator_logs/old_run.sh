#!/bin/sh
start_html() {
cat <<END
<?xml version="1.0"?>
<file_events>
END
}

htmlizediff() {
	read -r s
	while [[ $? -eq 0 ]]; do
		# Get beginning of line to determine what type
		# of diff line it is.
		t1=${s:0:1}
		
		case $t1 in
			[012345789])
				datec=`echo $s | cut -f1 -d ':'`
				user=`echo $s | cut -f2 -d ':'`				
				;;
			'&')
				filename=`echo $s | cut -f2 -d '&'`
				;;
			['+''-'])
				ext="D"
				if [[ "$t1" == '+' ]]; then
					ext="A"
				fi
				
				str=`echo $s | sed -e "s/^[+-]//" | md5sum | cut -f1 -d ' '`
				# str=`C:/Perl/bin/perl.exe -e 'print crypt($ARGV[0], $ARGV[1])' "$str" "longcode0123"`
				
				# str=`echo $s | sed -e "s/^[+-]//"`
				# rest=""
				# for ((i = 0; i < ${#str}; i++)); do 
					# rest=$rest`printf '%x' "'$(expr substr "$str" $i 1)'";`
				# done
				# str=`echo $rest | sed -e "s/20/\/s/g"`
				
				echo -ne '<event date="'$datec'"  author="'$filename'"  filename="'${str:0:8}'/'${str:8:16}'/'${str:16:30}'.'${str:30:32}'" action="'$ext'"  comment=""/>\n'			
				;;
		esac
		
		read -r s
	done
	echo
}

end_html() {
cat <<END
</file_events>
END
}

prepare_git() {
	gitdiff=$fileaction".temp"
	
	git log -U0 --diff-filter=AMD --reverse --pretty="%at000:%cn" -$1 | \
		grep -v "^--- " | \
		grep -v "^+++ " | \
		grep -v "^index " | \
		grep -v "^Binary " | \
		grep -v "^@@ " | \
		grep -v "^[+-][ 	]*$" | \
		grep -v "^[+-]$" | \
		grep -v "^[ 	]*$" | \
		sed -e "s/diff .* b\//\&/g" \
			-e "s/^+[ 	]\+/+/g" \
			-e "s/^-[ 	]\+/-/g" \
			-e "s/[ 	]+$//g" \
			-e "s/\"//g" > $gitdiff
	exec 7<&0
	exec < $gitdiff
}

post_git() {
	exec 0<&7 7<&-
	rm $gitdiff
}

prepare_mail() {	 
	exec 6>&1
	exec > $fileaction"action.xml"
}

send_mail() {
	exec 1>&6 6>&-
}

fileaction="$(date +%j%H%M%s)"

[[ "$1" == "" ]] && countcommit=10 || countcommit=$1

prepare_mail
prepare_git $countcommit
generet
htmlizediff
end_html
post_git
send_mail
