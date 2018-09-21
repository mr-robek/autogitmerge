#!/usr/bin/env bash

#TODO: Add opts to script
SRC_BRANCH=dev #$1
WORK_BRANCH=merge-dev-master #$2
DEST_BRANCH=master #$3
REPOSITORY_URL="git@github.com:mr-robek/autogitmerge.git" #$4
REPOSITORY=$(basename $REPOSITORY_URL .git)

errexit()
{
  echo $*
  exit 1
}

check_branch_exists()
{
  URL=$1
  BRANCH=$2
  echo "Checking if the branch $BRANCH exists..."
  git ls-remote --exit-code --heads $URL "$BRANCH" > /dev/null 2>&1
}

clone_repository()
{
  URL=$1
  echo "Cloning $URL"
  git clone $URL > /dev/null 2>&1
}
current_branch()
{
  git branch | grep \* | cut -d ' ' -f2
}

HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
WORKSPACE=$HOME/workspace

[ -d "$WORKSPACE" ] && mkdir "$WORKSPACE"

# 1. Clone repo if not cloned
cd "$WORKSPACE"

[ -d "$REPOSITORY" ] || clone_repository $REPOSITORY_URL || errexit "Failed to clone $REPOSITORY_URL"
cd "$REPOSITORY"

git fetch
check_branch_exists $REPOSITORY_URL $SRC_BRANCH || errexit "The branch $SRC_BRANCH does not exit..."
check_branch_exists $REPOSITORY_URL $DEST_BRANCH || errexit "The branch $DEST_BRANCH does not exit..."

if ! check_branch_exists $REPOSITORY_URL $WORK_BRANCH ; then
  git checkout -b $WORK_BRANCH origin/$DEST_BRANCH
  git push -u origin $WORK_BRANCH
fi

[ $(current_branch) != $WORK_BRANCH ] && git checkout $WORK_BRANCH

git pull
echo "Merging destination branch to work branch"
git merge --no-ff origin/$DEST_BRANCH
echo "Merging source branch to work branch"
git merge --no-ff origin/$SRC_BRANCH
