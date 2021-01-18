set -q __workspace_plugin_initialized; and exit 0

abbr --add w workspace
abbr --add wa workspace add
abbr --add wco workspace checkout
abbr --add wls workspace list
abbr --add wrm workspace remove

set -U __workspace_plugin_initialized (date)
