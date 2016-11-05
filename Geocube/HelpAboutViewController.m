/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

@interface HelpAboutViewController ()
{
    NSInteger width;
    NSArray *texts;
    NSMutableArray *heights;
}

@end

#define THISCELL @"HelpAboutCells"

@implementation HelpAboutViewController

- (instancetype)init
{
    self = [super init];

    lmi = nil;

    return self;
}

- (NSInteger)addText:(NSInteger)y text:(NSString *)t
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    width = bounds.size.width;
    GCTextblock *l;

    CGRect rect = CGRectMake(10, y, width - 20, 0);
    l = [[GCTextblock alloc] initWithFrame:rect];
    l.text = t;
    [l sizeToFit];
    [self.view addSubview:l];

    return l.frame.size.height + 10;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL];
    [self loadTexts];
    heights = [NSMutableArray arrayWithCapacity:[texts count] + 1];
    for (NSInteger i = 0; i < [texts count] + 1; i++) {
        [heights addObject:[NSNumber numberWithInteger:0]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-string-concatenation"

- (void)loadTexts
{
    texts = @[@"This software uses the following 3rd party modules and data. My sincere thanks to all of the above for their generousity.",

              @"OpenStreetMap maps\n"
              "© OpenStreetMap contributors\n"
              "The data used for the OpenStreetMap map is available under the Open Database License. For the map tiles, the cartography is licensed as CC BY-SA. See http://openstreetmap.org/copyright for more details.",

              @"ActionSheetPicker: Copyright (c) 2011, Tim Cinel\n"
              "(https://github.com/skywinder/ActionSheetPicker-3.0)\n"
              "Copyright (c) 2011, Tim Cinel, All rights reserved.\n"
              "Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
              "* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
              "* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
              "* Neither the name of the <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n"
              "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",

              @"CMRangeSlider: Copyright (c) 2010 Charlie Mezak <charliemezak@gmail.com>\n"
              "(https://github.com/cmezak/CMRangeSlider).\n"
              "Copyright (c) 2010 Charlie Mezak <charliemezak@gmail.com>\n"
              "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
              "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
              "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",

              @"DOPNavbarMenu: Copyright (c) 2015 Weizhou\n"
              "(https://github.com/dopcn/DOPNavbarMenu)\n"
              "The MIT License (MIT)\n"
              "Copyright (c) 2015 Weizhou\n"
              "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
              "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
              "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",

              @"'Import Complete' sound: Copyright (c) 2011, Brandon Morris CC-BY 3.0\n"
              "(http://opengameart.org/content/completion-sound)",

              @"MHTabBarController: Copyright (c) 2011 Matthijs Hollemans.\n"
              "(https://github.com/hollance/MHTabBarController).\n"
              "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
              "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
              "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",

              @"NKOColorPickerView: Copyright (C) 2014 Carlos Vidal\n"
              "(https://github.com/nakiostudio/NKO-Color-Picker-View-iOS)\n"
              "The MIT License (MIT)\n"
              "Copyright (C) 2014 Carlos Vidal\n"
              "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
              "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
              "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE LICENSE",

              @"Reachability: Copyright (C) 2015 Apple Inc. All Rights Reserved.\n"
              "http://developer.apple.com/library/ios/samplecode/Reachability/index.html\n"
              "IMPORTANT:  This Apple software is supplied to you by Apple Inc. (\"Apple\") in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.\n"
              "In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple's copyrights in this original Apple software (the \"Apple Software\"), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software. Neither the name, trademarks, service marks or logos of Apple Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.\n"
              "The Apple Software is provided by Apple on an \"AS IS\" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.\n"
              "IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",

              @"SSZipArchive: Copyright (c) 2010-2015, Sam Soffes, http://soff.es\n"
              "(https://github.com/iosphere/ssziparchive)",

              @"SVProgressHUD: Copyright (c) 2011-2016 Sam Vermette and contributors. All rights reserved.\n"
              "https://github.com/SVProgressHUD/SVProgressHUD\n"
              "SVProgressHUD is distributed under the terms and conditions of the MIT license (https://github.com/SVProgressHUD/SVProgressHUD/blob/master/LICENSE.txt). The success, error and info icons are made by Freepik (http://www.freepik.com) from Flaticon (http://www.flaticon.com) and are licensed under Creative Commons BY 3.0 (http://creativecommons.org/licenses/by/3.0/).",

              @"TFHpple: Created by Geoffrey Grosenbach on 1/31/09, Copyright (c) 2009 Topfunky Corporation, http://topfunky.com\n"
              "https://github.com/topfunky/hpple\n"
              "MIT LICENSE\n"
              "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
              "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
              "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."

              @"THLabel: Copyright (c) 2012-2016 Tobias Hagemann, tobiha.de\n"
              "https://github.com/MuscleRumble/THLabel\n"
              "This software is provided 'as-is', without any express or implied warranty.  In no event will the authors be held liable for any damages arising from the use of this software.\n"
              "Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:\n"
              "1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.\n"
              "2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software."
              "3. This notice may not be removed or altered from any source distribution.",

              @"VKSideMenu: Copyright © 2016 WOOPSS.com (http://woopss.com/)\n"
              "https://github.com/vladislav-k/VKSideMenu\n"
              "Created by Vladislav Kovalyov on 2/7/16.\n"
              "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
              "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
              "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",

              @"YIPopupTextView: Copyright (c) 2012 Yasuhiro Inami. All rights reserved.\n"
              "(https://github.com/inamiy/YIPopupTextView)\n"
              "`YIPopupTextView` is available under the [Beerware](http://en.wikipedia.org/wiki/Beerware) license. If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.",
          ];
}

#pragma clang diagnostic pop

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + [texts count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    if (indexPath.row == 0) {
        NSString *s = [NSString stringWithFormat:@"Geocube Version %@(%@)\nBuild on %s %s",
                       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                       __DATE__, __TIME__];
        cell.textLabel.text = s;
        cell.textLabel.font = [UIFont systemFontOfSize:configManager.GCTextblockFont.pointSize];
    } else {
        cell.textLabel.text = [texts objectAtIndex:indexPath.row - 1];
        cell.textLabel.font = [UIFont systemFontOfSize:configManager.GCSmallFont.pointSize];
    }

    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [cell.textLabel sizeToFit];
    [heights replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:cell.textLabel.frame.size.height]];
    [cell setUserInteractionEnabled:NO];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat h = 0;

    NSNumber *n = [heights objectAtIndex:indexPath.row];
    if (n == nil) {
        return 10;
    }
    h = [n floatValue];
    return h + 10;
}

@end
