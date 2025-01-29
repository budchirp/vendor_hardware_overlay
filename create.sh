if [ -d "apks" ]; then
	rm -rf apks/
fi

mkdir -p apks/

./build/build.sh
