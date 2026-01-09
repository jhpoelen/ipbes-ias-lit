#!/bin/bash
# 
# tracks zenodo query associated with known, versioned batlit content
#
# Usage: 
#  ./track-zenodo-associations.sh [Zenodo endpoint url] [Zenodo community]
#
# with 
#  Zenodo endpoint url being https://sandbox.zenodo.org (testing) or https://zenodo.org (production), and 
#  Zenodo community being the identifier of the Zenodo community (e.g., batlit) in which the deposits are located. 
#

set -x 

SCRIPT_DIR=$(dirname $0)
DATA_DIR="${SCRIPT_DIR}/../zenodo"

ZENODO_ENDPOINT_URL=${1:-https://zenodo.org/}
ZENODO_COMMUNITY=${2:-ipbes-ias}

preston track --data-dir "${DATA_DIR}" \
 --algo md5 \
 -f <(bash "${SCRIPT_DIR}/list-refs.sh" \
 | mlr --csv cut -f id \
 | tail -n+2 \
 | grep -oE '[0-9]+/items/[A-Z0-9]+$' \
 | tr '/' ':' \
 | sed 's+^+urn:lsid:zotero.org:groups:+g' \
 | xargs -I{} echo "${ZENODO_ENDPOINT_URL}/api/communities/${ZENODO_COMMUNITY}/records?q=%22{}%22&l=list&limit=1")

preston head --data-dir "${DATA_DIR}" --algo md5 \
 > "${DATA_DIR}/HEAD"
