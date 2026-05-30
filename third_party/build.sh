#!/bin/bash

set -e

script_dir="$(dirname "$(readlink -f -- "$0")")"
repo_dir="$(dirname "$script_dir")"
out_dir="$repo_dir/apks"

export LD_LIBRARY_PATH="$script_dir/aapt/"
export PATH="$script_dir/aapt/:$PATH"

if [ "$#" -eq 1 ]; then
	if [ -d "$1" ]; then
		makes="$(find "$1" -name Android.mk -exec readlink -f -- '{}' \;)"
	else
		makes="$(readlink -f -- "$1")"
	fi
else
	makes="$(find "$repo_dir/src" -name Android.mk)"
fi

cd "$script_dir"
mkdir -p "$out_dir"

echo "$makes" | while read -r f; do
	name="$(sed -nE 's/LOCAL_PACKAGE_NAME.*:\=\s*(.*)/\1/p' "$f")"
	grep -q overlay <<<"$name" || continue
	echo "Generating $name"

	path="$(dirname "$f")"
	aapt package -f -F "${name}-unsigned.apk" -M "$path/AndroidManifest.xml" -S "$path/res" -I android.jar
	LD_LIBRARY_PATH=./signapk/ java -jar signapk/signapk.jar keys/platform.x509.pem keys/platform.pk8 "${name}-unsigned.apk" "${name}.apk"
	rm -f "${name}-unsigned.apk"
	mv "${name}.apk" "$out_dir/"
done
