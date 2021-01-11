# Github pull-request:

- fork a public repo so that you have its code in your account (no need to fork if you have write permission to the repo)
- clone the repo to have it as a local copy
```bash
cd toTheFolderYouWantToCloneTheRepo
git clone https://github.com/your-username/repository.git
```
*(optional)*
- create new branch to make changes (get in the repo folder first)
```bash
git branch newBranchName
git checkout newBranchName
```
or change branch directly
```bash
git checkout -b newBranchName
```
check the remote
```bash
git remote -v
# should be something like: origin  https://github.com/your-username/forked-repository.git
```
or
```bash
git remote # should be: origin
```
- make the changes in code / add files etc
```bash
git status
git add .
git commit -m "you commit message"
git push
#or if you made a new branch (to sync any future pull) (origin is your remote):
git push -u origin newBranchName
#or
git push --set-upstream origin newBranchName
```
- Click the **Compare & pull request** button in github

*(optional)*
- Set your forked repo to track the original one (for pull)
```bash
git branch # see your branches
git checkout master # if you are in an other feature branch
git remote add upstream https://github.com/owner-username/repository.git # the one you forked
git fetch upstream # Fetch all the changes from the original repo
git merge upstream/master # Merge the changes from upstream/master into your local master branch. This will bring your fork’s master branch into sync with the upstream repository without losing your local changes
git push origin master # update the github repo
git branch -d newBranchName # delete the feature branch you created
git branch # to confirm
```
