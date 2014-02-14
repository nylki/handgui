#!/bin/bash

#get my working dir:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

array=( $@ )
len=${#array[@]}
_path=${array[$len-1]}
_keywords=${array[@]:0:$len-1}

echo pfad: $_path
echo keywords: $_keywords 

$DIR/exiv2 -M "add Xmp.dc.subject XmpBag $_keywords" $_path
#echo ./exiv2 -M "add Xmp.dc.subject XmpBag $_keywords" $_path