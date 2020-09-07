function workspace --argument-names command
  switch $command
    case init
      _workspace_init
    case rm remove
      _workspace_remove "$argv[2..-1]"
    case "" ls list
      _workspace_list
    case \*
      _workspace_switch $command
  end
end

function _workspace_init
  if string match --quiet --regex '/\.ws(/|$)' (pwd -P)
    echo [workspace] workspace already initialized!
    return
  end

  set --local workspace_root (command git rev-parse --show-toplevel)
  set --local workspace (_workspace_name (command git branch --show-current))
  command mv "$workspace_root" "{$workspace_root}-tmp"
  command mkdir -p "$workspace_root/.ws"
  command mv "{$workspace_root}-tmp" "$workspace_root/.ws/$workspace"
  echo "$workspace" > "$workspace_root/.ws/git_working_dir"
  command ln -s "$workspace_root/.ws/$workspace" "$workspace_root/$workspace"
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

function _workspace_switch --argument-names branch
  set --local workspace_root (_workspace_root)
  set --local workspace (_workspace_name "$branch")
  set --local git_working_dir (cat "$workspace_root/.ws/git_working_dir")
  if test ! -d "$workspace_root/.ws/$workspace"
    echo [workspace] creating workspace $workspace
    command git -C "$workspace_root/.ws/$git_working_dir" worktree add -B "$branch" --guess-remote --quiet "$workspace_root/.ws/$workspace" "$branch"
    command ln -s "$workspace_root/.ws/$workspace" "$workspace_root/$workspace"
    if set --query ws_setup_script
      cd "$workspace_root/.ws/$workspace"
      echo "$ws_setup_script" | source
    end
  end
  cd "$workspace_root/$workspace"
end

function _workspace_remove --argument-names branch
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
    echo [workspace] not a git workspace!
    return 1
  end
  echo $workspace_root
end

function _workspace_name --argument-names branch
  echo $branch
end
