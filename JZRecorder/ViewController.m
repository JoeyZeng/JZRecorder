//
//  ViewController.m
//  JZRecorder
//
//  Created by ZengJoey on 16/1/22.
//  Copyright © 2016年 ZengJoey. All rights reserved.
//

#import "ViewController.h"
#import "JZRecorder.h"

@interface ViewController () <JZRecorderDelegate>
{
    NSTimer *_timer;
}
@property (nonatomic) RecordState recordState;
@property (strong, nonatomic) JZRecorder *recorder;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *recordPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *reRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *recordCompleteButton;
@property (weak, nonatomic) IBOutlet UIView *recordContainerView;

@end

@implementation ViewController

- (JZRecorder *)recorder
{
    if (!_recorder) {
        _recorder = [JZRecorder new];
        _recorder.delegate = self;
    }
    return _recorder;
}

- (void)setRecordState:(RecordState)recordState {
    _recordState = recordState;
    if (recordState == RecordStateEmpty) {
        _reRecordButton.alpha = 0;
        _recordCompleteButton.alpha = 0;
        _durationLabel.alpha = 0;
        _recordPromptLabel.text = @"点击说两句";
    }
    else if (recordState == RecordStateRecording) {
        _reRecordButton.alpha = 0;
        _recordCompleteButton.alpha = 0;
        _durationLabel.alpha = 1;
        _recordPromptLabel.text = @"点击完成";
    }
    else if (recordState == RecordStateRecorded) {
        _reRecordButton.alpha = 1;
        _recordCompleteButton.alpha = 1;
        _durationLabel.alpha = 1;
        _recordPromptLabel.text = @"继续录音";
    }
    else if (recordState == RecordStateComplete) {
        _reRecordButton.alpha = 1;
        _recordCompleteButton.alpha = 0;
        _durationLabel.alpha = 1;
        _recordPromptLabel.text = @"播放录音";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.recordState = RecordStateEmpty;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action

- (IBAction)recordButtonAction:(id)sender {
    
    [UIView animateWithDuration:.3 animations: ^{
        if (self.recordState == RecordStateRecording) {
            self.recordState = RecordStateRecorded;
            [_recordButton setBackgroundImage:[UIImage imageNamed:@"GrayMic"] forState:UIControlStateNormal];
        }
        else {
            self.recordState = RecordStateRecording;
            [_recordButton setBackgroundImage:[UIImage imageNamed:@"MovMic1"] forState:UIControlStateNormal];
        }
        
        [_recordContainerView layoutIfNeeded];
    }];
    
    if (self.recordState == RecordStateRecording) {
        [self startRecord];
    }
    else if (self.recordState == RecordStateRecorded) {
        [self pauseRecord];
    }
}

- (IBAction)reRecordButtonAction:(id)sender {
    
    [self.recorder destroyRecord];

    [UIView animateWithDuration:.3 animations: ^{
        self.recordState = RecordStateEmpty;
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"GrayMic"] forState:UIControlStateNormal];
        [_recordContainerView layoutIfNeeded];
    }];
}

- (IBAction)recordCompleteAction:(id)sender {
    [self finishRecord];
    
    [UIView animateWithDuration:.3 animations: ^{
        self.recordState = RecordStateComplete;
    } completion: ^(BOOL finished) {
    }];
}

#pragma mark - record

- (void)startRecord {
    
    if ([self.recorder startRecord]) {
        [self startTimer];
    } else {
        self.recordState = RecordStateEmpty;
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"GrayMic"] forState:UIControlStateNormal];
    }
}

- (void)pauseRecord {
    [self.recorder pauseRecord];
    [self stopTimer];
}

- (void)finishRecord {
    [self.recorder finishRecord];
    [self stopTimer];
}

#pragma mark - timer

- (void)startTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(onTimerCounting) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)showDuration {
    NSTimeInterval recordTime;
    if (self.recordState == RecordStateRecording) {
        recordTime = _recorder.currentTime;
    }
    else {
        return;
    }
    
    int mint = recordTime / 60;
    int sec = (NSInteger)recordTime % 60;
    NSString *str = [NSString stringWithFormat:@"%02d:%02d", mint, sec];
    _durationLabel.text = str;
}

- (void)showRecordVoicePower {
    float rate = [self.recorder recordingCurrentVoiceRate];
    if (rate < .5f) {
        rate = .5f;
    } else if (rate > .9f) {
        rate = .9f;
    }
    int level = 20 * rate - 10;
    //    LOG(@"%f - %d", 20 * rate - 10., level);
    //    int level = (power + 90) / 10;  // 0 ~ 8
    NSString *imgName = [NSString stringWithFormat:@"img_mic_%d", level];
    [_recordButton setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    //    LOG(@"voice power:%f", power);
}

- (void)onTimerCounting {
    if (self.recordState == RecordStateRecording) {
        [self showDuration];
        [self showRecordVoicePower];
    }
    else if (self.recordState == RecordStateComplete) {
        [self showDuration]; //  play audio
    }
}

#pragma mark <RecordHelperDelegate>

- (void)recordFinishWithFilePath:(NSString *)filePath ducation:(NSInteger)ducation
{
    NSLog(@"ducation:%ld", ducation);
    NSLog(@"filePath:%@", filePath);
}

@end
