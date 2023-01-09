#!/usr/bin/env sh

# Script to connect to our servers via AWS SSM
#
# Uses fzf to quickly select wanted server
#
# Requires:
# fzf, jq

set -u -o pipefail

# Get server information, we need the name for display, and hostname to connect via SSM
servers=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].{ssmName:InstanceId,dns:PublicDnsName,name:Tags[?Key=='Name']|[0].Value}")

# * jq outputs name and ssmName with a special separator character (||) so we can
#   split on that later, this is to work around spaces in machine names
# * sort -V => sort by "version", so staging2 staging20 etc are sorted naturally
# * column uses our || separator to neatly divide our output into two columns
# * fzf - narrow down the result set
# * rev - cut - rev magic is to split on space, and get the first (final) part
target=$(echo $servers | jq -r '.[][] | "\(.name)||\(.ssmName)"' | sort -rV | column -t -s '||' | fzf | rev | cut -f1 -d$' ' | rev)
echo "Connecting to $target ..."

aws ssm start-session --target $target
