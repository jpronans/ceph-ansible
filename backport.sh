#!/usr/bin/env bash
set -e


#############
# VARIABLES #
#############

stable_branch=$1
commit=$2
bkp_branch_name=$3
bkp_branch_name_prefix=bkp
bkp_branch=$bkp_branch_name-$bkp_branch_name_prefix


#############
# FUNCTIONS #
#############

git_status () {
  if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
    echo "It looks like you have not committed changes:"
    echo ""
    git status --short
    echo ""
    echo ""
    echo "Press ENTER to continue and Ctrl+C to break."
    read -r
  fi
}

checkout () {
  git checkout -b "$bkp_branch" origin/"$stable_branch"
}

cherry_pick () {
  local x
  for com in ${commit//,/ }; do
    x="$x -x $com"
  done
  git cherry-pick -s "$x"
}

push () {
  git push origin "$bkp_branch"
}

cleanup () {
  echo "Moving back to previous branch"
  git checkout -
  git branch -D "$bkp_branch"
}

test_args () {
  if [ $# -ne 3 ]; then
    echo "Please run the script like this: ./backport.sh.sh STABLE_BRANCH_NAME COMMIT_SHA1 BACKPORT_BRANCH_NAME"
    echo "We accept multiple commits as soon as they are commas-separated."
    echo "e.g: ./backport.sh.sh stable-2.2 6892670d317698771be7e96ce9032bc27d3fd1e5 my-work"
    exit 1
  fi
}


########
# MAIN #
########

test_args "$@"
git_status
checkout
cherry_pick
push
cleanup
