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
  * git tag -af ci\_localpart\_followed\_by\_anything. The tag message should
    be the message desired for the squashed merge into the workbench branch.
  * git push --tags
* The post-receive hook on the server handles the push as follows:
  * Checks STDIN for a refname that is refs/tags/ci\_followed\_by\_anything
  * If it finds a suitable refname, it finds the commit linked to the tag:
    git for-each-ref --format="%(object) %(taggeremail)" refs/tags/...
  * Using the commit, it finds the branch that contains the commit.
    Using: git branch --contains commit_sha
  * It asserts that the tag includes the committer's email localpart, to
    avoid tag collisions between team members.
  * It finds a workbench branch in the tag name, by naming convention.  The
    tag name is expected to end in workbench\_something.
  * Write a merge request file, whose name is unique, into the configured queue
    directory. It contains:
    * tagger's identity (taggeremail and taggername)
    * tag refname
    * commit sha
    * workbench branch name
* The scheduler is a once-a-minute cron job (locked against itself by lockfile
  ( https://github.com/ahoward/lockfile ):
  * Discover all integration requests in the queue.
  * Find the tagger and workbench of the oldest integration request.
  * Find that tagger's newest integration request for the same workbench and
    kick off a validate-and-integrate process for it.
  * Delete all integration requests for this tagger and branch, that are older
    than the one we just started integrating.
  * Until the configured concurrent process limit is reached, find the tagger
    and workbench of the next oldest integration request and repeat the process.
    However, we always exclude integration requests that are for a branch that
    already has an integration in process.
  * Stall when the process limit is reached.
  * Exit when there are no more requests in the queue and no more requests
    being processed.
* The validate-and-merge operation works like this:
  * Check out the workbench branch.
  * Squashed merge the commit sha, constructing the commit message as follows:
      * Use the configured CI committer name and committer address.
      * Use the author name and author address from the tagged commit.
      * Use the tag annotation as the commit message for the merge.
  * Run the configured validator and abort with notification if it fails.
  * git push without -t, because we don't want the ci branch to make it back
    into the workbench branch, which would cause havoc.
  * Notify the tagger of success.

The rather finnicky queuing and scheduling approaches are the result of a few
evening sessions where we got bashed around by a few constraints:

* Parallel builds for the same workbench branch are tricky. Two concurrent
  builds are guaranteed to be missing commits in each other's trees, and so
  even if the squashed commits could somehow be push/pulled into coexistence
  in the workbench branch after validation, you'd end up with a workbench
  branch that had not been tested exactly as committed! We could introduce
  speculative parallel builds as an optimization, but that's more work than
  we can take on in the time available.
* Team members should not be able to completely starve each other out of the
  CI system without being bastards. Approximate fairness.
* We wanted to waste as little time as possible on superceded commits from
  the same tagger for the same branch.

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
