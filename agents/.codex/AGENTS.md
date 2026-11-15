# General Git Rules

Instructions

- when working on a new feature please start a new branch on the latest master/main, remember to pull from upstream/origin
- when making a pr against multiple branches, the branch name should be in the pr title in parenthesis

## Mandatory Pre-push Review Gate

- Before every Git push, pull-request creation, or pull-request update that sends commits to a remote branch, always invoke `$pre-push-review-gate`, even when the user does not explicitly name it.
- Do not push or publish the pull request until the skill's complete review workflow has run and the user has explicitly approved the push.
