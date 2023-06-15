#!/bin/bash

set -e

export LD_LIBRARY_PATH=./aapt/
export PATH=./aapt/:$PATH

script_dir="$(dirname "$(readlink -f -- "$0")")"
if [ "$#" -eq 1 ]; then
	if [ -d "$1" ]; then
		makes="$(find "$1" -name Android.mk -exec readlink -f -- '{}' \;)"

	else
		makes="$(readlink -f -- "$1")"
	fi
else
	cd "$script_dir"
	makes="$(find "$PWD/.." -name Android.mk)"
fi

cd "$script_dir"

echo "$makes" | while read -r f; do
	name="$(sed -nE 's/LOCAL_PACKAGE_NAME.*:\=\s*(.*)/\1/p' "$f")"
	grep -q overlay <<<"$name" || continue
	echo "Generating $name"

	path="$(dirname "$f")"
	aapt package -f -F "${name}-unsigned.apk" -M "$path/AndroidManifest.xml" -S "$path/res" -I android.jar
	LD_LIBRARY_PATH=./signapk/ java -jar signapk/signapk.jar keys/platform.x509.pem keys/platform.pk8 "${name}-unsigned.apk" "${name}.apk"
	rm -f "${name}-unsigned.apk"
	mv "${name}.apk" ../apks/
done
