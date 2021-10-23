ArcFaceGo_File="ArcFaceGo_1.0.1.121837.tar"
ArcFaceServer_File="ArcFaceServer_1.0.1.121839.tar"
dest_path="/userdata/arc/"
adb shell mkdir $dest_path
echo Uploading...
adb push "$ArcFaceGo_File"  $dest_path
adb push "$ArcFaceServer_File" $dest_path
adb push install.sh $dest_path
adb push start_app.sh $dest_path
echo Installing...
adb shell mv /etc/init.d/S98_lunch_init /
adb shell mv /etc/init.d/S06_QFacialGate /
adb push S99_ArcFaceGo /etc/init.d/
adb shell chmod +x /etc/init.d/S06_ArcFaceGo
adb shell chmod +x $dest_path/start_app.sh
adb shell chmod +x $dest_path/install.sh
adb shell $dest_path/install.sh
echo done
