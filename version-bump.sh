#!/bin/bash

# Directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

#
# Takes a version number, and the mode to bump it, and increments/resets
# the proper components so that the result is placed in the variable
# `NEW_VERSION`.
#
# $1 = mode (major, minor, patch)
# $2 = version (x.y.z)
#
function bump {
  local mode="$1"
  local old="$2"
  local parts=( ${old//./ } )
  case "$1" in
    major)
      local bv=$((parts[0] + 1))
      NEW_VERSION="${bv}.0.0"
      ;;
    minor)
      local bv=$((parts[1] + 1))
      NEW_VERSION="${parts[0]}.${bv}.0"
      ;;
    patch)
      local bv=$((parts[2] + 1))
      NEW_VERSION="${parts[0]}.${parts[1]}.${bv}"
      ;;
    esac
}

git config --global user.email $EMAIL
git config --global user.name $NAME

OLD_VERSION=$(jq ".version" < package.json | tr -d \")
BUMP_MODE="none"

if [[ "${TYPE}" == "" ]]
then
  if git log -1 | grep -q "#major"; then
  BUMP_MODE="major"
  elif git log -1 | grep -q "#minor"; then
  BUMP_MODE="minor"
  elif git log -1 | grep -q "#patch"; then
  BUMP_MODE="patch"
  fi
else
  case "$TYPE" in
    major)
      BUMP_MODE="major"
      ;;
    minor)
      BUMP_MODE="minor"
      ;;
    patch)
      BUMP_MODE="patch"
      ;;
    esac
fi

if [[ "${BUMP_MODE}" == "none" ]]
then
  echo "No matching commit tags found or no release type set."
  echo "package.json at" $POMPATH "will remain at" $OLD_VERSION
else
  echo $BUMP_MODE "version bump detected"
  bump $BUMP_MODE $OLD_VERSION
  echo "package.json at" $POMPATH "will be bumped from" $OLD_VERSION "to" $NEW_VERSION
  jq ".version = \"${NEW_VERSION}\"" <package.json >package.json.newVersion && mv package.json.newVersion package.json
  git add package.json
  REPO="https://$GITHUB_ACTOR:$TOKEN@github.com/$GITHUB_REPOSITORY.git"
  git commit -a -m "Bump package.json from $OLD_VERSION to $NEW_VERSION"
  git tag $NEW_VERSION
  git push $REPO --follow-tags
  git push $REPO --tags
fi
