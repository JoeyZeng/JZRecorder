//
//  JZRecorder.h
//  k12
//
//  Created by joey on 15/4/20.
//  Copyright (c) 2015年 ailejiao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JZRecorderState) {
    JZRecorderStateNormal,
    JZRecorderStateRecording,
    JZRecorderStatePause,
    JZRecorderStateFinish,
};

@protocol JZRecorderDelegate <NSObject>

- (void)recordFinishWithFilePath:(NSString *)filePath ducation:(NSInteger)ducation;

@end

@interface JZRecorder : NSObject

@property (nonatomic, weak) id<JZRecorderDelegate> delegate;
@property (nonatomic, readonly) JZRecorderState state;
@property (nonatomic) NSTimeInterval currentTime;


@property (nonatomic, copy) NSString *audioFilePath;
@property (nonatomic) NSInteger duration;

- (float)recordingCurrentVoiceRate; //音量

- (BOOL)startRecord;
- (void)pauseRecord;
- (void)finishRecord;

- (void)resetRecord;
- (void)destroyRecord;

@end
