//
//  JZViewController.h
//  JZRecorder
//
//  Created by ZengJoey on 01/22/2016.
//  Copyright (c) 2016 ZengJoey. All rights reserved.
//

@import UIKit;

typedef NS_ENUM (NSInteger, RecordState) {
    RecordStateEmpty,
    RecordStateRecording,
    RecordStateRecorded,
    RecordStateComplete,
};

@interface JZViewController : UIViewController

@end
