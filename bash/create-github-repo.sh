#https://stackoverflow.com/questions/11693288/how-to-create-a-new-repo-at-github-using-git-bash
reponame="new_repo"
USERNAME="user_of_repo"
curl -u $USERNAME https://api.github.com/user/repos -d "{\"name\":\"$reponame\"}"
git init 
touch README.md
git add *
git commit -m "Starting Out"
git remote add origin git@github.com:$USERNAME/$reponame.git
git push -u origin master