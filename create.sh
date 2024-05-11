if [ -d "apks" ]; then
	rm -rf apks/
fi

mkdir -p apks/

echo "Building..."
./build/build.sh
echo "Done!"

echo "Copying apks..."
cp ./apks/*.apk ./module/system/product/overlay/
echo "Done!"
