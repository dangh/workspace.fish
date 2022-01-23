status is-interactive || exit

function _workspace_fix --on-variable _workspace_root --description "fix worktree paths when moving to another place"
  test -n "$_workspace_root" || return
  set --local gitfile (string replace --regex '/\.ws/([^/]+).*' '/.ws/$1/.git' (pwd -P))
  test -f "$gitfile" || return
  read --delimiter='gitdir: ' --local _ gitdir < $gitfile
  test -d "$gitdir" && return
  set --local gitdir_fix (string replace --regex '/\.ws/([^/]+).*' '/.ws/.git_working_dir/.git/worktrees/$1' (pwd -P))
  test -d "$gitdir_fix" || return
  _workspace_log fixing worktree (set_color magenta)$gitdir(set_color normal) (set_color cyan)'>'(set_color normal) (set_color magenta)$gitdir_fix(set_color normal)
  echo "gitdir: $gitdir_fix" > $gitfile
end

function _workspace_log --description "print log"
  echo '('(set_color yellow)workspace(set_color normal)')' $argv
end

function _workspace_root --on-variable PWD --description "resolve workspace location"
  if test -d $PWD/.ws
    set --global _workspace_root $PWD
  else
    set --global _workspace_root (string match --regex -- '(.*)/\.ws($|/.*)' (pwd -P))[2]
  end
end && _workspace_root

function _workspace_git --description "execute git command with workspace config"
  set --local git_config $_workspace_root/.ws/.git_working_dir
  command git -C $git_config $argv
end

function _workspace_name --argument-names branch --description "standardize branch name to worktree name"
  string replace --all --regex "[\s/]" "-" "$argv"
end

function _workspace_path --argument-names branch --description "resolve worktree location"
  test -n "$_workspace_root" || _workspace_root
  echo $_workspace_root/.ws/(_workspace_name $branch)
end

function _workspace_alias --argument-names branch --description "resolve worktree alias location"
  test -n "$_workspace_root" || _workspace_root
  echo $_workspace_root/(_workspace_name $branch)
end

function _workspace_confirm --argument-names message --description "yes/no prompt"
  read -P (set_color magenta)$message(set_color normal)
end

function _workspace_worktrees --description "list all worktrees with branches"
  _workspace_git worktree list | while read --local w b
    set b (string match --regex -- '\[(.*)\]' $b)[2]
    echo $w\t$b
  end
end

function _workspace_local_branches
  _workspace_git for-each-ref --format='%(refname:strip=2)' refs/heads/ 2>/dev/null
end

function _workspace_remote_branches
  _workspace_git for-each-ref --format='%(refname:strip=3)' refs/remotes/ 2>/dev/null
end

function _workspace_all_branches --description "list all local/remote branches"
  _workspace_local_branches
  _workspace_remote_branches
end

function _workspace_associated_branches --description "list all associated branches"
  _workspace_git worktree list --porcelain | awk '{ if(match($2, /refs\/heads\//)) print substr($2, RSTART+RLENGTH) }'
end

function _workspace_branch_exists --argument-names branch --description "check branch existence"
  contains $branch (_workspace_all_branches)
end

if ! set --query _workspace_plugin_initialized
  set --universal _workspace_plugin_initialized (date)
  abbr --add w workspace
  abbr --add wa workspace add
  abbr --add wco workspace checkout
  abbr --add wl workspace list
  abbr --add wls workspace list
  abbr --add wr workspace remove
  abbr --add wrm workspace remove
end
