set --local subcommands init add rm remove ls list co checkout

complete --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" --arguments remove --description "delete branch"
complete --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" --arguments checkout --description "checkout branch"
complete --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" --arguments add --description "create new branch"
complete --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" --arguments list --description "list all local branches"
complete --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" --arguments init --description "init workspace"

complete --command workspace --condition "__fish_seen_subcommand_from rm remove; and not __fish_seen_subcommand_from (_workspace_associated_branches)" --arguments "(_workspace_associated_branches)"
complete --command workspace --condition "__fish_seen_subcommand_from checkout co; and not __fish_seen_subcommand_from (_workspace_local_branches)" --arguments "(_workspace_local_branches)"

# checkout command is optional
complete --command workspace --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_seen_subcommand_from (_workspace_all_branches)" --arguments "(_workspace_all_branches)" --description "checkout"

complete --no-files --command workspace
