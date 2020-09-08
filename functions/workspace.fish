function workspace --argument-names command
  switch $command
    case init
      _workspace_init
    case add
      _workspace_add $argv[2..-1]
    case rm remove
      _workspace_remove $argv[2..-1]
    case ls list ""
      _workspace_list $arvg[2..-1]
    case co checkout
      _workspace_checkout $argv[2..-1]
    case \*
      _workspace_checkout $argv
  end
end

function _workspace_init
  if string match --quiet --regex '/\.ws(/|$)' (pwd -P)
    _workspace_log workspace already initialized!
    return 1
  end

  set --local workspace_root (command git rev-parse --show-toplevel)
  set --local workspace (_workspace_name (command git branch --show-current))
  command mv "$workspace_root" "{$workspace_root}-tmp"
  command mkdir -p "$workspace_root/.ws"
  command mv "{$workspace_root}-tmp" "$workspace_root/.ws/$workspace"
  echo "$workspace" > "$workspace_root/.ws/git_working_dir"
  command ln -sf "$workspace_root/.ws/$workspace" "$workspace_root/$workspace"
  if set --query ws_setup_script
    cd "$workspace_root/.ws/$workspace"
    echo "$ws_setup_script" | source
  end
  cd "$workspace_root/$workspace"
end

function _workspace_list
  set --local workspace_root (_workspace_root)
  set --local git_working_dir (cat "$workspace_root/.ws/git_working_dir")
  command git -C "$workspace_root/.ws/$git_working_dir" worktree list
end

function _workspace_add --argument-names branch
  set --local workspace_root (_workspace_root)
  set --local workspace (_workspace_name "$branch")
  set --local git_working_dir (cat "$workspace_root/.ws/git_working_dir")
  if test ! -d "$workspace_root/.ws/$workspace"
    _workspace_log creating workspace `$workspace`
    command git -C "$workspace_root/.ws/$git_working_dir" worktree add -B "$branch" --guess-remote --quiet "$workspace_root/.ws/$workspace" "$branch"
    command ln -sf "$workspace_root/.ws/$workspace" "$workspace_root/$workspace"
    if set --query ws_setup_script
      cd "$workspace_root/.ws/$workspace"
      echo "$ws_setup_script" | source
    end
  else
    _workspace_log workspace `$workspace` is already exists! checkout `$workspace`
  end
  _workspace_checkout $branch
end

function _workspace_checkout --argument-names branch
  _workspace_log checkout `$branch`
  set --local workspace_root (_workspace_root)
  set --local workspace (_workspace_name "$branch")
  if test ! -d "$workspace_root/.ws/$workspace"
    _workspace_log workspace `$workspace` does not exist!
    _workspace_log checkout `$workspace` as (set_color magenta)workspace add $workspace(set_color normal)
    return 1
  end
  cd "$workspace_root/$workspace"
end

function _workspace_remove --argument-names branch
  _workspace_log remove `$branch`
  set --local workspace_root (_workspace_root)
  set --local workspace (_workspace_name "$branch")
  set --local git_working_dir (cat "$workspace_root/.ws/git_working_dir")
  set --local current_workspace (_workspace_name (command git branch --show-current))
  if test -d "$workspace_root/.ws/$workspace"
    command git -C "$workspace_root/.ws/$git_working_dir" worktree remove "$workspace"
    command rm "$workspace_root/$workspace"
  end
  if test "$workspace" = "$current_workspace"
    cd "$workspace_root"
  end
  _workspace_list
end

function _workspace_root
  set --local workspace_root (string replace --regex "/.ws/.*" "" -- (pwd -P))
  if test ! -d "$workspace_root/.ws"
    _workspace_log not a git workspace!
    return 1
  end
  echo $workspace_root
end

function _workspace_name --argument-names branch
  echo $branch
end

function _workspace_log
  echo '('(set_color green)workspace(set_color normal)')' $argv
end
