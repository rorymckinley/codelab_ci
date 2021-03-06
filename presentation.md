Part: The First (5 minutes) --> Rory McKinley
===============
* Intro - who, what, where
* Format of talk
* Why CI? What problems are we looking to solve?
  + Initially just seen as a way to offload slow tests
  + Issues with promiscous sharing between private branches - whose branch is it anyway?

Part: the Second (20 minutes) --> Sheldon Hearn
================
* CI as a discipline, rather than a tool.
  + Wikipedia defn & insight from John Feminella (in README.md)
  + Requirements
    + Human requirements
      + Organizational/project support for the practice
      + Buy-in from team members (willing to try new things?)
      + Willingness to communicate
      + Incremental changes
    + Technical requirements
      + DVCS (favour mainline, avoid branches)
      + Automated build
      + Self-testing build
      + Everyone Commits To the Mainline Every Day
      + Every Commit Should Build the Mainline on an Integration Machine
        + (when this is automatic, you are doing Automated CI)
      + Keep the Build Fast (the point of CI is rapid feedback)
      + Test in a Clone of the Production Environment
      + Make it Easy for Anyone to Get the Latest Executable
      + Everyone can see what is happening
      + Automate Deployment (more important for build-driven software)
  + Advantages
    + Every revert is a step back to known goodness
    + Early warning of conflicting changes
    + Constant availability of a deployable build
    + Immediate feedback on the quality, functionality, or system-wide impact
      of changes.
    + Frequent code check-in demands modular code and disciplined refactoring.
    + Less frustration, potential for less conflict.
  + Disadvantages
    + Initial setup time required
    + Well-developed test-suite required to achieve automated testing advantages
    + Hardware costs for build machines can be significant
* Why we rolled our own
  + Slow tests, optimistic integration
  + Instead of using jenkins
  + You do not have to DIY

Part: the Third (20 minutes) --> Rory McKinley
===============
* The merge process we wish to model with CI
  + What is a workbench branch
  + What is a private branch
  + What is a timeline
  + Principles for requestint integration
    * Running the CI on the private branch is voluntary
    * Decision to integrate can be done post-commit and does not require a new commit
    * Integration is done before merging into a workbench branch
    * When the dev is ready for integration she can specify a pretty commit message
    * Convention over configuration - rely on tags - "easy" to link
  + Parallel builds on workbench branch not allowed - too complex for now - ito commits
  + First come, first serve, but run the freshest commit
* How we modeled that process in code
  + Git hook - post-receive - why not post-update
  + Git hook - checks for a valid tag - and can it link that tag to a branch and a commit?
  + If we have an integration request add it to the queue.
  + Run the cron (enter the scheduler and dispatcher)
  + Get the next request to be integrated from the scheduler - pass it to the dispatcher
  + Dispatcher builds an Integration and forks a thread to run it
  + Integration forks a subprocess that executes the necesary 
  + Dispatcher is responsible for deciding what gets integrated and when - passes a filter to the scheduler
  + Once a request has been processed - the scheduler is told to remove it from the queue

Part: The Fourth (15 minutes) --> Sheldon Hearn
================
* Stuff left unfinished
  + Init script can be more polished
  + Notifications - not only to the tagger but also the other devs who share the workbench branch
  + Default integration and validation components assume a lot of happy day - need to be extended and probably made it a bit more robust
  + Use vagrant as an integration environment
  + Where can we use Jenkins/Goldberg/et al
* Code demo --> Sheldon talks and Rory does the work :)

Part: The Fifth (25 minutes)
===============
* Dive into the code
