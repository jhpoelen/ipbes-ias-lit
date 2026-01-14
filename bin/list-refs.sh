#!/bin/bash
#
# generates a list of references in most recent version of the bat literature corpus
#
#

set -x

SCRIPT_DIR=$(realpath $(dirname $0))
HEAD=$(cat "${SCRIPT_DIR}/../HEAD")

PRESTON_OPTS="--data-dir ${SCRIPT_DIR}/../data"

mlr --csv join -j id\
 -f\
 <(cat <(echo "id,authors,date,title,journal,type,volume,issue,pages,doi")\
 <(preston cat $PRESTON_OPTS ${HEAD}\
 | grep "items[?]"\
 | grep hasVersion\
 | preston cat ${PRESTON_OPTS}\
 | jq -c .[]\
 | jq --raw-output -c 'select(.data.creators != null) | [.links.self.href, (.data.creators | map(.lastName) | join(" | ")), ( .data.date, .data.title, .data.publicationTitle, .data.itemType, .data.volume, .data.issue, .data.pages, .data.DOI)] | @csv'\
 | sort)\
 | tr '\t' ' ')\
 <(cat <(echo "id,attachment,corpusId,attachmentId")\
 <(preston cat ${PRESTON_OPTS} ${HEAD}\
 | grep "items[?]"\
 | grep hasVersion\
 | preston cat ${PRESTON_OPTS}\
 | jq -c .[]\
 | jq --raw-output --arg HEAD "$HEAD" 'select(.data.md5 != null) | [.links.up.href, " ", $HEAD, " "] | @csv'\
 | sort))\
 | mlr --csv reorder -e -f corpusId,attachment,attachmentId\
 | mlr --csv uniq -a \
 | mlr --csv sort -t authors,date,title \
 | sed -E "s+^https://api.zotero.org/groups/+urn:lsid:zotero.org:groups:+g" \
 | sed -E "s+/items/+:items:+g"

