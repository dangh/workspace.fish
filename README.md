# fish-workspace
utilities to work with git worktree

## setup
```sh
fisher install dangh/relpath.fish dangh/withd.fish dangh/workspace.fish
```

## usage

```sh
# setup new workspace from a git repo
workspace init

# create new worktree and new branch
workspace add my-new-branch

# switch worktree, checkout existing branch and create new worktree if possible
workspace checkout existing-branch

# delete existing branch and worktree
workspace remove my-branch

# list all worktree
workspace list
```

## options

```sh
# this script will be executed when add a new worktree
set -U ws_setup_script 'test -f package.json && npm install --silent >/dev/null'
```
