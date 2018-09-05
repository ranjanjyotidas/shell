#!/bin/bash

# ./spaces.sh [file-path] [-f | --fix] [-h | --help]
function usage() {
	echo " USAGE : $0 [file-path] [-f | --fix] [-h | --help]"
	exit 1
}

if [ $# -eq 0 ]; then
	usage
fi


FIX=0  # 0 donot perform fix    1 perform fix


while [ $# -gt 0 ]
do
	case "$1" in
		-f|--fix )
			FIX=1
			echo inside fix
			shift
			;;
		-h|--help )
			usage
			echo inside help
			shift
			;;
		* )
			if [ -f "$1" ]; then
				FILE=$1
			
				shift
			else
				usage
			fi
			;;
        esac

if [ $FIX -eq 1 ] && [ -f "$FILE" ]; then
	echo "Fixing spaces and tabs at the begining ans end of lines"
	sed -i 's/[[:blank:]]\+$//' "$FILE"
	sed -i 's/^[[:blank:]]\+//' "$FILE"
	echo "DONE"
fi

#display space error graphically

if [ -f "$FILE" ]; then
        LINE=0
	REGEX_START="^[[:blank:]]+"
	REGEX_END="[[:blank:]]+$"
     
  while IFS= read -r line
  do 
	  let LINE++
	  #if there is no space issue in the line just print the line
	  echo "$line" | sed -e '/[[:blank:]]\+$/q9' -e '/^[[:blank:]]\+/q7' >/dev/null
          
	  if [ $? -eq 0 ]; then

		  printf %4s "$LINE:" >> temp.txt
		  echo "$line" >> temp.txt
		  continue
	  fi
          
	  #print line number
	  printf %4s "$LINE:" >> temp.txt

	  #print on the same line spaces/tabs as a red background at the begginging of the line
          if [[ "$line" =~ $REGEX_START ]]; then
		  MATCH=`echo "$BASH_REMATCH" | sed 's/\t/|__TAB__|/g'` 
		  echo -e -n "$(tput setab 1)$MATCH$(tput sgr 0)" >> temp.txt
		 # echo -e -n "\e[41m$MATCH\e[49m"  >> temp.txt
		  #echo "$MATCH" >> text.txt 
 
          fi

	  #print on the sane line part of line which is correct(after fixing spaces and tabs)
          echo -e -n "$line" | sed -e 's/^[[:blank:]]\+//' -e 's/[[:blank:]]\+$//' >>temp.txt

	  #print on the sam line spaces/tabs at the end of the line
	  if [[ "$line" =~ $REGEX_END ]]; then

                  MATCH=`echo "$BASH_REMATCH" | sed 's/\t/|__TAB__|/g'`
                  echo -e "$(tput setab 1)$MATCH$(tput sgr 0)" >> temp.txt
		  #echo -e  "\e[41m$MATCH\e[49m"  >> temp.txt
		  #echo "$MATCH" >> temp.txt

          else
		  echo >> temp.txt
          fi    

  done < "$FILE"

  cat temp.txt
  rm temp.txt
  #echo "$(tput setaf 1)Red text $(tput setab 7)and white background$(tput sgr 0)"

fi

done
