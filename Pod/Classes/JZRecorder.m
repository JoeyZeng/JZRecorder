//
//  JZRecorder.m
//  k12
//
//  Created by joey on 15/4/20.
//  Copyright (c) 2015年 ailejiao.com. All rights reserved.
//

#import "JZRecorder.h"
#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"record.caf"

@interface JZRecorder () <AVAudioRecorderDelegate>
{
    AVAudioRecorder *_audioRecorder;
    
    NSURL *_fileURL;
}
@property (nonatomic) JZRecorderState state;

@end

@implementation JZRecorder

- (void)dealloc {
    if (_audioRecorder) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
        if (error) {
            NSLog(@"Deactive AudioSessionError. %@", error);
        }
    }
}

- (NSString *)audioFilePath
{
    if (_audioFilePath.length == 0) {
        _audioFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _audioFilePath = [_audioFilePath stringByAppendingPathComponent:kRecordAudioFile];
        _fileURL = [NSURL fileURLWithPath:_audioFilePath];
    }
    return _audioFilePath;
}

- (NSTimeInterval)currentTime
{
    return _audioRecorder.currentTime;
}

#pragma mark - record


- (BOOL)removeAudioFile {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioFilePath]) {
        return [[NSFileManager defaultManager]removeItemAtPath:self.audioFilePath error:nil];
    }
    else {
        return YES;
    }
}

- (BOOL)initRecorder {
    _duration = 0;

    [self removeAudioFile];
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    //设置录音格式
    [setting setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了,44100
    [setting setObject:@(16000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [setting setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    //[setting setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    //[setting setObject:@(NO) forKey:AVLinearPCMIsFloatKey];
    
//    [setting setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    
    //创建录音机
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_fileURL settings:setting error:&error];
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
    //    BOOL flag = [_audioRecorder prepareToRecord];
    //    if (!flag || error) {
    //        LOG(@"创建录音机对象时发生错误，错误信息：%@",error);
    //        return NO;
    //    }else{
    //        return YES;
    //    }
    return YES;
}

- (void)destroyRecord {
    if (_audioRecorder) {
        [_audioRecorder stop];
        [_audioRecorder deleteRecording];
        _audioRecorder = nil;
    }
    [self removeAudioFile];
    self.state = JZRecorderStateNormal;
}

- (BOOL)startRecord {
    
    __block BOOL isRecordGranted = YES;

    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            isRecordGranted = NO;
            
            NSLog(@"无法录音。请在iPhone的 “设置－麦克风” 选项中，允许访问您手机的麦克风。");
        }
    }];
    
    if (!isRecordGranted) {
        return NO;
    }
    
    if (!_audioRecorder) {
        
        BOOL flag = [self initRecorder];
        if (flag == NO) {
            NSLog(@"录音出现错误！");
            return NO;
        }
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    
    // 上次录音结束之后，下次录音开始要把录音delete，不然播放player不会successful
//    if (self.state == JZRecorderStateFinish) {
//        [_audioRecorder deleteRecording];
//        [self removeAudioFile];
//    }
    
    if ([_audioRecorder prepareToRecord]) {
        [_audioRecorder record];
        self.state = JZRecorderStateRecording;
    }
    return YES;
}

- (void)pauseRecord {
    [_audioRecorder pause];
    
    self.state = JZRecorderStatePause;
}

- (void)resetRecord {
    [self destroyRecord];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startRecord];
    });
    
    self.state = JZRecorderStateNormal;
}

- (void)finishRecord {
    [_audioRecorder stop];
    _audioRecorder = nil;
    self.state = JZRecorderStateFinish;
}

- (float)recordingCurrentVoiceRate
{
    [_audioRecorder updateMeters];
    float power = [_audioRecorder peakPowerForChannel:0];
    float rate = (power + 160) / 160.f;
    return rate;
}


#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {

    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.audioFilePath error:nil];
//    NSLog(@"Record file size: %ld", [fileAttributes fileSize]);
    
    if (!flag || fileAttributes.allKeys.count == 0) {
        return;
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    AVAsset *info = [AVAsset assetWithURL:_fileURL];
    Float64 t = CMTimeGetSeconds(info.duration);
    _duration = [NSNumber numberWithDouble:t].floatValue * 1000;
    
//    NSLog(@"Record ducation: %d",_duration );
    
    if (_duration > 0) {
        [self.delegate recordFinishWithFilePath:self.audioFilePath ducation:_duration];
    }
}

@end
