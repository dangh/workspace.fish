function workspace -a command
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
    case co checkout p pull
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
  set -l root (command git rev-parse --show-toplevel)
  set -l branch (command git branch --show-current)
  command mv "$root" "$root-tmp" &&
  command mkdir -p "$root/.ws" &&
  set -l worktree (_workspace_path $branch)
  command mv "$root-tmp" "$worktree" &&
  ln -sf "$worktree" "$root/.ws/.git_working_dir" &&
  ln -sf "$worktree" (_workspace_alias $branch) &&
  cd (_workspace_alias $branch) &&
  test -n "$ws_setup_script" && withd "$worktree" "$ws_setup_script"
end

function _workspace_list
  set -l workspace_root (_workspace_root)
  _workspace_git worktree list
end

function _workspace_add -a branch -d "create new branch and checkout in it's worktree"
  set -l worktree (_workspace_path "$branch")

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
    ln -sf "$worktree" "$_workspace_root"
    test -n "$ws_setup_script" && withd "$worktree" "$ws_setup_script"
    cd (_workspace_alias $branch)
  end
end

function _workspace_checkout -a branch -d "checkout existing branch in it's worktree"
  set -l worktree (_workspace_path $branch)

  if ! _workspace_branch_exists $branch
    _workspace_log branch (set_color magenta)$branch(set_color normal) does not exists!
    _workspace_log create (set_color magenta)$branch(set_color normal) as (set_color green)workspace add $branch(set_color normal)
    return 1
  end

  if ! test -d "$worktree"
    _workspace_log checkout (set_color magenta)$branch(set_color normal) at worktree (set_color magenta)$worktree(set_color normal)
    set -l flags --checkout --quiet
    contains "$branch" (_workspace_local_branches) || set -a flags --track
    if _workspace_git worktree add $flags "$worktree" "$branch"
      ln -sf "$worktree" "$_workspace_root"
      test -n "$ws_setup_script" && withd "$worktree" "$ws_setup_script"
    end
  end

  set -l target (_workspace_alias $branch)
  if set -q ws_preserve_path
    if string match (_workspace_path)\* $PWD
      string replace (_workspace_path) '' $PWD | read -l -d / _0 suffix
      if test -n "$suffix"
        set target $target/$suffix
        while not test -d $target
          set target (path dirname $target)
        end
      end
    end
  end
  cd $target
end

function _workspace_remove -a branch
  set -l worktree (_workspace_path "$branch")
  set -l current_workspace (_workspace_path (command git branch --show-current))

  set -l found_worktree
  set -l found_branch
  set -l found_both
  _workspace_worktrees | while read -l w b
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

  argparse -i 'f/force' -- $argv

  _workspace_log delete branch (set_color magenta)$branch(set_color normal) and worktree (set_color magenta)$worktree(set_color normal)
  if test -d "$worktree"
    if set -q _flag_force
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
