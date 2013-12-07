wayfare
===

Workflow
===

This is a workflow I've been wanting to use for a while - I think it'll be a good one.

The main idea is to create a feature branch and a pull request every time you start working on something new.
The branch gives you an isolated place to commit your code, while keeping in sync with the develop branch.
The pull request gives us a place to discuss that specific branch, and an easy way to merge it in at the end.

**Such flow. Very git.**

We're gonna use something called git-flow for this project. It's really just a convention for naming branches. There are four types of branches in git flow:

1. `develop` - holds the most current code. when feature branches are done, they get merged into here. before you finish a feature, you'll sync up with develop so only your changes get pushed.
2. `feature/your_feature_name` - based on develop. start these when you start working on a feature. when you're done, merge them back into develop.
3. `master` - this is production code. it will always be exactly what is deployed online. to push a change to master is to push a change to the world.
4. `hotfix` - based on master. start these when you want to fix something that has been pushed to master. when you're done, merge them back into master, then rebase develop on top of master. you won't use these much.

Examples
===

Starting to work on something
---

Let's say I was starting to work on a new feature to generate buildings. Here's what I would do:
(all commands run from the root of the repo)

`git fetch --all` to get info from github on the state of all repos

`git pull --rebase origin develop` from the remote `origin` (should point to github), pull the develop branch down. the `--rebase` means that if you have any changes locally, the branch will get pulled down, then your changes will be added on top.

`git checkout -b feature/generate-buildings` make a new branch called feature/generate-buildings, and switch to it. At this point, this branch will be exactly the same as develop

`git push origin feature/generate-buildings` we have this branch locally, but github doesn't know about it yet. let's fix that by pushing it up to github (the `origin` remote)

Cool. So at this point I've got a fresh new branch, cut off of develop. In fact, right now it's identical to develop. Now, I want to create a pull request so that we've got a place to talk about this branch now, and merge it in later.
The easiest way to do this is through the github repo page. If you just pushed it up, you should see a prompt to create a pull request. If you don't just pick your branch from the dropdown, and click the green button with the arrow-square. Enter a bit of info about what the hell this branch is for, and click create. That's it for now - don't press the big merge button.

So at this point I could code happily away, and when I hit a point where I want to "save" my changes, I can do this:

Saving changes
---

`git status` shows you what's up in the repo

`git add --all` if you have any untracked files that you want to add to the repo. you'll have to do this if you created any files.

`git commit -am 'figured out how to represent building layouts in templates'` commits the current changes with a commit message

`git status` should now show that you have no changes

`git push origin feature/generate-buildings` pushes this commit up to github. It'll also show up in that pull request.

My changes have now been saved, and persisted to the server. Let's say I make 10 more commits, and then I decide that this feature is done. After discussing on the PR if there are any conflicts or etc, I'm ready to merge this branch in. Wait! Don't click the merge button in the pull request! If you've been working on this branch for a while, some progress  has probably been made on the develop branch. If you merge your branch straight in, you'll overwrite those changes with your old version of those files, because you haven't updated them since you started the branch. Let's fix that:

Finishing something
---

`git checkout develop` to switch to the develop branch. make sure you've committed all of your changes first.

`git fetch --all` to get info about any changes from github on the develop branch

`git pull --rebase origin develop` to pull down the version of develop from github and merge it with your local version

`git checkout feature/generate-buildings` to switch back to your feature branch

`git rebase develop` remember how you based this branch on develop when you created it? rebase goes back to that point, and pretended that you based it on the newest version of develop, instead of the one that was there when you started. Your changes get "replayed" on top of the new develop. You're changing the "base" of your feature branch to the new develop. "re"-"base"

`git push origin feature/generate-buildings` to update the branch on github.

Now if you go back to the pull request, you should see that the only changes listed are to the files you changed in your feaure branch. Awesome. At this point, you're cool to merge this branch with develop. Then, anyone else working on a feature branch can pull down develop 
