#!/usr/bin/env bash

printf "Checking latest version\n"

__dir="$(dirname "${BASH_SOURCE[0]}")"

LATEST_VERSION=$(gh release list --repo Gustash/Hyprshot --json name,tagName,isLatest --jq '.[] | select(.isLatest)|.tagName' | grep -oE '[0-9]\.([0-9\.]+[a-z]*)+' )
export VERSION=${LATEST_VERSION#"v"}
CURRENT_VERSION=$(grep -E '^version=' ${__dir}/template | cut -d= -f2)

printf "Latest version is: %s\nLatest built version is: %s\n" "${VERSION}" "${CURRENT_VERSION}"
[ "${CURRENT_VERSION}" = "${VERSION}" ] && printf "No new version to release\n" && exit 0

# No preprepped checksum files, need to download the tarball and calculate it myself
gh release download -R Gustash/Hyprshot -p "Hyprshot-${VERSION}.tar.gz" --output "Hyprshot-${VERSION}.tar.gz"
export SHA256=$(sha256sum ./Hyprshot-${VERSION}.tar.gz | cut -d ' ' -f1 )
rm ./Hyprshot-${VERSION}.tar.gz
[[ ! ${SHA256} =~ ^[a-z0-9]+$ ]] && printf "got junk instead of sha256\n" && exit 1

envsubst '${SHA256} ${VERSION}' < ${__dir}/.template > ${__dir}/template

printf "Hyprshot template updated\n"

