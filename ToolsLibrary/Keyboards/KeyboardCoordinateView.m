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

@interface KeyboardCoordinateView ()

@end

@implementation KeyboardCoordinateView

- (void)addObservers
{
    // Keep track of the textView/Field that we are editing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}

// Editing just began, store a reference to the object that just became the firstResponder
- (void)editingDidBegin:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UIResponder class]]) {
        if ([notification.object conformsToProtocol:@protocol(UITextInput)]) {
            self.targetTextInput = notification.object;
            return;
        }
    }

    // Not a valid target for us to worry about.
    self.targetTextInput = nil;
}

// Editing just ended.
- (void)editingDidEnd:(NSNotification *)notification
{
    self.targetTextInput = nil;
}

// Replace the text of the textInput in textRange with string if the delegate approves
- (void)textInput:(UITextField <UITextInput> *)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string
{
    if (textInput != nil) {
        if (textRange != nil) {
            NSMutableString *s = [NSMutableString stringWithString:[textInput text]];
            [s replaceCharactersInRange:[self rangeForTextRange:textRange] withString:string];

            [textInput replaceRange:textRange withText:string];
        }
    }
}

- (UITextRange *)textRangeForRange:(NSRange)range
{
    UITextPosition *startPos = [self.targetTextInput positionFromPosition:self.targetTextInput.beginningOfDocument offset:range.location];
    UITextPosition *endPos = [self.targetTextInput positionFromPosition:self.targetTextInput.beginningOfDocument offset:(range.location + range.length)];
    UITextRange *textRange = [self.targetTextInput textRangeFromPosition:startPos toPosition:endPos];
    return textRange;
}

//
// Calculate the location and length -> create NSRange
//
- (NSRange)rangeForTextRange:(UITextRange *)textRange
{
    NSUInteger location = [self.targetTextInput offsetFromPosition:self.targetTextInput.beginningOfDocument toPosition:textRange.start];
    NSUInteger length = [self.targetTextInput offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

@end
