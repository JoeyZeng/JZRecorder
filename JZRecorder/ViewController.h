//
//  ViewController.h
//  JZRecorder
//
//  Created by ZengJoey on 16/1/22.
//  Copyright © 2016年 ZengJoey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, RecordState) {
    RecordStateEmpty,
    RecordStateRecording,
    RecordStateRecorded,
    RecordStateComplete,
};

@interface ViewController : UIViewController


@end

