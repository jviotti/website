#!/bin/sh

set -o errexit
set -o nounset

if [ $# -lt 1 ]
then
  echo "Usage: $0 <articles...>" 1>&2
  exit 1
fi

extract() {
  grep "^$2: " < "$1" | head -n 1 | sed "s/$2: //g"
}

assert() {
  if [ -z "$1" ]
  then
    echo "(ERROR) $2" 1>&2
    exit 1
  fi
}

parse_date() {
  date -jf "%B %d, %Y" "$1" "+%a, %d %b %Y %H:%M:%S %z"
}

echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">'
echo '  <channel>'
echo '    <title>Juan Cruz Viotti</title>'
echo '    <description>Personal blog</description>'
echo '    <language>en-us</language>'
echo '    <category>Technology</category>'
echo '    <link>https://www.jviotti.com</link>'
echo '    <image>'
echo '      <url>https://www.jviotti.com/me.jpg</url>'
echo '      <title>A picture of Juan Cruz Viotti</title>'
echo '    </image>'
echo '    <atom:link href="https://www.jviotti.com/feed.xml" rel="self" type="application/rss+xml" />'

CURRENT_DATE="$(date -R)"
echo "    <lastBuildDate>$CURRENT_DATE</lastBuildDate>"
echo "    <pubDate>$CURRENT_DATE</pubDate>"

for entry in "$@"
do
  NAME="$(basename "$entry" .html)"
  DAY="$(basename "$(dirname "$entry")")"
  MONTH="$(basename "$(dirname "$(dirname "$entry")")")"
  YEAR="$(basename "$(dirname "$(dirname "$(dirname "$entry")")")")"
  ORIGINAL="articles/$YEAR-$MONTH-$DAY-$NAME.markdown"
  TITLE="$(extract "$ORIGINAL" title)"
  DESCRIPTION="$(extract "$ORIGINAL" description)"
  DATE="$(extract "$ORIGINAL" date)"
  URL="https://www.jviotti.com/$YEAR/$MONTH/$DAY/$NAME.html"

  assert "$TITLE" "Missing title: $entry"
  assert "$DESCRIPTION" "Missing description: $entry"
  assert "$DATE" "Missing date: $entry"

  echo '    <item>'
  echo "      <title>$TITLE</title>"
  echo "      <description>$DESCRIPTION</description>"
  echo "      <pubDate>$(parse_date "$DATE")</pubDate>"
  echo "      <link>$URL</link>"
  echo "      <guid isPermaLink=\"true\">$URL</guid>"
  echo '    </item>'
done

echo '  </channel>'
echo '</rss>'
