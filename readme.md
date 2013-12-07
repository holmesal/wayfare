wayfare
===

Workflow
===

Commit early and often.

Always do a `git pull --rebase origin develop` before you push any code to develop.

How to Github
===

Clone shit
---

Navigate to the folder where you'd like the repo to live

`git clone git@github.com:holmesal/wayfare.git` to pull down the repo

Code shit
---

Make changes and stuff. Every so often you should commit (save snapshot of) code:

`git status` shows you what's up in the repo

`git add --all` if you have any untracked files that you want to add to the repo. you'll have to do this if you created any files.

`git commit -am 'figured out how to represent building layouts in templates'` commits the current changes with a commit message

`git status` should now show that you have no changes

Pull shit
---

Anytime you want to update your code so it's in sync with what's on github, do the following. MAKE SURE YOU COMMIT FIRST. `git status` should show that you have no changes.

`git pull --rebase origin develop` pulls down the develop branch, rewinds your code to the last time you pulled it down, replaces then-develop with now-develop, and fast-forwards your changes on top of it. The `--rebase` is hugely important, otherwise it will try to straight-up merge your code with the origin/develop, which might not work.

Push shit
---

Anytime you want to push your changes out to github, make sure you're all committed-up and ready to roll (`git status` shows no changes).

`git pull --rebase origin develop` (same as pull shit) to make sure that if there have been any changes to the code on github since you last pulled, they're now incorporated into the code that you're about to push back to github. This keeps you from rolling back changes other people have made, because you have an outdated version of code. `develop` is the name of the branch to pull.

`git push origin develop` to push your code up to github. If you get an error about the tip of your branch being behind, make sure you `pull --rebase` as mentioned above.

*Advanced* Branch shit
---

Sometimes you want to try doing something another way, or work on a few things at the same time, but not in the same code base. You can "branch" your code, which creates a new branch based on the one you're currently on. For example, let's say I'm working on "develop" and I want to go off on a side tangent about generating buildings. Here's what I would do:

`git commit -am 'some commit message'` commit all your changes first. If you don't do this, your uncommitted changes will carry over to your new branch.

`git checkout -b generate-buildings` create a new branch called generate-buildings and switch to it.

Then you can commit and all that jazz, except now you're on a different branch. You can list branches with `git branch` and change them with `git branch branch_name`.

If you decide you want to keep this branch and merge it back into your copy of develop, you can do this like so: (make sure you're all committed up first)

`git checkout develop` to switch to the develop branch
`git merge generate-buildings` to merge your branch back into develop.

If that goes okay, your changes are now in develop. You can delete that other branch if you want. I tend to keep them around cuz I'm an idiot.