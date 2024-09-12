status is-interactive || exit

function _workspace_log -d "print log"
    echo '('(set_color yellow)workspace(set_color normal)')' $argv
end

function _workspace_root -v PWD -d "resolve workspace location"
    set -g _workspace_root
    set -g _workspace
    if test -d $PWD/.ws
        set _workspace_root $PWD
    else
        set _workspace_root (string match -r -- '(.*)/\.ws($|/.*)' (pwd -P))[2]
        set _workspace (string replace $_workspace_root '' $PWD | string match -rg '^/([^/]+)')
    end
end && _workspace_root

function _workspace_git -d "execute git command with workspace config"
    set -l git_config $_workspace_root/.ws/.git_working_dir
    command git -C $git_config $argv
end

function _workspace_name -a branch -d "standardize branch name to worktree name"
    string replace -a -r "[\s/]" - "$argv"
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

function _workspace_setup -e workspace_setup -a worktree -d "run init script for workspace"
    test -f $worktree/package.json && begin
        fish --private -c "
            cd $worktree
            npm install --silent --prefer-offline &>/dev/null
        "
    end
end

function _workspace_remember -e fish_prompt -d "remember last working space"
    set -U _workspace_last_worktree $_workspace_root/$_workspace
end

set -q ws_remember && test "$PWD" = "$HOME" && cd $_workspace_last_worktree

abbr -a w workspace
abbr -a wa workspace add
abbr -a wco workspace checkout
abbr -a wp workspace pull
abbr -a wl workspace list
abbr -a wls workspace list
abbr -a wr workspace remove
abbr -a wrm workspace remove
