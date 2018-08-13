/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface ThemeImageGeocube ()

@property (nonatomic, retain) NSMutableDictionary<NSString *, UIImage *> *pinImages;
@property (nonatomic, retain) NSMutableDictionary<NSString *, UIImage *> *typeImages;

@end

@implementation ThemeImageGeocube

- (instancetype)init
{
    self = [super init];

    /* Pin and type images */
    self.pinImages = [NSMutableDictionary dictionaryWithCapacity:25];
    self.typeImages = [NSMutableDictionary dictionaryWithCapacity:25];

    return self;
}

- (void)loadImages
{
    [self loadImages:@"geocube-images.json"];
}

// -------------------------------------------------------------

- (void)addpinhead:(NSInteger)index image:(UIImage *)img
{
    NSString *name = [NSString stringWithFormat:@"pinhead: %ld", (long)index];
    [imageManager replaceInLibrary:img name:name index:index];
}

- (UIImage *)mergePinhead:(UIImage *)bottom topImg:(UIImage *)top
{
    UIImage *out = [self addImageToImage:bottom withImage2:top andRect:CGRectMake(3, 3, 15, 15)];
    return out;
}
- (UIImage *)mergePinhead2:(UIImage *)bottom top:(NSInteger)top
{
    UIImage *out = [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(3, 3, 15, 15)];
    return out;
}
- (UIImage *)mergePinhead:(UIImage *)bottom top:(NSInteger)top
{
    return [self mergePinhead2:bottom top:top];
}
- (void)mergePinhead:(NSInteger)bottom top:(NSInteger)top index:(NSInteger)index
{
    UIImage *out = [self mergePinhead2:[imageManager get:bottom] top:top];
    NSString *name = [NSString stringWithFormat:@"Merge of %ld and %ld", (long)bottom, (long)top];
    [imageManager replaceInLibrary:out name:name index:index];
}

- (UIImage *)mergeDNF:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(6, 6, 13, 13)];
}
- (UIImage *)mergeFound:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(6, 6, 13, 13)];
}

- (UIImage *)mergeHighlight:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(0, 0, 21, 21)];
}

- (UIImage *)mergeStick:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(0, 0, 35, 42)];
}
- (UIImage *)mergePin:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(0, 0, 35, 42)];
}
- (UIImage *)mergePin:(UIImage *)bottom topImg:(UIImage *)top
{
    return [self addImageToImage:bottom withImage2:top andRect:CGRectMake(0, 0, 35, 42)];
}
- (UIImage *)mergeOwner:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(3, 3, 15, 15)];
}

- (UIImage *)mergeDisabled:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(3, 3, 15, 15)];
}
- (UIImage *)mergeArchived:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[imageManager get:top] andRect:CGRectMake(3, 3, 15, 15)];
}

// -----------------------------------------------------------

- (UIImage *)getPin:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF
{
    NSString *s = [imageManager getCode:pin found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF planned:NO];
    UIImage *img = [self.pinImages valueForKey:s];
    if (img == nil) {
        NSLog(@"Geocube: Creating pin %@s", s);
        img = [self getPinImage:pin found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF];
        [self.pinImages setObject:img forKey:s];
    }

    return img;
}

- (UIImage *)getPinImage:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF
{
    UIImage *img = [imageManager get:ImageMap_background];

    switch (found) {
        case LOGSTATUS_NOTLOGGED:
            // Do not overlay anything
            img = [self mergeStick:img top:ImageMap_pin];
            break;
        case LOGSTATUS_NOTFOUND:
            img = [self mergeStick:img top:ImageMap_dnf];
            // Overlay the blue cross
            break;
        case LOGSTATUS_FOUND:
            img = [self mergeStick:img top:ImageMap_found];
            // Overlay the yellow tick
            break;
    }

    if (highlight == YES)
        img = [self mergeHighlight:img top:ImageMap_pinOutlineHighlight];

    img = [self mergePinhead:img topImg:pin.img];

    if (owner == YES)
        img = [self mergeOwner:img top:ImageMap_pinOwner];

    if (inProgress == YES)
        img = [self mergeOwner:img top:ImageMap_pinInProgress];

    if (markedFound == YES) {
        img = [self mergeFound:img top:ImageMap_pinMarkedFound];
    } else {
        switch (found) {
            case LOGSTATUS_NOTLOGGED:
                // Do not overlay anything
                break;
            case LOGSTATUS_NOTFOUND:
                img = [self mergeFound:img top:ImageMap_pinCrossDNF];
                // Overlay the blue cross
                break;
            case LOGSTATUS_FOUND:
                img = [self mergeFound:img top:ImageMap_pinTickFound];
                // Overlay the yellow tick
                break;
        }
    }

    if (markedDNF == YES)
        img = [self mergeDNF:img top:ImageMap_pinCrossDNF];

    if (disabled == YES)
        img = [self mergeDisabled:img top:ImageMap_pinOutlineDisabled];

    if (archived == YES)
        img = [self mergeArchived:img top:ImageMap_pinOutlineArchived];

    return img;
}

// -----------------------------------------------------------

- (UIImage *)getType:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned
{
    NSString *s = [imageManager getCode:type found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF planned:planned];
    UIImage *img = [self.typeImages valueForKey:s];
    if (img == nil) {
        img = [self getTypeImage:type found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF planned:planned];
        [self.typeImages setObject:img forKey:s];
    }

    return img;
}

- (UIImage *)getTypeImage:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned
{
    UIImage *img = [imageManager get:type.icon];

    if (owner == YES)
        img = [self mergeOwner:img top:ImageContainerFlag_owner];

    if (inProgress == YES)
        img = [self mergeArchived:img top:ImageContainerFlag_inProgress];

    if (markedFound == YES) {
        img = [self mergeFound:img top:ImageContainerFlag_markedFound];
    } else {
        switch (found) {
            case LOGSTATUS_NOTLOGGED:
                // Do not overlay anything
                break;
            case LOGSTATUS_NOTFOUND:
                img = [self mergeFound:img top:ImageContainerFlag_crossDNF];
                // Overlay the blue cross
                break;
            case LOGSTATUS_FOUND:
                img = [self mergeFound:img top:ImageContainerFlag_tickFound];
                // Overlay the yellow tick
                break;
        }
    }

    if (markedDNF == YES)
        img = [self mergeDNF:img top:ImageContainerFlag_crossDNF];

    if (disabled == YES)
        img = [self mergeDisabled:img top:ImageContainerFlag_outlineDisabled];

    if (archived == YES)
        img = [self mergeArchived:img top:ImageContainerFlag_outlineArchived];

    if (planned == YES)
        img = [self mergeArchived:img top:ImageContainerFlag_planned];

    return img;
}

// ----------------------------------

- (CGPoint)centerOffsetAppleMaps
{
    return CGPointMake(7, -17);
}

- (CGPoint)groundAnchorGoogleMaps
{
    return CGPointMake(11.0 / 35.0, 38.0 / 42.0);
}
- (CGPoint)infoWindowAnchorGoogleMaps
{
    return CGPointMake(11.0 / 35.0, 3.0 / 42.0);
}

@end
