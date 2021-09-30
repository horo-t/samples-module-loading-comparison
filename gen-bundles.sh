#!/bin/sh

set -e

DIRNAME="dist/three/unbundled"
WBNDIR="wbn/"
OUTHAR="dist/three/three_js.har"
OUTWBN="dist/three/three_js.wbn"
OUTWBNJS="dist/three/three_js_wbn.js"

files=(`find $DIRNAME -type f | xargs`)

to_har_item () {
  URL=$1
  CONTENT=`base64 $2 -w 0`
  TYPE=$3
  ITEM=`cat <<EOM
      {
        "request": {
          "method": "GET",
          "url": "$URL",
          "headers": []
        },
        "response": {
          "status": 200,
          "headers": [
            {
              "name": "Content-type",
              "value": "$TYPE"
            }
          ],
          "content": {
            "text": "$CONTENT",
            "encoding": "base64"
          }
        }
      }
EOM`
    echo -e "$ITEM"
}

to_js_har_item () {
  RESULT=`to_har_item $1 $2 "text/javascript"`
  echo -e "$RESULT"
}

echo -e "{\n  \"log\": {\n    \"entries\": [" > $OUTHAR

for ((i = 0; i < ${#files[@]}; i++))
do
  file="${files[$i]}"
  wbnpath="$WBNDIR${file:${#DIRNAME}+1}"
  if test $i -ne 0 ; then
    echo -e ",\n" >> $OUTHAR
  fi
  echo -e "`to_js_har_item "$wbnpath" "$file"`" >> $OUTHAR
done

echo "]}}" >> $OUTHAR



gen-bundle   -version b2   -har $OUTHAR   -o $OUTWBN

cp $OUTWBN $OUTWBNJS