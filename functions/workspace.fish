function workspace --argument-names command
  if ! test -n "$_workspace_root"
    _workspace_confirm "workspace haven't initialized yet! do it now?" && _workspace_init
    return
  end
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
  if test -n "$_workspace_root"
    _workspace_log workspace already initialized!
    return 1
  end
  set --local root (command git rev-parse --show-toplevel)
  set --local branch (command git branch --show-current)
  set --local worktree (_workspace_path $branch)
  command mv "$root" "{$root}-tmp" &&
  command mkdir -p "$root/.ws" &&
  command mv "{$root}-tmp" "$worktree" &&
  command ln -sf "$worktree" "$root/.ws/.git_working_dir" &&
  command ln -sf "$worktree" (_workspace_alias $branch) &&
  test -n "$ws_setup_script" && withd "$worktree" "$ws_setup_script"
end

function _workspace_list
  set --local workspace_root (_workspace_root)
  _workspace_git worktree list
end

function _workspace_add --argument-names branch --description "create new branch and checkout in it's worktree"
  set --local worktree (_workspace_path "$branch")

  if test -d "$worktree"
    _workspace_log worktree (set_color magenta)$worktree(set_color normal) is already exists!
    _workspace_log checkout (set_color magenta)$branch(set_color normal) as (set_color green)workspace checkout $branch(set_color normal)
    return 1
  end
  if _workspace_branch_exists $branch
    _workspace_log branch (set_color magenta)$branch(set_color normal) is already exists!
    _workspace_log checkout (set_color magenta)$branch(set_color normal) as (set_color green)workspace checkout $branch(set_color normal)
    return 1
  end

  _workspace_log creating branch (set_color magenta)$branch(set_color normal) at worktree (set_color magenta)$worktree(set_color normal)
  if _workspace_git worktree add -B "$branch" --checkout --quiet "$worktree"
    command ln -sf "$worktree" "$_workspace_root"
    test -n "$ws_setup_script" && withd "$worktree" "$ws_setup_script"
    cd (_workspace_alias $branch)
  end
end

function _workspace_checkout --argument-names branch --description "checkout existing branch in it's worktree"
  set --local worktree (_workspace_path $branch)

  if ! _workspace_branch_exists $branch
    _workspace_log branch (set_color magenta)$branch(set_color normal) does not exists!
    _workspace_log create (set_color magenta)$branch(set_color normal) as (set_color green)workspace add $branch(set_color normal)
    return 1
  end

  if ! test -d "$worktree"
    _workspace_log checkout (set_color magenta)$branch(set_color normal) at worktree (set_color magenta)$worktree(set_color normal)
    if _workspace_git worktree add --checkout --quiet --track --guess-remote "$worktree" "$branch"
      command ln -sf "$worktree" "$_workspace_root"
      test -n "$ws_setup_script" && withd "$worktree" "$ws_setup_script"
    end
  end

  cd (_workspace_alias $branch)
end

function _workspace_remove --argument-names branch
  set --local worktree (_workspace_path "$branch")
  set --local current_workspace (_workspace_path (command git branch --show-current))

  set --local found_worktree
  set --local found_branch
  set --local found_both
  _workspace_worktrees | while read --local w b
    test "$worktree" = "$w" && set found_worktree TRUE
    test "$branch" = "$b" && set found_branch TRUE
    test "$worktree" = "$w" -a "$branch" = "$b" && set found_both TRUE
  end
  if test "$found_worktree" != TRUE
    _workspace_log worktree (set_color magenta)$worktree(set_color normal) does not exists!
    return 1
  end
  if test "$found_branch" != TRUE
    _workspace_log branch (set_color magenta)$branch(set_color normal) does not exists locally!
    return 1
  end
  if test "$found_both" != TRUE
    _workspace_log branch (set_color magenta)$branch(set_color normal) does not associate with worktree (set_color magenta)$worktree(set_color normal)!
    return 1
  end

  argparse --ignore-unknown 'f/force' -- $argv

  _workspace_log delete branch (set_color magenta)$branch(set_color normal) and worktree (set_color magenta)$worktree(set_color normal)
  if test -d "$worktree"
    if set --query _flag_force
      _workspace_git worktree remove "$worktree" --force &&
      _workspace_git branch -D "$branch" &&
      command rm (_workspace_alias $branch)
    else
      _workspace_git worktree remove "$worktree" &&
      _workspace_git branch -d "$branch" &&
      command rm (_workspace_alias $branch)
    end
  end

  test "$worktree" = "$current_workspace" && cd $_workspace_root
end
