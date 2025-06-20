#!/usr/bin/env bash

printf "Checking latest version\n"

__dir="$(dirname "${BASH_SOURCE[0]}")"

REPO="lbonn/rofi"
LATEST_VERSION=$(gh release list --repo "$REPO" --limit 100 --json tagName \
    --jq '[.[].tagName | select(contains("+wayland"))] | sort_by(split("+")[0] | split(".") | map(tonumber)) | last')
export VERSION="${LATEST_VERSION}"
CURRENT_VERSION=$(grep -E '^version=' "${__dir}/template" | cut -d= -f2)
printf "Latest version is: %s\nLatest built version is: %s\n" "${VERSION}" "${CURRENT_VERSION}"
[ "${CURRENT_VERSION}" = "${VERSION}" ] && printf "No new version to release\n" && exit 0

# No preprepped checksum files, need to download the binary and calculate it myself
ASSET_NAME="rofi-${VERSION}.tar.gz"
gh release download "${VERSION}" -R "$REPO" --pattern "${ASSET_NAME}" --output "${ASSET_NAME}"
export SHA256=$(sha256sum "${ASSET_NAME}" | cut -d ' ' -f1)
rm -f "${ASSET_NAME}"
[[ ! ${SHA256} =~ ^[a-f0-9]{64}$ ]] && printf "got junk instead of sha256\n" && exit 1

envsubst '${SHA256} ${VERSION}' < "${__dir}/.template" > "${__dir}/template"

printf "rofi-wayland template updated\n"
