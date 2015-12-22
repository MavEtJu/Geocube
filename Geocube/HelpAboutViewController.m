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

#import "Geocube-Prefix.pch"

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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     //[self reloadTexts];
                                 }
     ];
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
    heights = [NSMutableArray arrayWithCapacity:[texts count]];
    for (NSInteger i = 0; i < [texts count]; i++) {
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
    texts = @[@"This software uses the following 3rd party modules. My sincere thanks to all of the above for their generousity.",

              @"ActionSheetPicker: Copyright (c) 2011, Tim Cinel\n"
              "(https://github.com/skywinder/ActionSheetPicker-3.0)\n"
              "Copyright (c) 2011, Tim Cinel, All rights reserved.\n"
              "Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
              "* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
              "* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
              "* Neither the name of the <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n"
              "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",

              @"BHTabBar: Copyright (c) 2011 Fictorial LLC.\n"
              "(https://github.com/fictorial/BHTabBar).\n"
              "Copyright (c) 2011 Fictorial LLC.\n"
              "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
              "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
              "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",

              @"CMRangeSlider: Copyright (c) 2010 Charlie Mezak <charliemezak@gmail.com>\n"
              "(https://github.com/cmezak/CMRangeSlider).\n"
              "Copyright (c) 2010 Charlie Mezak <charliemezak@gmail.com>\n"
              "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
              "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
              "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",

              @"DejalActivityView: Includes 'DejalActivtyView' code from Dejal\n"
              "(http://www.dejal.com/developer/).\n"
              "Dejal Open Source\n"
              "Created by David Sinclair on 2009-07-26.\n"
              "Copyright (c) 2009-2013 Dejal Systems, LLC. All rights reserved.\n"
              "Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
              "- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
              "- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
              "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",

              @"DOPNavbarMenu: Copyright (c) 2015 Weizhou\n"
              "(https://github.com/dopcn/DOPNavbarMenu)\n"
              "The MIT License (MIT)\n"
              "Copyright (c) 2015 Weizhou\n"
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

              @"YIPopupTextView: Copyright (c) 2012 Yasuhiro Inami. All rights reserved.\n"
              "(https://github.com/inamiy/YIPopupTextView)\n"
              "`YIPopupTextView` is available under the [Beerware](http://en.wikipedia.org/wiki/Beerware) license. If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.",

              @"SSZipArchive: Copyright (c) 2010-2015, Sam Soffes, http://soff.es\n"
              "(https://github.com/iosphere/ssziparchive)",

              @"'Import Complete' sound: Copyright (c) 2011, Brandon Morris CC-BY 3.0\n"
              "(http://opengameart.org/content/completion-sound)",
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
    return [texts count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];

    cell.textLabel.text = [texts objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont systemFontOfSize:myConfig.GCSmallFont.pointSize];

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
        NSLog(@"foo: %ld", indexPath.row);
        return 10;
    }
    h = [n floatValue];
    return h + 10;
}

@end
