set -l subcommands init add rm remove ls list co checkout

complete -c workspace -n "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" -a remove -d "delete branch"
complete -c workspace -n "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" -a checkout -d "checkout branch"
complete -c workspace -n "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" -a add -d "create new branch"
complete -c workspace -n "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" -a list -d "list all local branches"
complete -c workspace -n "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" -a init -d "init workspace"

complete -c workspace -n "__fish_seen_subcommand_from rm remove; and not __fish_seen_subcommand_from (_workspace_associated_branches)" -a "(_workspace_associated_branches)"
complete -c workspace -n "__fish_seen_subcommand_from checkout co; and not __fish_seen_subcommand_from (_workspace_local_branches)" -a "(_workspace_local_branches)"
complete -c workspace -n "__fish_seen_subcommand_from p pull; and not __fish_seen_subcommand_from (_workspace_remote_branches)" -a "(_workspace_remote_branches)"

# checkout command is optional
complete -c workspace -n "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" -a "(_workspace_all_branches)" -d checkout

complete -f -c workspace
