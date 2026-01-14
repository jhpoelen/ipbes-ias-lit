#!/bin/bash
#
# generates a list of references in most recent version of the bat literature corpus
#
#

set -x

SCRIPT_DIR=$(realpath $(dirname $0))
HEAD=$(cat "${SCRIPT_DIR}/../zenodo/HEAD")

PRESTON_OPTS="--data-dir ${SCRIPT_DIR}/../zenodo"

cat <(echo "id,authors,date,title,journal,type,volume,issue,pages,doi,alternateDoi")\
 <(preston cat $PRESTON_OPTS ${HEAD}\
 | grep "records[?]q="\
 | grep hasVersion\
 | preston cat ${PRESTON_OPTS}\
 | jq -c .hits.hits[]\
 | jq --raw-output -c 'select(.metadata.creators != null) | [ (.metadata.alternate_identifiers[].identifier | select(test("urn.*"))), (.metadata.creators | map(.name) | join(" | ")), ( .metadata.publication_date, .metadata.title, .metadata.journal.title, .metadata.itemType, .metadata.journal.volume, .metadata.journal.issue, .metadata.journal.pages, .doi, (.metadata.alternate_identifiers[].identifier | select(test("10.*"))))] | @csv')
