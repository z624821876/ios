//
//  CCUtility.m
//  Nextcloud iOS
//
//  Created by Marino Faggiana on 02/02/16.
//  Copyright (c) 2017 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "CCUtility.h"
#import "CCGraphics.h"
#import "NCBridgeSwift.h"

#import <netinet/in.h>
#import <openssl/x509.h>
#import <openssl/bio.h>
#import <openssl/err.h>
#import <openssl/pem.h>

#define INTRO_MessageType       @"MessageType_"

#define E2E_PublicKey           @"EndToEndPublicKey_"
#define E2E_PrivateKey          @"EndToEndPrivateKey_"
#define E2E_Passphrase          @"EndToEndPassphrase_"
#define E2E_PublicKeyServer     @"EndToEndPublicKeyServer_"

@implementation CCUtility

#pragma --------------------------------------------------------------------------------------------
#pragma mark ======================= KeyChainStore ==================================
#pragma --------------------------------------------------------------------------------------------

+ (void)deleteAllChainStore
{
    [UICKeyChainStore removeAllItems];
    [UICKeyChainStore removeAllItemsForService:k_serviceShareKeyChain];
}

+ (void)storeAllChainInService
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    
    NSArray *items = store.allItems;
    
    for (NSDictionary *item in items) {
        
        [UICKeyChainStore setString:[item objectForKey:@"value"] forKey:[item objectForKey:@"key"] service:k_serviceShareKeyChain];
        [UICKeyChainStore removeItemForKey:[item objectForKey:@"key"]];
    }
}

#pragma ------------------------------ GET/SET

+ (NSString *)getVersion
{
    return [UICKeyChainStore stringForKey:@"version" service:k_serviceShareKeyChain];
}

+ (NSString *)setVersion
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    [UICKeyChainStore setString:version forKey:@"version" service:k_serviceShareKeyChain];
    
    return version;
}

+ (NSString *)getBuild
{
    return [UICKeyChainStore stringForKey:@"build" service:k_serviceShareKeyChain];
}

+ (NSString *)setBuild
{
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    [UICKeyChainStore setString:build forKey:@"build" service:k_serviceShareKeyChain];
    
    return build;
}

+ (NSString *)getBlockCode
{
    return [UICKeyChainStore stringForKey:@"blockcode" service:k_serviceShareKeyChain];
}

+ (void)setBlockCode:(NSString *)blockcode
{
    [UICKeyChainStore setString:blockcode forKey:@"blockcode" service:k_serviceShareKeyChain];
}

+ (BOOL)getSimplyBlockCode
{
    NSString *simplyBlockCode = [UICKeyChainStore stringForKey:@"simplyblockcode" service:k_serviceShareKeyChain];
    
    if (simplyBlockCode == nil) {
        
        [self setSimplyBlockCode:YES];
        return YES;
    }
    
    return [simplyBlockCode boolValue];
}

+ (void)setSimplyBlockCode:(BOOL)simply
{
    NSString *sSimply = (simply) ? @"true" : @"false";
    [UICKeyChainStore setString:sSimply forKey:@"simplyblockcode" service:k_serviceShareKeyChain];
}

+ (BOOL)getOnlyLockDir
{
    return [[UICKeyChainStore stringForKey:@"onlylockdir" service:k_serviceShareKeyChain] boolValue];
}

+ (void)setOnlyLockDir:(BOOL)lockDir
{
    NSString *sLockDir = (lockDir) ? @"true" : @"false";
    [UICKeyChainStore setString:sLockDir forKey:@"onlylockdir" service:k_serviceShareKeyChain];
}

+ (NSString *)getOrderSettings
{
    NSString *order = [UICKeyChainStore stringForKey:@"order" service:k_serviceShareKeyChain];
    
    if (order == nil) {
        
        [self setOrderSettings:@"fileName"];
        return @"fileName";
    }
    
    return order;
}

+ (void)setOrderSettings:(NSString *)order
{
    [UICKeyChainStore setString:order forKey:@"order" service:k_serviceShareKeyChain];
}

+ (BOOL)getAscendingSettings
{
    NSString *ascending = [UICKeyChainStore stringForKey:@"ascending" service:k_serviceShareKeyChain];
    
    if (ascending == nil) {
        
        [self setAscendingSettings:YES];
        return YES;
    }
    
    return [ascending boolValue];
}

+ (void)setAscendingSettings:(BOOL)ascendente
{
    NSString *sAscendente = (ascendente) ? @"true" : @"false";
    [UICKeyChainStore setString:sAscendente forKey:@"ascending" service:k_serviceShareKeyChain];
}

+ (NSString *)getGroupBySettings
{
    NSString *groupby = [UICKeyChainStore stringForKey:@"groupby" service:k_serviceShareKeyChain];
    
    if (groupby == nil) {
        
        [self setGroupBySettings:@"none"];
        return @"none";
    }
    
    return groupby;
}

+ (void)setGroupBySettings:(NSString *)groupby
{
    [UICKeyChainStore setString:groupby forKey:@"groupby" service:k_serviceShareKeyChain];
}

+ (BOOL)getIntro
{
    // Set compatibility old version don't touch me
    if ([[UICKeyChainStore stringForKey:[INTRO_MessageType stringByAppendingString:@"Intro"] service:k_serviceShareKeyChain] boolValue] == YES) {
        [CCUtility setIntro:YES];
        return YES;
    }
    
    return [[UICKeyChainStore stringForKey:@"intro" service:k_serviceShareKeyChain] boolValue];
}

+ (BOOL)getIntroMessageOldVersion
{
    NSString *key = [INTRO_MessageType stringByAppendingString:@"Intro"];
    
    return [[UICKeyChainStore stringForKey:key service:k_serviceShareKeyChain] boolValue];
}

+ (void)setIntro:(BOOL)set
{
    NSString *sIntro = (set) ? @"true" : @"false";
    [UICKeyChainStore setString:sIntro forKey:@"intro" service:k_serviceShareKeyChain];

}

+ (NSString *)getIncrementalNumber
{
    long number = [[UICKeyChainStore stringForKey:@"incrementalnumber" service:k_serviceShareKeyChain] intValue];
    
    number++;
    if (number >= 9999) number = 1;
    
    [UICKeyChainStore setString:[NSString stringWithFormat:@"%ld", number] forKey:@"incrementalnumber"];
    
    return [NSString stringWithFormat:@"%04ld", number];
}

+ (NSString *)getActiveAccountExt
{
    return [UICKeyChainStore stringForKey:@"activeAccountExt" service:k_serviceShareKeyChain];
}

+ (void)setActiveAccountExt:(NSString *)activeAccount
{
    [UICKeyChainStore setString:activeAccount forKey:@"activeAccountExt" service:k_serviceShareKeyChain];
}

+ (NSString *)getServerUrlExt
{
    return [UICKeyChainStore stringForKey:@"serverUrlExt" service:k_serviceShareKeyChain];
}

+ (void)setServerUrlExt:(NSString *)serverUrl
{
    [UICKeyChainStore setString:serverUrl forKey:@"serverUrlExt" service:k_serviceShareKeyChain];
}

+ (NSString *)getTitleServerUrlExt
{
    return [UICKeyChainStore stringForKey:@"titleServerUrlExt" service:k_serviceShareKeyChain];
}

+ (void)setTitleServerUrlExt:(NSString *)titleServerUrl
{
    [UICKeyChainStore setString:titleServerUrl forKey:@"titleServerUrlExt" service:k_serviceShareKeyChain];
}

+ (NSString *)getFileNameExt
{
    return [UICKeyChainStore stringForKey:@"fileNameExt" service:k_serviceShareKeyChain];
}

+ (void)setFileNameExt:(NSString *)fileName
{
    [UICKeyChainStore setString:fileName forKey:@"fileNameExt" service:k_serviceShareKeyChain];
}

+ (NSString *)getEmail
{
    return [UICKeyChainStore stringForKey:@"email" service:k_serviceShareKeyChain];
}

+ (void)setEmail:(NSString *)email
{
    [UICKeyChainStore setString:email forKey:@"email" service:k_serviceShareKeyChain];
}

+ (NSString *)getHint
{
    return [UICKeyChainStore stringForKey:@"hint" service:k_serviceShareKeyChain];
}

+ (void)setHint:(NSString *)hint
{
    [UICKeyChainStore setString:hint forKey:@"hint" service:k_serviceShareKeyChain];
}

+ (BOOL)getDirectoryOnTop
{
    NSString *valueString = [UICKeyChainStore stringForKey:@"directoryOnTop" service:k_serviceShareKeyChain];
    
    // Default TRUE
    if (valueString == nil) {
        [self setDirectoryOnTop:YES];
        return true;
    }
    
    return [valueString boolValue];
}

+ (void)setDirectoryOnTop:(BOOL)directoryOnTop
{
    NSString *sDirectoryOnTop = (directoryOnTop) ? @"true" : @"false";
    [UICKeyChainStore setString:sDirectoryOnTop forKey:@"directoryOnTop" service:k_serviceShareKeyChain];
}

+ (BOOL)getOriginalFileName:(NSString *)key
{
    return [[UICKeyChainStore stringForKey:key service:k_serviceShareKeyChain] boolValue];
}

+ (void)setOriginalFileName:(BOOL)value key:(NSString *)key
{
    NSString *sValue = (value) ? @"true" : @"false";
    [UICKeyChainStore setString:sValue forKey:key service:k_serviceShareKeyChain];
}

+ (NSString *)getFileNameMask:(NSString *)key
{
    NSString *mask = [UICKeyChainStore stringForKey:key service:k_serviceShareKeyChain];
    
    if (mask == nil)
        mask = @"";
    
    return mask;
}

+ (void)setFileNameMask:(NSString *)mask key:(NSString *)key
{
    [UICKeyChainStore setString:mask forKey:key service:k_serviceShareKeyChain];
}

+ (BOOL)getFileNameType:(NSString *)key
{
    return [[UICKeyChainStore stringForKey:key service:k_serviceShareKeyChain] boolValue];
}

+ (void)setFileNameType:(BOOL)prefix key:(NSString *)key
{
    NSString *sPrefix = (prefix) ? @"true" : @"false";
    [UICKeyChainStore setString:sPrefix forKey:key service:k_serviceShareKeyChain];
}

+ (BOOL)getFavoriteOffline
{
    return [[UICKeyChainStore stringForKey:@"favoriteOffline" service:k_serviceShareKeyChain] boolValue];
}

+ (void)setFavoriteOffline:(BOOL)offline
{
    NSString *sFavoriteOffline = (offline) ? @"true" : @"false";
    [UICKeyChainStore setString:sFavoriteOffline forKey:@"favoriteOffline" service:k_serviceShareKeyChain];
}

+ (BOOL)getActivityVerboseHigh
{
    return [[UICKeyChainStore stringForKey:@"activityVerboseHigh" service:k_serviceShareKeyChain] boolValue];
}

+ (void)setActivityVerboseHigh:(BOOL)high
{
    NSString *sHigh = (high) ? @"true" : @"false";
    [UICKeyChainStore setString:sHigh forKey:@"activityVerboseHigh" service:k_serviceShareKeyChain];
}

+ (BOOL)getShowHiddenFiles
{
    return [[UICKeyChainStore stringForKey:@"showHiddenFiles" service:k_serviceShareKeyChain] boolValue];
}

+ (void)setShowHiddenFiles:(BOOL)show
{
    NSString *sShow = (show) ? @"true" : @"false";
    [UICKeyChainStore setString:sShow forKey:@"showHiddenFiles" service:k_serviceShareKeyChain];
}

+ (BOOL)getFormatCompatibility
{
    NSString *valueString = [UICKeyChainStore stringForKey:@"formatCompatibility" service:k_serviceShareKeyChain];
    
    // Default TRUE
    if (valueString == nil) {
        [self setFormatCompatibility:YES];
        return true;
    }
    
    return [valueString boolValue];
}

+ (void)setFormatCompatibility:(BOOL)set
{
    NSString *sSet = (set) ? @"true" : @"false";
    [UICKeyChainStore setString:sSet forKey:@"formatCompatibility" service:k_serviceShareKeyChain];
}

+ (NSString *)getEndToEndPublicKey:(NSString *)account
{
    NSString *key = [E2E_PublicKey stringByAppendingString:account];
    return [UICKeyChainStore stringForKey:key service:k_serviceShareKeyChain];
}

+ (void)setEndToEndPublicKey:(NSString *)account publicKey:(NSString *)publicKey
{
    NSString *key = [E2E_PublicKey stringByAppendingString:account];
    [UICKeyChainStore setString:publicKey forKey:key service:k_serviceShareKeyChain];
}

+ (NSString *)getEndToEndPrivateKey:(NSString *)account
{
    NSString *key = [E2E_PrivateKey stringByAppendingString:account];
    return [UICKeyChainStore stringForKey:key service:k_serviceShareKeyChain];
}

+ (void)setEndToEndPrivateKey:(NSString *)account privateKey:(NSString *)privateKey
{
    NSString *key = [E2E_PrivateKey stringByAppendingString:account];
    [UICKeyChainStore setString:privateKey forKey:key service:k_serviceShareKeyChain];
}

+ (NSString *)getEndToEndPassphrase:(NSString *)account
{
    NSString *key = [E2E_Passphrase stringByAppendingString:account];
    return [UICKeyChainStore stringForKey:key service:k_serviceShareKeyChain];
}

+ (void)setEndToEndPassphrase:(NSString *)account passphrase:(NSString *)passphrase
{
    NSString *key = [E2E_Passphrase stringByAppendingString:account];
    [UICKeyChainStore setString:passphrase forKey:key service:k_serviceShareKeyChain];
}

+ (NSString *)getEndToEndPublicKeyServer:(NSString *)account
{
    NSString *key = [E2E_PublicKeyServer stringByAppendingString:account];
    return [UICKeyChainStore stringForKey:key service:k_serviceShareKeyChain];
}

+ (void)setEndToEndPublicKeyServer:(NSString *)account publicKey:(NSString *)publicKey
{
    NSString *key = [E2E_PublicKeyServer stringByAppendingString:account];
    [UICKeyChainStore setString:publicKey forKey:key service:k_serviceShareKeyChain];
}

+ (BOOL)isEndToEndEnabled:(NSString *)account
{
    tableCapabilities *capabilities = [[NCManageDatabase sharedInstance] getCapabilitesWithAccount:account];

    NSString *publicKey = [self getEndToEndPublicKey:account];
    NSString *privateKey = [self getEndToEndPrivateKey:account];
    NSString *passphrase = [self getEndToEndPassphrase:account];
    NSString *publicKeyServer = [self getEndToEndPublicKeyServer:account];    
    
    if (passphrase.length > 0 && privateKey.length > 0 && publicKey.length > 0 && publicKeyServer.length > 0 && capabilities.endToEndEncryption) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}

+ (void)clearAllKeysEndToEnd:(NSString *)account
{
    [self setEndToEndPublicKey:account publicKey:nil];
    [self setEndToEndPrivateKey:account privateKey:nil];
    [self setEndToEndPassphrase:account passphrase:nil];
    [self setEndToEndPublicKeyServer:account publicKey:nil];
}

+ (BOOL)getDisableFilesApp
{
    return [[UICKeyChainStore stringForKey:@"disablefilesapp" service:k_serviceShareKeyChain] boolValue];
}

+ (void)setDisableFilesApp:(BOOL)disable
{
    NSString *sDisable = (disable) ? @"true" : @"false";
    [UICKeyChainStore setString:sDisable forKey:@"disablefilesapp" service:k_serviceShareKeyChain];
}

+ (void)setPushNotificationPublicKey:(NSData *)data
{
    [UICKeyChainStore setData:data forKey:@"ncPNPublicKey" service:k_serviceShareKeyChain];
}

+ (NSData *)getPushNotificationPublicKey
{
    return [UICKeyChainStore dataForKey:@"ncPNPublicKey" service:k_serviceShareKeyChain];
}

+ (void)setPushNotificationPrivateKey:(NSData *)data
{
    [UICKeyChainStore setData:data forKey:@"ncPNPrivateKey" service:k_serviceShareKeyChain];
}

+ (NSData *)getPushNotificationPrivateKey
{
    return [UICKeyChainStore dataForKey:@"ncPNPrivateKey" service:k_serviceShareKeyChain];
}

+ (void)setPushNotificationToken:(NSString *)token
{
    [UICKeyChainStore setString:token forKey:@"ncPushToken" service:k_serviceShareKeyChain];
}

+ (NSString *)getPushNotificationToken
{
    return [UICKeyChainStore stringForKey:@"ncPushToken" service:k_serviceShareKeyChain];
}

+ (NSInteger)getMediaWidthImage
{
    NSString *width = [UICKeyChainStore stringForKey:@"mediaWidthImage" service:k_serviceShareKeyChain];
    
    if (width == nil) {
        return 80;
    } else {
        return [width integerValue];
    }
}

+ (void)setMediaWidthImage:(NSInteger)width
{
    NSString *widthString = [@(width) stringValue];
    [UICKeyChainStore setString:widthString forKey:@"mediaWidthImage" service:k_serviceShareKeyChain];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ===== Various =====
#pragma --------------------------------------------------------------------------------------------

+ (NSString *)getUserAgent
{
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    return [NSString stringWithFormat:@"%@%@",@"Mozilla/5.0 (iOS) Nextcloud-iOS/",appVersion];
}

+ (NSString *)dateDiff:(NSDate *) convertedDate
{
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if (ti < 60) {
        // This minute
        return NSLocalizedString(@"_less_a_minute_", nil);
    } else if (ti < 3600) {
        // This hour
        int diff = round(ti / 60);
        return [NSString stringWithFormat:NSLocalizedString(@"_minutes_ago_", nil), diff];
    } else if (ti < 86400) {
        // This day
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:NSLocalizedString(@"_hours_ago_", nil), diff];
    } else if (ti < 86400 * 30) {
        // This month
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:NSLocalizedString(@"_days_ago_", nil), diff];
    } else {
        // Older than one month
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setFormatterBehavior:NSDateFormatterBehavior10_4];
        [df setDateStyle:NSDateFormatterMediumStyle];
        return [df stringFromDate:convertedDate];
    }
}


+ (NSDate *)dateEnUsPosixFromCloud:(NSString *)dateString
{
    NSDate *date = [NSDate date];
    NSError *error;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"EEE, dd MMM y HH:mm:ss zzz"];

    if (![dateFormatter getObjectValue:&date forString:dateString range:nil error:&error]) {
        NSLog(@"[LOG] Date '%@' could not be parsed: %@", dateString, error);
        date = [NSDate date];
    }

    return date;
}

+ (NSString *)transformedSize:(double)value
{
    NSString *string = [NSByteCountFormatter stringFromByteCount:value countStyle:NSByteCountFormatterCountStyleBinary];
    return string;
}

// Remove do not forbidden characters for Nextcloud Server
+ (NSString *)removeForbiddenCharactersServer:(NSString *)fileName
{
    NSArray *arrayForbiddenCharacters = [NSArray arrayWithObjects:@"/", nil];
    
    for (NSString *currentCharacter in arrayForbiddenCharacters) {
        fileName = [fileName stringByReplacingOccurrencesOfString:currentCharacter withString:@""];
    }
    
    return fileName;
}

// Remove do not forbidden characters for File System Server
+ (NSString *)removeForbiddenCharactersFileSystem:(NSString *)fileName
{
    NSArray *arrayForbiddenCharacters = [NSArray arrayWithObjects:@"\\",@"<",@">",@":",@"\"",@"|",@"?",@"*",@"/", nil];
    
    for (NSString *currentCharacter in arrayForbiddenCharacters) {
        fileName = [fileName stringByReplacingOccurrencesOfString:currentCharacter withString:@""];
    }
    
    return fileName;
}

+ (NSString*)stringAppendServerUrl:(NSString *)serverUrl addFileName:(NSString *)addFileName
{
    NSString *result;
    
    if (serverUrl == nil || addFileName == nil) return nil;
    if ([addFileName isEqualToString:@""]) return serverUrl;
    
    if ([serverUrl isEqualToString:@"/"]) result = [serverUrl stringByAppendingString:addFileName];
    else result = [NSString stringWithFormat:@"%@/%@", serverUrl, addFileName];
    
    return result;
}

+ (NSString *)createRandomString:(int)numChars
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: numChars];
    
    for (int i=0; i < numChars; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((unsigned int)[letters length]) % [letters length]]];
    }
    
    return [NSString stringWithFormat:@"%@", randomString];
}

+ (NSString *)createFileNameDate:(NSString *)fileName extension:(NSString *)extension
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH-mm-ss"];
    NSString *fileNameDate = [formatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@ %@.%@", fileName, fileNameDate, extension];
}

+ (NSString *)createFileName:(NSString *)fileName fileDate:(NSDate *)fileDate fileType:(PHAssetMediaType)fileType keyFileName:(NSString *)keyFileName keyFileNameType:(NSString *)keyFileNameType keyFileNameOriginal:(NSString *)keyFileNameOriginal
{
    BOOL addFileNameType = NO;
    
    // Original FileName ?
    if ([self getOriginalFileName:keyFileNameOriginal]) {
        return fileName;
    }
    
    NSString *numberFileName;
    if ([fileName length] > 8) numberFileName = [fileName substringWithRange:NSMakeRange(04, 04)];
    else numberFileName = [CCUtility getIncrementalNumber];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH-mm-ss"];
    NSString *fileNameDate = [formatter stringFromDate:fileDate];
    
    NSString *fileNameType = @"";
    if (fileType == PHAssetMediaTypeImage)
        fileNameType = NSLocalizedString(@"_photo_", nil);
    if (fileType == PHAssetMediaTypeVideo)
        fileNameType = NSLocalizedString(@"_video_", nil);
    if (fileType == PHAssetMediaTypeAudio)
        fileNameType = NSLocalizedString(@"_audio_", nil);
    if (fileType == PHAssetMediaTypeUnknown)
        fileNameType = NSLocalizedString(@"_unknown_", nil);

    // Use File Name Type
    if (keyFileNameType)
        addFileNameType = [CCUtility getFileNameType:keyFileNameType];
    
    NSString *fileNameExt = [[fileName pathExtension] lowercaseString];
    
    if (keyFileName) {
        
        fileName = [CCUtility getFileNameMask:keyFileName];
        
        if ([fileName length] > 0) {
            
            [formatter setDateFormat:@"dd"];
            NSString *dayNumber = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"MMM"];
            NSString *month = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"MM"];
            NSString *monthNumber = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"yyyy"];
            NSString *year = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"yy"];
            NSString *yearNumber = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"HH"];
            NSString *hour24 = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"hh"];
            NSString *hour12 = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"mm"];
            NSString *minute = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"ss"];
            NSString *second = [formatter stringFromDate:fileDate];
            [formatter setDateFormat:@"a"];
            NSString *ampm = [formatter stringFromDate:fileDate];
            
            // Replace string with date

            fileName = [fileName stringByReplacingOccurrencesOfString:@"DD" withString:dayNumber];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"MMM" withString:month];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"MM" withString:monthNumber];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"YYYY" withString:year];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"YY" withString:yearNumber];

            fileName = [fileName stringByReplacingOccurrencesOfString:@"HH" withString:hour24];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"hh" withString:hour12];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"mm" withString:minute];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"ss" withString:second];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"ampm" withString:ampm];

            if (addFileNameType)
                fileName = [NSString stringWithFormat:@"%@%@%@.%@", fileNameType, fileName, numberFileName, fileNameExt];
            else
                fileName = [NSString stringWithFormat:@"%@%@.%@", fileName, numberFileName, fileNameExt];
            
            fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
        } else {
            
            if (addFileNameType)
                fileName = [NSString stringWithFormat:@"%@ %@ %@.%@", fileNameType, fileNameDate, numberFileName, fileNameExt];
            else
                fileName = [NSString stringWithFormat:@"%@ %@.%@", fileNameDate, numberFileName, fileNameExt];
        }
        
    } else {
        
        if (addFileNameType)
            fileName = [NSString stringWithFormat:@"%@ %@ %@.%@", fileNameType, fileNameDate, numberFileName, fileNameExt];
        else
            fileName = [NSString stringWithFormat:@"%@ %@.%@", fileNameDate, numberFileName, fileNameExt];

    }
    
    return fileName;
}

+ (NSURL *)getDirectoryGroup
{
    NSURL *path = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[NCBrandOptions sharedInstance].capabilitiesGroups];
    return path;
}

+ (NSString *)getHomeServerUrlActiveUrl:(NSString *)activeUrl
{
    if (activeUrl == nil)
        return @"";
    
    return [activeUrl stringByAppendingString:k_webDAV];
}

+ (NSString *)getStringUser:(NSString *)activeUser activeUrl:(NSString *)activeUrl
{
    NSString *baseUrl = [activeUrl lowercaseString];
    NSString *dirUserBaseUrl = @"";

    if ([activeUser length] && [baseUrl length]) {
        
        if ([baseUrl hasPrefix:@"https://"]) baseUrl = [baseUrl substringFromIndex:8];
        if ([baseUrl hasPrefix:@"http://"]) baseUrl = [baseUrl substringFromIndex:7];
        
        dirUserBaseUrl = [NSString stringWithFormat:@"%@-%@", activeUser, baseUrl];
        dirUserBaseUrl = [[self removeForbiddenCharactersFileSystem:dirUserBaseUrl] lowercaseString];
    }
    
    return dirUserBaseUrl;
}

// Return path of User
+ (NSString *)getDirectoryActiveUser:(NSString *)activeUser activeUrl:(NSString *)activeUrl
{
    NSURL *dirGroup = [CCUtility getDirectoryGroup];
    NSString *user = activeUser;
    NSString *baseUrl = [activeUrl lowercaseString];
    NSString *dirUserBaseUrl = nil;
    NSString *dirApplicationUserGroup = nil;
    
    if ([user length] && [baseUrl length]) {
        
        if ([baseUrl hasPrefix:@"https://"]) baseUrl = [baseUrl substringFromIndex:8];
        if ([baseUrl hasPrefix:@"http://"]) baseUrl = [baseUrl substringFromIndex:7];
        
        dirUserBaseUrl = [NSString stringWithFormat:@"%@-%@", user, baseUrl];
        dirUserBaseUrl = [[self removeForbiddenCharactersFileSystem:dirUserBaseUrl] lowercaseString];
    } else return @"";
    
    dirApplicationUserGroup = [[dirGroup URLByAppendingPathComponent:k_appApplicationSupport] path];
    dirUserBaseUrl = [NSString stringWithFormat:@"%@/%@", dirApplicationUserGroup, dirUserBaseUrl];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: dirUserBaseUrl]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirUserBaseUrl withIntermediateDirectories:YES attributes:nil error:nil];
    }
        
    return dirUserBaseUrl;
}

// Return the path of directory Documents -> NSDocumentDirectory
+ (NSString *)getDirectoryDocuments
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [paths objectAtIndex:0];
}

+ (NSString *)getDirectoryReaderMetadata
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    return [NSString stringWithFormat:@"%@/Reader Metadata", [paths objectAtIndex:0]];
}

// Return the path of directory Audio
+ (NSString *)getDirectoryAudio
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    return [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], @"audio"];
}

// Return the path of directory Cetificates
+ (NSString *)getDirectoryCerificates
{
    NSString *path = [[[CCUtility getDirectoryGroup] URLByAppendingPathComponent:k_appCertificates] path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return path;
}

+ (NSString *)getDirectoryUserData
{
    NSString *path = [[[CCUtility getDirectoryGroup] URLByAppendingPathComponent:k_appUserData] path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return path;
}

+ (NSString *)getDirectoryProviderStorage
{
    NSString *path = [[[CCUtility getDirectoryGroup] URLByAppendingPathComponent:k_DirectoryProviderStorage] path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];

    return path;
}

+ (NSString *)getDirectoryProviderStorageFileID:(NSString *)fileID
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self getDirectoryProviderStorage], fileID];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];

    return path;
}

+ (NSString *)getDirectoryProviderStorageFileID:(NSString *)fileID fileNameView:(NSString *)fileNameView
{
    NSString *fileNamePath = [NSString stringWithFormat:@"%@/%@", [self getDirectoryProviderStorageFileID:fileID], fileNameView];
    
    // if do not exists create file 0 length
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileNamePath] == NO) {
        [[NSFileManager defaultManager] createFileAtPath:fileNamePath contents:nil attributes:nil];
    }
    
    return fileNamePath;
}

+ (NSString *)getDirectoryProviderStorageIconFileID:(NSString *)fileID fileNameView:(NSString *)fileNameView
{
    return [NSString stringWithFormat:@"%@/%@.ico", [self getDirectoryProviderStorageFileID:fileID], fileNameView];
}

+ (BOOL)fileProviderStorageExists:(NSString *)fileID fileNameView:(NSString *)fileNameView
{
    NSString *fileNamePath = [self getDirectoryProviderStorageFileID:fileID fileNameView:fileNameView];
    
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileNamePath error:nil] fileSize];
    
    if (fileSize > 0) return true;
    else return false;
}

+ (BOOL)fileProviderStorageIconExists:(NSString *)fileID fileNameView:(NSString *)fileNameView
{
    NSString *fileNamePath = [self getDirectoryProviderStorageIconFileID:fileID fileNameView:fileNameView];
    
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileNamePath error:nil] fileSize];
    
    if (fileSize > 0) return true;
    else return false;
}

+ (NSString *)getTitleSectionDate:(NSDate *)date
{
    NSString * title;
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    
    if ([date isEqualToDate:[CCUtility datetimeWithOutTime:[NSDate distantPast]]]) {
        
        title =  NSLocalizedString(@"_no_date_", nil);
        
    } else {
        
        title = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterFullStyle timeStyle:0];
        
        if ([date isEqualToDate:[CCUtility datetimeWithOutTime:today]])
            title = [NSString stringWithFormat:NSLocalizedString(@"_today_", nil)];
        
        if ([date isEqualToDate:[CCUtility datetimeWithOutTime:yesterday]])
            title = [NSString stringWithFormat:NSLocalizedString(@"_yesterday_", nil)];
    }
    
    return title;
}

+ (void)moveFileAtPath:(NSString *)atPath toPath:(NSString *)toPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:atPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:toPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:atPath toPath:toPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:atPath error:nil];
    }
}

+ (void)copyFileAtPath:(NSString *)atPath toPath:(NSString *)toPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:atPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:toPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:atPath toPath:toPath error:nil];
    }
}

+ (void)removeFileAtPath:(NSString *)atPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:atPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:atPath error:nil];
    }
}

+ (NSString *)deletingLastPathComponentFromServerUrl:(NSString *)serverUrl
{
    NSURL *url = [[NSURL URLWithString:[serverUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]] URLByDeletingLastPathComponent];
    NSString *pather = [[url absoluteString] stringByRemovingPercentEncoding];
    
    return [pather substringToIndex: [pather length] - 1];
}

+ (NSString *)firtsPathComponentFromServerUrl:(NSString *)serverUrl activeUrl:(NSString *)activeUrl
{
    NSString *firstPath = serverUrl;

    NSURL *serverUrlURL = [NSURL URLWithString:[serverUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSURL *activeUrlURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/", [activeUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], k_webDAV]];
    
    while ([[serverUrlURL absoluteString] isEqualToString:[activeUrlURL absoluteString]] == false) {
        firstPath = [serverUrlURL absoluteString];
        serverUrlURL = [serverUrlURL URLByDeletingLastPathComponent];
    }
    
    if ([firstPath hasSuffix:@"/"]) firstPath = [firstPath substringToIndex:[firstPath length] - 1];
    return firstPath;
}

+ (NSString *)getLastPathFromServerUrl:(NSString *)serverUrl activeUrl:(NSString *)activeUrl
{
    if ([serverUrl isEqualToString:activeUrl])
        return @"";
    
    NSURL *serverUrlURL = [NSURL URLWithString:[serverUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSString *fileName = [serverUrlURL lastPathComponent];

    return fileName;
}

+ (NSString *)returnPathfromServerUrl:(NSString *)serverUrl activeUrl:(NSString *)activeUrl
{
    NSString *path = [serverUrl stringByReplacingOccurrencesOfString:[activeUrl stringByAppendingString:k_webDAV] withString:@""];
    
    return path;
}
                                       
+ (NSString *)returnFileNamePathFromFileName:(NSString *)metadataFileName serverUrl:(NSString *)serverUrl activeUrl:(NSString *)activeUrl
{
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", [serverUrl stringByReplacingOccurrencesOfString:[CCUtility getHomeServerUrlActiveUrl:activeUrl] withString:@""], metadataFileName];
    
    if ([fileName hasPrefix:@"/"]) fileName = [fileName substringFromIndex:1];
    
    return fileName;
}

+ (NSArray *)createNameSubFolder:(PHFetchResult *)alassets
{
    NSMutableOrderedSet *datesSubFolder = [NSMutableOrderedSet new];
    
    for (PHAsset *asset in alassets) {
        
        NSDate *assetDate = asset.creationDate;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSString *yearString = [formatter stringFromDate:assetDate];
        if (yearString)
            [datesSubFolder addObject:yearString];
        
        [formatter setDateFormat:@"MM"];
        NSString *monthString = [formatter stringFromDate:assetDate];
        monthString = [NSString stringWithFormat:@"%@/%@", yearString, monthString];
        if (monthString)
            [datesSubFolder addObject:monthString];
    }
    
    return (NSArray *)datesSubFolder;
}

+ (BOOL)isDocumentModifiableExtension:(NSString *)fileExtension
{
    // Use UPPERCASE extension :
    
    return [@[@"TXT", @"MD", @"MARKDOWN", @"ORG"] containsObject:fileExtension];
}

+ (NSString *)getMimeType:(NSString *)fileNameView
{
    CFStringRef fileUTI = nil;
    NSString *returnFileUTI = nil;
    
    if ([fileNameView isEqualToString:@"."]) {
        
        return returnFileUTI;
        
    } else {
        CFStringRef fileExtension = (__bridge CFStringRef)[fileNameView pathExtension];
        NSString *ext = (__bridge NSString *)fileExtension;
        ext = ext.uppercaseString;
        fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        if (fileUTI != nil) {
            returnFileUTI = (__bridge NSString *)fileUTI;
            CFRelease(fileUTI);
        }
    }
    
    return returnFileUTI;
}

+ (NSString *)getDirectoryScan
{
    NSString *path = [[[CCUtility getDirectoryGroup] URLByAppendingPathComponent:k_appScan] path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return path;
}

+ (void)writeData:(NSData *)data fileNamePath:(NSString *)fileNamePath
{
    [data writeToFile:fileNamePath atomically:YES];
}

+ (NSString *)createDirectoyIDFromAccount:(NSString *)account serverUrl:(NSString *)serverUrl
{
    NSArray *arrayForbiddenCharacters = [NSArray arrayWithObjects:@"\\",@"<",@">",@":",@"\"",@"|",@"?",@"*",@"/", nil];
    
    for (NSString *currentCharacter in arrayForbiddenCharacters) {
        account = [account stringByReplacingOccurrencesOfString:currentCharacter withString:@""];
    }
    
    for (NSString *currentCharacter in arrayForbiddenCharacters) {
        serverUrl = [serverUrl stringByReplacingOccurrencesOfString:currentCharacter withString:@""];
    }
    
    return [[account stringByAppendingString:serverUrl] lowercaseString];
}

+ (NSString *)createMetadataIDFromAccount:(NSString *)account serverUrl:(NSString *)serverUrl fileNameView:(NSString *)fileNameView directory:(BOOL)directory
{
    NSString *metadataID =  [[[self createDirectoyIDFromAccount:account serverUrl:serverUrl] stringByAppendingString:fileNameView] lowercaseString];
    
    if (directory) {
        return [metadataID stringByAppendingString:@"-dir"];
    }
    
    return metadataID;
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ===== E2E Encrypted =====
#pragma --------------------------------------------------------------------------------------------

+ (NSString *)generateRandomIdentifier
{
    NSString *UUID = [[NSUUID UUID] UUIDString];
    
    return [[UUID stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
}

+ (BOOL)isFolderEncrypted:(NSString *)serverUrl account:(NSString *)account
{
    BOOL depth = NO;
    
    if (depth) {
        
        NSArray *directories = [[NCManageDatabase sharedInstance] getTablesDirectoryWithPredicate:[NSPredicate predicateWithFormat:@"account == %@ AND e2eEncrypted == 1 AND serverUrl BEGINSWITH %@", account, serverUrl] sorted:@"serverUrl" ascending:false];
        for (tableDirectory *directory in directories) {
            if ([serverUrl containsString:directory.serverUrl])
                return true;
        }
        
    } else {
        
        tableDirectory *directory = [[NCManageDatabase sharedInstance] getTableDirectoryWithPredicate:[NSPredicate predicateWithFormat:@"account == %@ AND e2eEncrypted == 1 AND serverUrl == %@", account, serverUrl]];
        if (directory != nil)
            return true;
    }
    
    return false;
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ===== CCMetadata =====
#pragma --------------------------------------------------------------------------------------------

+ (tableMetadata *)createMetadataWithAccount:(NSString *)account date:(NSDate *)date directory:(BOOL)directory fileID:(NSString *)fileID serverUrl:(NSString *)serverUrl fileName:(NSString *)fileName etag:(NSString *)etag size:(double)size status:(double)status url:(NSString *)url
{
    tableMetadata *metadata = [tableMetadata new];
    
    metadata.account = account;
    metadata.date = date;
    metadata.directory = directory;
    metadata.etag = etag;
    metadata.fileID = fileID;
    metadata.fileName = fileName;
    metadata.fileNameView = fileName;
    metadata.serverUrl = serverUrl;
    metadata.size = size;
    metadata.status = status;
    metadata.url = url;
    
    [self insertTypeFileIconName:fileName metadata:metadata];
    
    return metadata;
}

+ (tableMetadata *)trasformedOCFileToCCMetadata:(OCFileDto *)itemDto fileName:(NSString *)fileName serverUrl:(NSString *)serverUrl autoUploadFileName:(NSString *)autoUploadFileName autoUploadDirectory:(NSString *)autoUploadDirectory activeAccount:(NSString *)activeAccount isFolderEncrypted:(BOOL)isFolderEncrypted
{
    tableMetadata *metadata = [tableMetadata new];
    NSString *fileNameView;
    
    fileName = [CCUtility removeForbiddenCharactersServer:fileName];
    fileNameView = fileName;
    
    // E2EE find the fileName for fileNameView
    if (isFolderEncrypted) {
        tableE2eEncryption *tableE2eEncryption = [[NCManageDatabase sharedInstance] getE2eEncryptionWithPredicate:[NSPredicate predicateWithFormat:@"account == %@ AND serverUrl == %@ AND fileNameIdentifier == %@", activeAccount, serverUrl, fileName]];
        if (tableE2eEncryption)
            fileNameView = tableE2eEncryption.fileName;
    }
    
    metadata.account = activeAccount;
    metadata.date = [NSDate dateWithTimeIntervalSince1970:itemDto.date];
    metadata.directory = itemDto.isDirectory;
    metadata.e2eEncrypted = itemDto.isEncrypted;
    metadata.etag = itemDto.etag;
    metadata.favorite = itemDto.isFavorite;
    metadata.fileID = itemDto.ocId;
    metadata.fileName = fileName;
    metadata.fileNameView = fileNameView;
    metadata.hasPreview = itemDto.hasPreview;
    metadata.iconName = @"";
    metadata.permissions = itemDto.permissions;
    metadata.serverUrl = serverUrl;
    metadata.sessionTaskIdentifier = k_taskIdentifierDone;
    metadata.size = itemDto.size;
    metadata.status = k_metadataStatusNormal;
    metadata.typeFile = @"";
    
    [self insertTypeFileIconName:fileNameView metadata:metadata];
 
    return metadata;
}

+ (NSString *)insertTypeFileIconName:(NSString *)fileNameView metadata:(tableMetadata *)metadata
{
    CFStringRef fileUTI = nil;
    NSString *returnFileUTI = nil;
    
    if ([fileNameView isEqualToString:@"."]) {
        
        metadata.typeFile = k_metadataTypeFile_unknown;
        metadata.iconName = @"file";
        
    } else if (metadata.directory) {
        
        metadata.typeFile = k_metadataTypeFile_directory;
        fileUTI = kUTTypeFolder;
        
    } else {
        
        CFStringRef fileExtension = (__bridge CFStringRef)[fileNameView pathExtension];
        NSString *ext = (__bridge NSString *)fileExtension;
        ext = ext.uppercaseString;
        fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);

        // hasPreview
        if (metadata.hasPreview == -1) {
            if ([ext isEqualToString:@"JPG"] || [ext isEqualToString:@"PNG"] || [ext isEqualToString:@"JPEG"] || [ext isEqualToString:@"GIF"] || [ext isEqualToString:@"BMP"] || [ext isEqualToString:@"MP3"]  || [ext isEqualToString:@"MOV"]  || [ext isEqualToString:@"MP4"]  || [ext isEqualToString:@"M4V"] || [ext isEqualToString:@"3GP"])
                metadata.hasPreview = 1;
            else
                metadata.hasPreview = 0;
        }
        
        // Type image
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
            metadata.typeFile = k_metadataTypeFile_image;
            metadata.iconName = @"file_photo";
        }
        // Type Video
        else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
            metadata.typeFile = k_metadataTypeFile_video;
            metadata.iconName = @"file_movie";
        }
        // Type Audio
        else if (UTTypeConformsTo(fileUTI, kUTTypeAudio)) {
            metadata.typeFile = k_metadataTypeFile_audio;
            metadata.iconName = @"file_audio";
        }
        // Type Document [DOC] [PDF] [XLS] [TXT] (RTF = "public.rtf" - ODT = "org.oasis-open.opendocument.text") + isDocumentModifiableExtension
        else if (UTTypeConformsTo(fileUTI, kUTTypeContent) || [CCUtility isDocumentModifiableExtension:ext]) {
            metadata.typeFile = k_metadataTypeFile_document;
            metadata.iconName = @"document";
            
            NSString *typeFile = (__bridge NSString *)fileUTI;
            
            if ([typeFile isEqualToString:@"com.adobe.pdf"]) {
                metadata.iconName = @"file_pdf";
            }
            
            if ([typeFile isEqualToString:@"org.openxmlformats.spreadsheetml.sheet"]) {
                metadata.iconName = @"file_xls";
            }
            
            if ([typeFile isEqualToString:@"com.microsoft.excel.xls"]) {
                metadata.iconName = @"file_xls";
            }
            
            if ([typeFile isEqualToString:@"public.plain-text"] || [CCUtility isDocumentModifiableExtension:ext]) {
                metadata.iconName = @"file_txt";
            }
            
            if ([typeFile isEqualToString:@"public.html"]) {
                metadata.iconName = @"file_code";
            }
        }
        // Type compress
        else if (UTTypeConformsTo(fileUTI, kUTTypeZipArchive) && [(__bridge NSString *)fileUTI containsString:@"org.openxmlformats"] == NO && [(__bridge NSString *)fileUTI containsString:@"oasis"] == NO) {
            metadata.typeFile = k_metadataTypeFile_compress;
            metadata.iconName = @"file_compress";
        } else {
            
            // Type unknown
            metadata.typeFile = k_metadataTypeFile_unknown;
            
            // icon uTorrent
            if ([ext isEqualToString:@"TORRENT"]) {
                
                metadata.iconName = @"utorrent";
                
            } else {
            
                metadata.iconName = @"file";
            }
        }
    }
    
    if (fileUTI != nil) {
        returnFileUTI = (__bridge NSString *)fileUTI;
        CFRelease(fileUTI);
    }
    
    return returnFileUTI;
}

+ (tableMetadata *)insertFileSystemInMetadata:(tableMetadata *)metadata
{
    NSString *fileNamePath = [CCUtility getDirectoryProviderStorageFileID:metadata.fileID fileNameView:metadata.fileName];
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileNamePath error:nil];
    
    metadata.date = attributes[NSFileModificationDate];
    metadata.size = [attributes[NSFileSize] longValue];
    
    [self insertTypeFileIconName:metadata.fileNameView metadata:metadata];
    
    return metadata;
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark ===== Third parts =====
#pragma --------------------------------------------------------------------------------------------

+ (NSString *)stringValueForKey:(id)key conDictionary:(NSDictionary *)dictionary
{
    id obj = [dictionary objectForKey:key];
    
    if ([obj isEqual:[NSNull null]]) return @"";
    
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    }
    else {
        return [obj description];
    }
}

+ (NSString *)currentDevice
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceName=[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //NSLog(@"[LOG] Device Name :%@",deviceName);
    
    return deviceName;
}

+ (NSString *)getExtension:(NSString*)fileName
{
    NSMutableArray *fileNameArray =[[NSMutableArray alloc] initWithArray: [fileName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]]];
    NSString *extension = [NSString stringWithFormat:@"%@",[fileNameArray lastObject]];
    extension = [extension uppercaseString];
    //If the file has a ZIP extension obtain the previous one for check if it is a .pages.zip / .numbers.zip / .key.zip extension
    if ([extension isEqualToString:@"ZIP"]) {
        [fileNameArray removeLastObject];
        NSString *secondExtension = [NSString stringWithFormat:@"%@",[fileNameArray lastObject]];
        secondExtension = [secondExtension uppercaseString];
        if ([secondExtension isEqualToString:@"PAGES"] || [secondExtension isEqualToString:@"NUMBERS"] || [secondExtension isEqualToString:@"KEY"]) {
            extension = [NSString stringWithFormat:@"%@.%@",secondExtension,extension];
            return extension;
        }
    }
    return extension;
}

/*
 * Util method to make a NSDate object from a string from xml
 * @dateString -> Data string from xml
 */
+ (NSDate*)parseDateString:(NSString*)dateString
{
    //Parse the date in all the formats
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    /*In most cases the best locale to choose is "en_US_POSIX", a locale that's specifically designed to yield US English results regardless of both user and system preferences. "en_US_POSIX" is also invariant in time (if the US, at some point in the future, changes the way it formats dates, "en_US" will change to reflect the new behaviour, but "en_US_POSIX" will not). It will behave consistently for all users.*/
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    //This is the format for the concret locale used
    [dateFormatter setDateFormat:@"EEE, dd MMM y HH:mm:ss zzz"];
    
    NSDate *theDate = nil;
    NSError *error = nil;
    if (![dateFormatter getObjectValue:&theDate forString:dateString range:nil error:&error]) {
        NSLog(@"[LOG] Date '%@' could not be parsed: %@", dateString, error);
    }
    
    return theDate;
}

+ (NSDate *)datetimeWithOutTime:(NSDate *)datDate
{
    if (datDate == nil) return nil;
    
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:datDate];
    datDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    return datDate;
}

+ (NSDate *)datetimeWithOutDate:(NSDate *)datDate
{
    if (datDate == nil) return nil;
    
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:datDate];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+ (BOOL)isValidEmail:(NSString *)checkString
{
    checkString = [checkString lowercaseString];
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString *)URLEncodeStringFromString:(NSString *)string
{
    static CFStringRef charset = CFSTR("!@#$%&*()+'\";:=,/?[] ");
    CFStringRef str = (__bridge CFStringRef)string;
    CFStringEncoding encoding = kCFStringEncodingUTF8;
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, str, NULL, charset, encoding));
}

@end
