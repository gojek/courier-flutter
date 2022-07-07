#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

require_clean_work_tree() {
  if output=$(git status --porcelain) && [[ "$output" ]]; then
    echo -e "${RED}error: there are uncommitted changes in your working directory. Stash the changes and try again.${NC}"
    exit 1
  fi
}

validate_current_branch_is_master() {
  CURRENT_BRANCH=$(git branch --show-current)
  if [[ ! $CURRENT_BRANCH == 'master' ]]; then
    echo -e "${RED}error: releases can be created from master branch only ${NC}"
    exit 1
  fi
}

validate_release_version_argument() {
  if [[ ! "$1" ]]; then
    echo -e "${RED}error: version number not provided as an argument ${NC}"
    exit 1
  fi
}

update_version_in_pubspec_for_path() {
  PUBSPEC_ROOT=$1
  NEW_VERSION=$2
  cd "$PUBSPEC_ROOT" || exit 1
  if sed -i.bak "s/version:.*/version: $NEW_VERSION/" pubspec.yaml; then
    fvm flutter pub get || exit 1
    rm pubspec.yaml.bak
    cd ..
    echo -e "${GREEN}Success ${NC}"
  else
    echo -e "${RED}error: failed to update version in pubspec.yaml for $PUBSPEC_ROOT ${NC}"
    exit 1
  fi
}

RELEASE_VERSION="$1"
RELEASE_BRANCH="release-$RELEASE_VERSION"
TAG="$RELEASE_VERSION"

require_clean_work_tree
validate_release_version_argument "$RELEASE_VERSION"
validate_current_branch_is_master

echo "Checking out new branch: $RELEASE_BRANCH"
git checkout -b "$RELEASE_BRANCH" || exit 1
echo

echo "Updating version in pubspec for courier_dart_sdk package..."
update_version_in_pubspec_for_path courier_dart_sdk "$RELEASE_VERSION"
echo

echo "Updating version in pubspec for courier_dart_sdk_demo app..."
update_version_in_pubspec_for_path courier_dart_sdk_demo "$RELEASE_VERSION"
echo

echo "Committing changes..."
git add . || exit 1
git commit -m "Bump up versions for release v$RELEASE_VERSION" || exit 1
echo

echo "Creating a tag..."
git tag -a "$RELEASE_VERSION" -m "$TAG" || exit 1
echo

echo "Pushing branch & tag to remote..."
git push origin "$RELEASE_BRANCH" || exit 1
git push origin "$TAG" || exit 1
echo -e "${GREEN}Success, a release job will be triggered on CI${NC}"
echo

MATCH_VERSION_BRANCH="match_version_${RELEASE_VERSION}"
COMMIT_SHA=$(git rev-parse HEAD)
echo "Raising a MR from $MATCH_VERSION_BRANCH on master with version bump commit..."
git checkout master || exit 1
git checkout -b "$MATCH_VERSION_BRANCH" || exit 1
git cherry-pick "${COMMIT_SHA}" || exit 1
echo

git push origin "$MATCH_VERSION_BRANCH" || exit
echo -e "${YELLOW}**************************************************************${NC}"
echo -e "${YELLOW}* Raise MR from link above to reflect version bump on master *${NC}"
echo -e "${YELLOW}**************************************************************${NC}"
echo

git checkout master
