function __workspace_worktree_list
  set --local git_working_dir
  set --local git_args
  if test -e .ws/git_working_dir
    set git_working_dir .ws/(command cat .ws/git_working_dir)
    set git_args "-C" $git_working_dir
  end
  for i in (command git $git_args worktree list)
    string replace -r '^.*/.ws/(.+?)\s+\w{9}\s\[.+\]$' '$1' $i
  end
end

function __workspace_branch_list
  git branch --remote --format '%(refname:lstrip=3)'
end

set --local subcommands init add rm remove ls list co checkout

complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_worktree_list)" --arguments remove --description "delete branch"
complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_worktree_list)" --arguments checkout --description "checkout branch"
complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_worktree_list)" --arguments add --description "create new branch"
complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_worktree_list)" --arguments list --description "list all local branches"
complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_worktree_list)" --arguments init --description "init workspace"

complete --keep-order --no-files --command workspace --condition "__fish_seen_subcommand_from rm remove; and not __fish_seen_subcommand_from (__workspace_worktree_list)" --arguments "(__workspace_worktree_list)"
complete --keep-order --no-files --command workspace --condition "__fish_seen_subcommand_from checkout co; and not __fish_seen_subcommand_from (__workspace_worktree_list)" --arguments "(__workspace_branch_list)"

complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_worktree_list)" --arguments "(__workspace_worktree_list)" --description "checkout"

complete --keep-order --no-files --command workspace
