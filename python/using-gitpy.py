# http://gitpython.readthedocs.io/en/stable/index.html
# https://stackoverflow.com/questions/46168923/how-to-clone-repository-using-gitpython
import git
repo = git.Repo.clone_from("https://github.com/electrum/tpch-dbgen.git", "some-directory")
