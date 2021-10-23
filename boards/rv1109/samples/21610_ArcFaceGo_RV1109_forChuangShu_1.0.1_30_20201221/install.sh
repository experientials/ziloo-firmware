#!/bin/bash
echo Unpacking...
dest_path="/userdata/" 

ArcFaceGo_File=`find / | grep ArcFaceGo_.*.tar |head -1 |awk '{print $1}'`
ArcFaceServer_File=`find / | grep ArcFaceServer_.*.tar |head -1 |awk '{print $1}'`

echo $ArcFaceGo_File
echo $dest_path

tar -xvf $ArcFaceGo_File -C $dest_path
rm $ArcFaceGo_File 

echo $ArcFaceServer_File
tar -xvf $ArcFaceServer_File -C $dest_path
rm $ArcFaceServer_File

exit 0
