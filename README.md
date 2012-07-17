codelab\_ci
==========

Teh Plan
--------

* The team creates a new workbench branch, e.g. workbench\_sprint66.
* Each team member branches their own CI branch off the workbench branch, for
  example ci\_sheldonh\_workbench\_sprint66.
* Each team member can commit and push as vigorously as they please on their CI
  branch, using sloppy, private commit messages along the way.
* When a team member wants to share their changes on the workbench, they:
  * git tag -af ci. The tag message should be the message desired for the
    squashed merge into the workbench branch.
  * git push -t
* The update hook on the server handles the push as follows:
  * Get out of the way unless sha1-new is tagged as ci.
  * Select the workbench branch by naming convention: strip off ci\_[^\_]\+\_
    from the CI branch.
  * Schedule a test-and-merge operation from the CI branch to HEAD on the
    workbench branch.
* The test-and-merge operation works like this:
  * Check out the workbench branch.
  * Squashed merge the commit tagged as ci on the CI branch, constructing the
    commit message as follows:
      * Use the configured CI committer name and committer address.
      * Use the author name and author address from the tagged commit.
      * Use the tag annotation as the commit message for the merge.
  * Run the configured validator and abort with notification if it fails.
  * git push without -t, because we don't want the ci branch to make it back
    into the workbench branch, which would cause havoc.
  * Notify the configured team address, or the author address.

Ideas
-----

* Use a stale branch report to warn about CI branches that haven't been tagged
  for merge into the workbench for a while.
* The hook will need to be deployed into the repo, visibly as part of the
  presentation. We can use a repo from github.com, but we'll need a bare local
  checkout of that repo on our presentation server, to use it as an origin for
  our presentation client.
* The hook should call out to our workbench-hook gem, which itself calls out to
  our workbench-validator gem. Gem names need to be sexier.

Git-hooks
---------

* Looks like the post-receive hook is better suited for our purposes than the
  update hook. The update hook fires once per ref being pushed --> e.g. once
  for the branch and once for the tag (the tag does not travel with the branch).
  This makes the hook logic as follows:
  * Get refs from STDIN
  * Check if one of the refs passed is refs/tags/ci
  * If it is pick the new shas from the branches pushed (refs/heads) and check
    each one to see if the tag contains it, using something like 
    system("git tag --contains #{new_sha} | grep ci")
  * If the new sha is contained by the tag, then pass it on to the validator

