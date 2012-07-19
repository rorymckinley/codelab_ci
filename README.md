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
  * git tag -af ci\_followed\_by\_anything. The tag message should be the 
    message desired for the squashed merge into the workbench branch. The
    tag must not be duplicated across "users"
  * git push -t
* The post-receive hook on the server handles the push as follows:
  * Checks STDIN for a refname that is refs/tags/ci\_followed\_by\_anything
  * If it finds a suitable refname, it finds the commit linked to the tag 
    (using the refname not the sha of the tag to ensure that we always get
    the latest commit for that tag). Use:
    git for-each-ref --format="%(object) %(taggeremail)" refs/tags/ci
  * Using the commit, it finds the branch that contains the commit.
    Using: git branch --contains commit_sha
  * It tries to lookup a workbench branch via the naming convention:
    strip off ci\_[^\_]\+\_ from the CI branch.
  * Write a merge request file, whose name is unique, into the configured queue
    directory. It contains:
    * tagger's identity (taggeremail?)
    * tag sha
    * commit sha
    * workbench branch name
* The scheduler is a once-a-minute cron job (locked against itself by rlock
  (from https://github.com/ahoward/lockfile):
  * Discover all merge requests in the queue.
  * Find the tagger and workbench of the oldest merge request.
  * Find that tagger's newest merge request for the same workbench and kick
    off a validate-and-merge process for it.
  * Delete all other merge requests for that tagger and branch (leaving the one
    we just kicked off).
  * Until the configured concurrent process limit is reached, find the tagger
    and workbench of the next oldest merge request and repeat the process.
    Workbenches and merge requests already kicked off in this run are excluded
    from consideration.
  * If any processes were kicked off, Process.wait. :-)
* The validate-and-merge operation works like this:
  * Check out the workbench branch.
  * Squashed merge the commit sha, constructing the commit message as follows:
      * Use the configured CI committer name and committer address.
      * Use the author name and author address from the tagged commit.
      * Use the tag annotation as the commit message for the merge.
  * Run the configured validator and abort with notification if it fails.
  * git push without -t, because we don't want the ci branch to make it back
    into the workbench branch, which would cause havoc.
  * Notify the tagger of failure or success.

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
