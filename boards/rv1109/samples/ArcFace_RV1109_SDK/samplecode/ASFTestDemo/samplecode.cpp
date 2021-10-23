#include <iostream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include "arcsoft_face_sdk.h"
#include "amcomdef.h"
#include "asvloffscreen.h"
#include "merror.h"

using namespace std;

//测试数据，从开发者中心获取替换
#define APPID "D617np8jyKt1jN9gMr7ENbXzAmrykzWndGM8d68Ucafc"
#define SDKKEY "G1VJLUSqc6XnWfra39jcuL8Gf42Tei6AfoTJWDXkgDGx"
#define ACTIVEKEY "9851-113X-73WR-NXBB"  //186.216


#define NSCALE 27
#define FACENUM	10  //支持检测的人脸数不超过10个

#define SafeFree(p) { if ((p)) free(p); (p) = NULL; }
#define SafeArrayDelete(p) { if ((p)) delete [] (p); (p) = NULL; } 
#define SafeDelete(p) { if ((p)) delete (p); (p) = NULL; }

int ColorSpaceConversion(MInt32 width, MInt32 height, MInt32 format, MUInt8* imgData, ASVLOFFSCREEN& offscreen);
void timestampToTime(char* timeStamp, char* dateTime, int dateTimeSize);

void printSDKInfo()
{
    printf("\n************* ArcFace SDK Info *****************\n");
    MRESULT res = MOK;
    res = ASFOnlineActivation(APPID, SDKKEY, ACTIVEKEY);
//    res = ASFOfflineActivation("85T1113W313MLCMD.dat");
    if (MOK != res && MERR_ASF_ALREADY_ACTIVATED != res)
        printf("ASFOnlineActivation failed: %x\n", res);
    else
        printf("ASFOnlineActivation sucess************: %x\n", res);

    //采集当前设备信息，用于离线激活
    char* deviceInfo = NULL;
    res = ASFGetActiveDeviceInfo(&deviceInfo);
    if (res != MOK) {
        printf("ASFGetActiveDeviceInfo failed: %x\n", res);
    } else {
        printf("ASFGetActiveDeviceInfo sucess: %s\n", deviceInfo);
    }

    //获取激活文件信息
    ASF_ActiveFileInfo activeFileInfo = { 0 };
    res = ASFGetActiveFileInfo(&activeFileInfo);
    if (res != MOK){
        printf("ASFGetActiveFileInfo failed: %x\n", res);
    } else {
        //这里仅获取了有效期时间，还需要其他信息直接打印即可
        char startDateTime[32];
        timestampToTime(activeFileInfo.startTime, startDateTime, 32);
        printf("startTime: %s\n", startDateTime);
        char endDateTime[32];
        timestampToTime(activeFileInfo.endTime, endDateTime, 32);
        printf("endTime: %s\n", endDateTime);
    }

    //SDK版本信息
    const ASF_VERSION version = ASFGetVersion();
    printf("\nVersion:%s\n", version.Version);
    printf("BuildDate:%s\n", version.BuildDate);
    printf("CopyRight:%s\n", version.CopyRight);
}


int main(int argc, char* argv[])
{
    //激活与打印一些信息
    printSDKInfo();

	printf("\n************* Face Recognition *****************\n");
	MRESULT res = MOK;

	//初始化引擎
	MHandle handle = NULL;
    MInt32 initMask = ASF_FACE_DETECT | ASF_FACERECOGNITION | ASF_IMAGEQUALITY |
            ASF_AGE | ASF_GENDER | ASF_FACE3DANGLE | ASF_LIVENESS | ASF_IR_LIVENESS |
            ASF_FACESHELTER | ASF_MASKDETECT | ASF_FACELANDMARK;
	res = ASFInitEngine(ASF_DETECT_MODE_IMAGE, ASF_OP_0_ONLY,
	        NSCALE, FACENUM, initMask, &handle);
	if (res != MOK)
		printf("ASFInitEngine failed: %x\n", res);
	else
		printf("ASFInitEngine sucess: %x\n", res);

	/*********以下三张图片均存在，图片保存在 ./images/ 文件夹下*********/
	
	//可见光图像 NV21格式裸数据
	char* picPath1 = "./images/640x480_1.NV21";
    int Width1 = 640;
    int Height1 = 480;
	int Format1 = ASVL_PAF_NV21;
	MUInt8* imageData1 = (MUInt8*)malloc(Height1*Width1*3/2);
	FILE* fp1 = fopen(picPath1, "rb");


	//可见光图像 NV21格式裸数据
	char* picPath2 = "./images/640x480_2.NV21";
	int Width2 = 640;
	int Height2 = 480;
	int Format2 = ASVL_PAF_NV21;
	MUInt8* imageData2 = (MUInt8*)malloc(Height2*Width2*3/2);
	FILE* fp2 = fopen(picPath2, "rb");
	
	//红外图像 NV21格式裸数据
	char* picPath3 = "./images/640x480_3.NV21";
	int Width3 = 640;
	int Height3 = 480;
	int Format3 = ASVL_PAF_GRAY;
	MUInt8* imageData3 = (MUInt8*)malloc(Height3*Width3);	//只读NV21前2/3的数据为灰度数据
	FILE* fp3 = fopen(picPath3, "rb");

	if (fp1 && fp2 && fp3)
	{
		fread(imageData1, 1, Height1*Width1*3/2, fp1);	//读NV21裸数据
		fclose(fp1);
		fread(imageData2, 1, Height2*Width2*3/2, fp2);	//读NV21裸数据
		fclose(fp2);
		fread(imageData3, 1, Height3*Width3, fp3);		//读NV21前2/3的数据,用于红外活体检测
		fclose(fp3);

        //第一张人脸
        ASVLOFFSCREEN offscreen1 = {0};
        ColorSpaceConversion(Width1, Height1, ASVL_PAF_NV21, imageData1, offscreen1);

        ASF_MultiFaceInfo detectedFaces1 = {0};
        ASF_SingleFaceInfo SingleDetectedFaces = {0};
        ASF_FaceFeature feature1 = {0};
        ASF_FaceFeature copyfeature1 = {0};

        res = ASFDetectFacesEx(handle, &offscreen1, &detectedFaces1);
        if (res != MOK || detectedFaces1.faceNum < 1) {
            printf("%s ASFDetectFaces 1 failed: %x\n", picPath1, res);
        } else {
            SingleDetectedFaces.faceRect.left = detectedFaces1.faceRect[0].left;
            SingleDetectedFaces.faceRect.top = detectedFaces1.faceRect[0].top;
            SingleDetectedFaces.faceRect.right = detectedFaces1.faceRect[0].right;
            SingleDetectedFaces.faceRect.bottom = detectedFaces1.faceRect[0].bottom;
            SingleDetectedFaces.faceOrient = detectedFaces1.faceOrient[0];

            // 第一张认为是注册照，注册照要求不戴口罩
            res = ASFFaceFeatureExtractEx(handle, &offscreen1, &SingleDetectedFaces, &feature1, ASF_REGISTER, 0);
            if (res != MOK) {
                printf("%s ASFFaceFeatureExtractEx 1 failed: %x\n", picPath1, res);
            } else {
                //拷贝feature，否则第二次进行特征提取，会覆盖第一次特征提取的数据，导致比对的结果为1
                copyfeature1.featureSize = feature1.featureSize;
                copyfeature1.feature = (MByte *) malloc(feature1.featureSize);
                memset(copyfeature1.feature, 0, feature1.featureSize);
                memcpy(copyfeature1.feature, feature1.feature, feature1.featureSize);
                printf("%s ASFFaceFeatureExtractEx 1 sucessed: %x\n", picPath1, res);
            }
        }


        //设置遮挡检测阈值
        MFloat ShelterThreshhold = 0.8f;
        res = ASFSetFaceShelterParam(handle, ShelterThreshhold);
        if (res != MOK) {
            printf("ASFSetFaceShelterParam failed: %x\n", res);
        }

        //第二张人脸
        ASVLOFFSCREEN offscreen2 = {0};
        ColorSpaceConversion(Width2, Height2, ASVL_PAF_NV21, imageData2, offscreen2);

        ASF_MultiFaceInfo detectedFaces2 = {0};
        ASF_FaceFeature feature2 = {0};
        ASF_MaskInfo maskInfo = {0};              //是否带口罩
        res = ASFDetectFacesEx(handle, &offscreen2, &detectedFaces2);
        if (res != MOK || detectedFaces2.faceNum < 1) {
            printf("%s ASFDetectFacesEx 2 failed: %x\n", picPath2, res);
        } else {
            SingleDetectedFaces.faceRect.left = detectedFaces2.faceRect[0].left;
            SingleDetectedFaces.faceRect.top = detectedFaces2.faceRect[0].top;
            SingleDetectedFaces.faceRect.right = detectedFaces2.faceRect[0].right;
            SingleDetectedFaces.faceRect.bottom = detectedFaces2.faceRect[0].bottom;
            SingleDetectedFaces.faceOrient = detectedFaces2.faceOrient[0];

            MFloat imageQualityConfidenceLevel;
            res = ASFImageQualityDetectEx(handle, &offscreen2, &SingleDetectedFaces, &imageQualityConfidenceLevel);
            if (res == MOK) {
                printf("ASFImageQualityDetectEx 2 sucessed: %f\n", imageQualityConfidenceLevel);
            } else {
                printf("ASFImageQualityDetectEx 2 failed: %x\n", res);
            }

            // 检测是否戴口罩
            MInt32 proMask = ASF_MASKDETECT;
            res = ASFProcessEx(handle, &offscreen2, &detectedFaces2, proMask);
            if (res != MOK) {
                printf("ASFProcessEx 2 failed: %x\n", res);
            } else {
                printf("ASFProcessEx 2 sucessed: %x\n", res);
            }

            // 获取是否戴口罩
            res = ASFGetMask(handle, &maskInfo);
            if (res != MOK) {
                printf("ASFGetMask failed: %x\n", res);
            } else {
                printf("ASFGetMask sucessed: %d\n", maskInfo.maskArray[0]);
            }

            // 作为预览模式下的识别照
            res = ASFFaceFeatureExtractEx(handle, &offscreen2, &SingleDetectedFaces, &feature2,
                                          ASF_RECOGNITION, maskInfo.maskArray[0]);
            if (res != MOK) {
                printf("%s ASFFaceFeatureExtractEx 2 failed: %x\n", picPath2, res);
            } else {
                printf("%s ASFFaceFeatureExtractEx 2 sucess: %x\n", picPath2, res);
            }
        }

        //比对之前可加业务逻辑
        //口罩	遮挡	提示语
        // 0	 0	    请佩戴口罩
        // 0	 1	    请佩戴口罩
        // 1	 0	    请正确佩戴
        // 1	 1	    佩戴正确，可识别

        // 单人脸特征比对
        MFloat confidenceLevel;
        res = ASFFaceFeatureCompare(handle, &copyfeature1, &feature2, &confidenceLevel,
                maskInfo.maskArray[0], ASF_LIFE_PHOTO);
        if (res != MOK) {
            printf("ASFFaceFeatureCompare failed: %x\n", res);
        } else {
            printf("ASFFaceFeatureCompare sucess: %lf\n", confidenceLevel);
        }

        printf("\n************* Face Process *****************\n");
        //设置活体置信度 SDK内部默认值为 IR：0.7  RGB：0.5（无特殊需要，可以不设置）
        ASF_LivenessThreshold threshold = {0};
        threshold.thresholdmodel_BGR = 0.5;
        threshold.thresholdmodel_IR = 0.7;
        res = ASFSetLivenessParam(handle, &threshold);
        if (res != MOK) {
            printf("ASFSetLivenessParam failed: %x\n", res);
        }

        // 人脸信息检测
        MInt32 processMask = ASF_FACE3DANGLE | ASF_LIVENESS | ASF_AGE | ASF_GENDER |
                             ASF_FACESHELTER | ASF_MASKDETECT | ASF_FACELANDMARK;
        res = ASFProcessEx(handle, &offscreen2, &detectedFaces2, processMask);
        if (res != MOK)
            printf("ASFProcessEx 2 failed: %x\n", res);
        else
            printf("ASFProcessEx 2 sucess: %x\n", res);

        // 获取年龄
        ASF_AgeInfo ageInfo = {0};
        res = ASFGetAge(handle, &ageInfo);
        if (res != MOK || ageInfo.num < 1)
            printf("%s ASFGetAge 2 failed: %x\n", picPath2, res);
        else
            printf("%s First face 2 age: %d\n", picPath2, ageInfo.ageArray[0]);

        // 获取性别
        ASF_GenderInfo genderInfo = {0};
        res = ASFGetGender(handle, &genderInfo);
        if (res != MOK || genderInfo.num < 1)
            printf("%s ASFGetGender 2 failed: %x\n", picPath2, res);
        else
            printf("%s First face 2 gender: %d\n", picPath2, genderInfo.genderArray[0]);

        // 获取3D角度
        ASF_Face3DAngle angleInfo = {0};
        res = ASFGetFace3DAngle(handle, &angleInfo);
        if (res != MOK || angleInfo.num < 1)
            printf("%s ASFGetFace3DAngle 2 failed: %x\n", picPath2, res);
        else
            printf("%s First face 3dAngle: roll: %lf yaw: %lf pitch: %lf\n", picPath2, angleInfo.roll[0],
                   angleInfo.yaw[0], angleInfo.pitch[0]);

        //获取活体信息
        ASF_LivenessInfo rgbLivenessInfo = {0};
        res = ASFGetLivenessScore(handle, &rgbLivenessInfo);
        if (res != MOK || rgbLivenessInfo.num < 1)
            printf("ASFGetLivenessScore 2 failed: %x\n", res);
        else
            printf("ASFGetLivenessScore 2 sucess: %d\n", rgbLivenessInfo.isLive[0]);

        //获取遮挡结果
        ASF_FaceShelter rgbFaceShelterInfo = {0};
        res = ASFGetFaceShelter(handle, &rgbFaceShelterInfo);
        if (res != MOK || rgbFaceShelterInfo.num < 1)
            printf("ASFGetFaceShelter 2 failed: %x\n", res);
        else
            printf("FaceShelter: %d\n", rgbFaceShelterInfo.FaceShelter[0]);

        //获取口罩检测结果
        ASF_MaskInfo rgbMaskInfo = {0};
        res = ASFGetMask(handle, &rgbMaskInfo);
        if (res != MOK || rgbMaskInfo.num < 1)
            printf("ASFGetMask failed: %x\n", res);
        else
            printf("Mask: %d\n", rgbMaskInfo.maskArray[0]);

        //获取额头区域
        ASF_LandMarkInfo headLandMarkInfo = {0};
        res = ASFGetFaceLandMark(handle, &headLandMarkInfo);
        if (res != MOK)
            printf("ASFGetFaceLandMark failed: %x\n", res);
        else
            printf("ASFGetFaceLandMark sucessed: %d\n", headLandMarkInfo.num);


        printf("\n**********IR LIVENESS*************\n");

        //第三张人脸IR图像
        ASVLOFFSCREEN offscreen3 = {0};
        ColorSpaceConversion(Width3, Height3, ASVL_PAF_GRAY, imageData3, offscreen3);

        ASF_MultiFaceInfo detectedFaces3 = {0};
        for(int i = 0; i < 100; i++)
        {
            res = ASFDetectFacesEx(handle, &offscreen3, &detectedFaces3);
            if(res == MOK && detectedFaces3.faceNum){
                break;
            }
        }
        if (res != MOK)
            printf("ASFDetectFacesEx failed: %x\n", res);
        else
            printf("Face num: %d\n", detectedFaces3.faceNum);

        //IR图像活体检测
        MInt32 processIRMask = ASF_IR_LIVENESS;
        res = ASFProcessEx_IR(handle, &offscreen3, &detectedFaces3, processIRMask);
        if (res != MOK)
            printf("ASFProcessEx_IR failed: %x\n", res);
        else
            printf("ASFProcessEx_IR sucess: %x\n", res);

        //获取IR活体信息
        ASF_LivenessInfo irLivenessInfo = {0};
        res = ASFGetLivenessScore_IR(handle, &irLivenessInfo);
        if (res != MOK || irLivenessInfo.num < 1)
            printf("ASFGetLivenessScore_IR failed: %x\n", res);
        else
            printf("IR Liveness: %d\n", irLivenessInfo.isLive[0]);

        //释放内存
        SafeFree(copyfeature1.feature);
        SafeArrayDelete(imageData1);
        SafeArrayDelete(imageData2);
        SafeArrayDelete(imageData3);

		//反初始化
		res = ASFUninitEngine(handle);
		if (res != MOK)
			printf("ASFUninitEngine failed: %x\n", res);
		else
			printf("ASFUninitEngine sucess: %x\n", res);
	}
	else
	{
		printf("No pictures found.\n");
	}
    return 0;
}


//时间戳转换为日期格式
void timestampToTime(char* timeStamp, char* dateTime, int dateTimeSize)
{
    time_t tTimeStamp = atoll(timeStamp);
    struct tm* pTm = gmtime(&tTimeStamp);
    strftime(dateTime, dateTimeSize, "%Y-%m-%d %H:%M:%S", pTm);
}

//图像颜色格式转换
int ColorSpaceConversion(MInt32 width, MInt32 height, MInt32 format, MUInt8* imgData, ASVLOFFSCREEN& offscreen)
{
    offscreen.u32PixelArrayFormat = (unsigned int)format;
    offscreen.i32Width = width;
    offscreen.i32Height = height;

    switch (offscreen.u32PixelArrayFormat)
    {
        case ASVL_PAF_RGB24_B8G8R8:
            offscreen.pi32Pitch[0] = offscreen.i32Width * 3;
            offscreen.ppu8Plane[0] = imgData;
            break;
        case ASVL_PAF_I420:
            offscreen.pi32Pitch[0] = width;
            offscreen.pi32Pitch[1] = width >> 1;
            offscreen.pi32Pitch[2] = width >> 1;
            offscreen.ppu8Plane[0] = imgData;
            offscreen.ppu8Plane[1] = offscreen.ppu8Plane[0] + offscreen.i32Height*offscreen.i32Width;
            offscreen.ppu8Plane[2] = offscreen.ppu8Plane[0] + offscreen.i32Height*offscreen.i32Width * 5 / 4;
            break;
        case ASVL_PAF_NV12:
        case ASVL_PAF_NV21:
            offscreen.pi32Pitch[0] = offscreen.i32Width;
            offscreen.pi32Pitch[1] = offscreen.pi32Pitch[0];
            offscreen.ppu8Plane[0] = imgData;
            offscreen.ppu8Plane[1] = offscreen.ppu8Plane[0] + offscreen.pi32Pitch[0] * offscreen.i32Height;
            break;
        case ASVL_PAF_YUYV:
        case ASVL_PAF_DEPTH_U16:
            offscreen.pi32Pitch[0] = offscreen.i32Width * 2;
            offscreen.ppu8Plane[0] = imgData;
            break;
        case ASVL_PAF_GRAY:
            offscreen.pi32Pitch[0] = offscreen.i32Width;
            offscreen.ppu8Plane[0] = imgData;
            break;
        default:
            return 0;
    }
    return 1;
}


