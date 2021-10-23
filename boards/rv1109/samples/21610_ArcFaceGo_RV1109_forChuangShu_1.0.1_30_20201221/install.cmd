set ArcFaceGo_File="ArcFaceGo_1.0.1.121837.tar"
set ArcFaceServer_File="ArcFaceServer_1.0.1.121839.tar"
set dest_path="/userdata/arc"

pushd %~dp0
PATH %CD%\platform-tools;%PATH%
adb disconnect

echo Uploading...
adb push "%ArcFaceGo_File%" %dest_path%
adb push "%ArcFaceServer_File%" %dest_path%
adb push install.sh %dest_path%
adb push start_app.sh %dest_path%

echo Installing...
adb shell chmod +x %dest_path%/start_app.sh
adb shell chmod +x %dest_path%/install.sh
adb shell %dest_path%/install.sh
pause

