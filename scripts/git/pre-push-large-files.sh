#!/usr/bin/env bash
set -euo pipefail

# Blocks pushes that contain blobs larger than PRE_PUSH_MAX_FILE_BYTES (default 50 MB).
# Override threshold temporarily:
#   PRE_PUSH_MAX_FILE_BYTES=100000000 git push

MAX_FILE_BYTES="${PRE_PUSH_MAX_FILE_BYTES:-50000000}"
ZERO_OID_REGEX='^0+$'

format_bytes() {
	local bytes="$1"
	awk -v b="$bytes" 'BEGIN {
		split("B KB MB GB TB", units, " ");
		i = 1;
		while (b >= 1024 && i < 5) { b /= 1024; i++; }
		printf "%.2f %s", b, units[i];
	}'
}

declare -a ranges=()
while read -r local_ref local_sha remote_ref remote_sha; do
	if [[ -z "${local_sha:-}" ]]; then
		continue
	fi

	# Deleted ref; nothing new to scan.
	if [[ "$local_sha" =~ $ZERO_OID_REGEX ]]; then
		continue
	fi

	if [[ "$remote_sha" =~ $ZERO_OID_REGEX ]]; then
		ranges+=("$local_sha")
	else
		ranges+=("$remote_sha..$local_sha")
	fi
done

if [[ ${#ranges[@]} -eq 0 ]]; then
	exit 0
fi

declare -A seen=()
declare -a offenders=()

for range in "${ranges[@]}"; do
	while read -r object_type object_id object_size object_path; do
		if [[ "$object_type" != "blob" ]]; then
			continue
		fi
		if [[ -z "${object_path:-}" ]]; then
			continue
		fi
		if (( object_size <= MAX_FILE_BYTES )); then
			continue
		fi

		if [[ -n "${seen[$object_id]:-}" ]]; then
			continue
		fi
		seen[$object_id]=1
		offenders+=("$object_size|$object_path|$object_id")
	done < <(
		git rev-list --objects "$range" |
		git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)'
	)
done

if [[ ${#offenders[@]} -eq 0 ]]; then
	exit 0
fi

echo ""
echo "Push blocked: found file(s) larger than $(format_bytes "$MAX_FILE_BYTES") in outgoing commits."
echo ""
for row in "${offenders[@]}"; do
	IFS='|' read -r size path oid <<< "$row"
	echo "  - $path ($(format_bytes "$size"), blob $oid)"
done

echo ""
echo "Why blocked: GitHub warns above 50 MB and rejects files above 100 MB."
echo "Suggested fixes:"
echo "  1) Remove the file(s) from commit history before pushing."
echo "  2) Use Git LFS for large assets: https://git-lfs.github.com/"
echo "  3) For one-off override (not recommended): PRE_PUSH_MAX_FILE_BYTES=100000000 git push"
echo ""

exit 1
