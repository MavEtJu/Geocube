/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

AudioFeedback *audioFeedback;

/* Obtained from http://www.cocoawithlove.com/2010/10/ios-tone-generator-introduction-to.html */
OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags *ioActionFlags,
                    const AudioTimeStamp       *inTimeStamp,
                    UInt32                      inBusNumber,
                    UInt32                      inNumberFrames,
                    AudioBufferList            *ioData)

{
    // Fixed amplitude is good enough for our purposes
    const double amplitude = 0.25;

    // Get the tone parameters out of the view controller
    double theta = audioFeedback.theta;
    double theta_increment = 2.0 * M_PI * audioFeedback.frequency / audioFeedback.sampleRate;

    // This is a mono tone generator so we only need the first buffer
    const int channel = 0;
    Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;

    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
        buffer[frame] = sin(theta) * amplitude;

        theta += theta_increment;
        if (theta > 2.0 * M_PI) {
            theta -= 2.0 * M_PI;
        }
    }

    audioFeedback.theta = theta;

    return noErr;
}

@interface AudioFeedback ()

@property (nonatomic        ) AudioComponentInstance toneUnit;

@end

@implementation AudioFeedback

- (instancetype)init
{
    self = [super init];

    self.theta = 0;
    self.sampleRate = 44100;
    self.frequency = 340;

    return self;
}

- (void)createToneUnit
{
    // Configure the search parameters to find the default playback output unit
    // (called the kAudioUnitSubType_RemoteIO on iOS but
    // kAudioUnitSubType_DefaultOutput on Mac OS X)
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;

    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");

    // Create a new unit based on this that we'll use for output
    AudioComponentInstance toneUnit;
    OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
    self.toneUnit = toneUnit;
    NSAssert1(self.toneUnit, @"Error creating unit: %hd", err);

    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = RenderTone;
    input.inputProcRefCon = nil;    // was self
    err = AudioUnitSetProperty(self.toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);

    // Set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = self.sampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty (self.toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
}

- (void)setTheFrequency:(double)f
{
    self.frequency = f;
}

- (void)togglePlay:(BOOL)on
{
    if (on == NO) {
        AudioOutputUnitStop(self.toneUnit);
        AudioUnitUninitialize(self.toneUnit);
        AudioComponentInstanceDispose(self.toneUnit);
        self.toneUnit = nil;
    } else {
        [self createToneUnit];

        // Stop changing parameters on the unit
        OSErr err = AudioUnitInitialize(self.toneUnit);
        NSAssert1(err == noErr, @"Error initializing unit: %hd", err);

        // Start playback
        err = AudioOutputUnitStart(self.toneUnit);
        NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    }
}

@end
