#!/usr/bin/python
#coding=utf-8

from any_open_api import AnyiOSOpenAPI
import coreios
import file_operate

def script(SDK, work_dir, target_name, usrSDKConfig, SDKDestDir, project):
    api_obj = AnyiOSOpenAPI(SDK, work_dir, target_name, usrSDKConfig, SDKDestDir, project)
    
    api_obj.add_ldflags("-all_load -lstdc++")
    api_obj.add_plist_url_schemes(api_obj.get_param_value("TZgameID"),"taozi","taozi","")
    api_obj.add_plist_queries_schemes("TZGame mqq")

    api_obj.add_plist_row("NSCameraUsageDescription", u"访问相机")
    api_obj.add_plist_row("NSMicrophoneUsageDescription", u"访问麦克风")
    api_obj.add_plist_row("NSPhotoLibraryUsageDescription", u"使用相册保存图片")

    api_obj.add_delegate_header("<TZSdk/TZGameSdk.h>")

    api_obj.add_delegate_code("sourceApplication","- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation","[[TZGameSdk sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];")

    api_obj.add_delegate_code("options","- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options","[[TZGameSdk sharedInstance] application:app openURL:url options:options];")
    
    api_obj.add_delegate_code("applicationWillEnterForeground","- (void)applicationWillEnterForeground:(UIApplication *)application"," [[TZGameSdk sharedInstance] willEnterForeground];")

    core = ""
    if api_obj.get_param_value("TZtrackKey") == "":
        core = "[[TZGameSdk sharedInstance] applicationDidFinishLaunchingWithTrackKey:nil];"
    else:
        core = "[[TZGameSdk sharedInstance] applicationDidFinishLaunchingWithTrackKey:"+api_obj.get_param_value("TZtrackKey")+"];"
    api_obj.add_delegate_code("didFinishLaunchingWithOptions","- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions",core)

