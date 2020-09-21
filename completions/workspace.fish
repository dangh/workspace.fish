function __workspace_complete_list
  for i in (git worktree list)
      string replace -r '^.*/.ws/(.+?)\s+\w{9}\s\[.+\]$' '$1' $i
  end
end

function __workspace_complete_add
  git branch --remote --format '%(refname:lstrip=3)'
end

set --local subcommands init add rm ls list co checkout

complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_complete_list)" --arguments remove --description "remove current worktree"
complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_complete_list)" --arguments checkout --description "checkout worktree"
complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_complete_list)" --arguments add --description "add new worktree"
complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_complete_list)" --arguments list --description "list all worktrees"
complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_complete_list)" --arguments init --description "init workspace"

complete --keep-order --no-files --command workspace --condition "__fish_seen_subcommand_from checkout co; and not __fish_seen_subcommand_from (__workspace_complete_list)" --arguments "(__workspace_complete_list)"
complete --keep-order --no-files --command workspace --condition "__fish_seen_subcommand_from add; and not __fish_seen_subcommand_from (__workspace_complete_add)" --arguments "(__workspace_complete_add)"

complete --keep-order --no-files --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (__workspace_complete_list)" --arguments "(__workspace_complete_list)" --description "checkout"

complete --keep-order --no-files --command workspace
