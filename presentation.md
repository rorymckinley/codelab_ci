* Intro - who, what, where
* Why CI? What problems are we looking to solve?
  + Initially just seen as a way to offload slow tests
  + Issues with promiscous sharing between private branches - whose branch is it anyway?
* CI as a discipline, rather than a tool.
* Why we rolled our own
  + Instead of using jenkins
  + You do not have to DIY
* The merge process we wish to model with CI
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
* Stuff left unfinished
  + Init script can be more polished
  + Notifications - not only to the tagger but also the other devs who share the workbench branch
  + Default integration and validation components assume a lot of happy day - need to be extended and probably made it a bit more robust
  + Use vagrant as an integration environment
  + Where can we use Jenkins/Goldberg/et al
* Code demo
* Dive into the code
