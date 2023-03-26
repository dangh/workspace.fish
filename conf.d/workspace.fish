status is-interactive || exit

function _workspace_fix -v _workspace_root -d "fix worktree paths when moving to another place"
  test -n "$_workspace_root" || return
  set -l gitfile (string replace -r '/\.ws/([^/]+).*' '/.ws/$1/.git' (pwd -P))
  test -f "$gitfile" || return
  read -l -d 'gitdir: ' _0 gitdir < $gitfile
  test -d "$gitdir" && return
  set -l gitdir_fix (string replace -r '/\.ws/([^/]+).*' '/.ws/.git_working_dir/.git/worktrees/$1' (pwd -P))
  test -d "$gitdir_fix" || return
  _workspace_log fixing worktree (set_color magenta)$gitdir(set_color normal) (set_color cyan)'>'(set_color normal) (set_color magenta)$gitdir_fix(set_color normal)
  echo "gitdir: $gitdir_fix" > $gitfile
end

function _workspace_log -d "print log"
  echo '('(set_color yellow)workspace(set_color normal)')' $argv
end

function _workspace_root -v PWD -d "resolve workspace location"
  if test -d $PWD/.ws
    set -g _workspace_root $PWD
  else
    set -g _workspace_root (string match -r -- '(.*)/\.ws($|/.*)' (pwd -P))[2]
  end
end && _workspace_root

function _workspace_git -d "execute git command with workspace config"
  set -l git_config $_workspace_root/.ws/.git_working_dir
  command git -C $git_config $argv
end

function _workspace_name -a branch -d "standardize branch name to worktree name"
  string replace -a -r "[\s/]" "-" "$argv"
end

function _workspace_path -a branch -d "resolve worktree location"
  test -n "$_workspace_root" || _workspace_root
  echo $_workspace_root/.ws/(_workspace_name $branch)
end

function _workspace_alias -a branch -d "resolve worktree alias location"
  test -n "$_workspace_root" || _workspace_root
  echo $_workspace_root/(_workspace_name $branch)
end

function _workspace_confirm -a message -d "yes/no prompt"
  read -P (set_color magenta)$message(set_color normal)
end

function _workspace_worktrees -d "list all worktrees with branches"
  _workspace_git worktree list | while read -l w b
    set b (string match -r -- '\[(.*)\]' $b)[2]
    echo $w\t$b
  end
end

function _workspace_local_branches
  _workspace_git for-each-ref --format='%(refname:strip=2)' refs/heads/ 2>/dev/null
end

function _workspace_remote_branches
  _workspace_git for-each-ref --format='%(refname:strip=3)' refs/remotes/ 2>/dev/null
end

function _workspace_all_branches -d "list all local/remote branches"
  _workspace_local_branches
  _workspace_remote_branches
end

function _workspace_associated_branches -d "list all associated branches"
  _workspace_git worktree list --porcelain | awk '{ if(match($2, /refs\/heads\//)) print substr($2, RSTART+RLENGTH) }'
end

function _workspace_branch_exists -a branch -d "check branch existence"
  contains $branch (_workspace_all_branches)
end

function _workspace_install -e workspace_install -e workspace_update
  abbr -a w workspace
  abbr -a wa workspace add
  abbr -a wco workspace checkout
  abbr -a wp workspace pull
  abbr -a wl workspace list
  abbr -a wls workspace list
  abbr -a wr workspace remove
  abbr -a wrm workspace remove
end

function _workspace_uninstall -e workspace_uninstall
  set -e _workspace_plugin_initialized
  abbr -e w
  abbr -e wa
  abbr -e wco
  abbr -e wp
  abbr -e wl
  abbr -e wls
  abbr -e wr
  abbr -e wrm
end
