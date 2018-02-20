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

@interface HelpAboutViewController ()

@property (nonatomic, retain) NSMutableArray<NSDictionary *> *texts;

@end

@implementation HelpAboutViewController

- (instancetype)init
{
    self = [super init];

    self.lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerNib:[UINib nibWithNibName:XIB_HELPABOUTTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_HELPABOUTTABLEVIEWCELL];
    [self loadTexts];
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
    self.texts = [NSMutableArray arrayWithCapacity:20];
    [self.texts addObject:@{
        @"name": @"OpenStreetMap maps",
        @"copyright": @"© OpenStreetMap contributors",
        @"url": @"http://openstreetmap.org",
        @"license": @"The data used for the OpenStreetMap map is available under the Open Database License. For the map tiles, the cartography is licensed as CC BY-SA. See http://openstreetmap.org/copyright for more details.",
     }];

    [self.texts addObject:@{
        @"name": @"ActionSheetPicker",
        @"copyright": @"Copyright (c) 2011, Tim Cinel, All rights reserved.",
        @"url": @"https://github.com/skywinder/ActionSheetPicker-3.0",
        @"license":
            @"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
            "\n"
            "* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
            "* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
            "* Neither the name of the <organization> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n"
            "\n"
            "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",
     }];
    [self.texts addObject:@{
        @"name": @"'Beeper' sound (original Beep-2.wav)",
        @"copyright": @"Copyright (c) SoundJay.com",
        @"url": @"https://www.soundjay.com/beep-sounds-1.html",
        @"license": @"You are allowed to use the sounds free of charge and royalty free in your projects (such as films, videos, games, presentations, animations, stage plays, radio plays, audio books, apps) be it for commercial or non-commercial purposes.",
     }];
    [self.texts addObject:@{
        @"name": @"CMRangeSlider",
        @"copyright": @"Copyright (c) 2010 Charlie Mezak <charliemezak@gmail.com>",
        @"url": @"https://github.com/cmezak/CMRangeSlider",
        @"license":
            @"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
     }];
    [self.texts addObject:@{
        @"name": @"DOPNavbarMenu",
        @"copyright": @"Copyright (c) 2015 Weizhou",
        @"url": @"https://github.com/dopcn/DOPNavbarMenu",
        @"license":
            @"The MIT License (MIT)\n"
            "\n"
            "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
     }];
    [self.texts addObject:@{
        @"name": @"'Import Complete' sound",
        @"copyright": @"Copyright (c) 2011, Brandon Morris",
        @"url": @"http://opengameart.org/content/completion-sound",
        @"license": @"CC-BY 3.0",
     }];
    [self.texts addObject:@{
        @"name": @"kxintro",
        @"copyright": @"Copyright (c) 2013 Konstantin Bukreev. All rights reserved.\n",
        @"url": @"https://github.com/kolyvan/kxintro/",
        @"license":
            @"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
            "\n"
            "- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
            "- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
            "\n"
            "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",
     }];
    [self.texts addObject:@{
        @"name": @"Mapbox iOS SDK",
        @"copyright": @"© Mapbox",
        @"url": @"https://www.mapbox.com/about/maps/",
        @"license": @"Mapbox license",
    }];
    [self.texts addObject:@{
        @"name": @"MHTabBarController",
        @"copyright": @"Copyright (c) 2011 Matthijs Hollemans.",
        @"url": @"https://github.com/hollance/MHTabBarController",
        @"license":
            @"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
     }];
    [self.texts addObject:@{
        @"name": @"NKOColorPickerView",
        @"copyright": @"Copyright (C) 2014 Carlos Vidal",
        @"url": @"https://github.com/nakiostudio/NKO-Color-Picker-View-iOS",
        @"license":
            @"The MIT License (MIT)\n"
            "\n"
            "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE LICENSE",
     }];
    [self.texts addObject:@{
        @"name": @"NVHTarGzip",
        @"copyright": @"Copyright (c) 2014 Niels van Hoorn <niels@zekerwaar.nl>",
        @"url": @"https://github.com/nvh/NVHTarGzip",
        @"license":
            @"The MIT License (MIT)\n"
            "\n"
            "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
     }];
    [self.texts addObject:@{
       @"name": @"Geodata via OpenCage Data",
       @"copyright": @"Geodata copyright OpenStreetMap contributors",
       @"url": @"https://geocoder.opencagedata.com/",
       @"license": @"The geocodes the API returns are jointly licensed under the ODbL and CC-BY-SA licenses."
     }];
    [self.texts addObject:@{
        @"name": @"Google Maps iOS SDK",
        @"copyright": @"Copyright (c) Google Inc.",
        @"url": @"https://developers.google.com/maps/",
        @"license":
            @"By using the Google Maps SDK for iOS you accept Google's Terms of Service and Policies. Pay attention particularly to the following aspects:\n"
            "\n"
            "* Depending on your app and use case, you may be required to display attribution. Read more about [attribution requirements] (https://developers.google.com/maps/documentation/ios-sdk/intro#attribution_requirements).\n"
            "* Your API usage is subject to quota limitations. Read more about [usage limits](https://developers.google.com/maps/pricing-and-plans/).\n"
            "* The [Terms of Service](https://developers.google.com/maps/terms) are a comprehensive description of the legal contract that you enter with Google by using the Google Maps SDK for iOS. You may want to pay special attention to [section 10] (https://developers.google.com/maps/terms#10-license-restrictions), as it talks in detail about what you can do with the API, and what you can't.",
     }];
    [self.texts addObject:@{
       @"name": @"google-maps-ios-utils",
       @"copyright": @"Copyright (c) 2016 Google Inc.",
       @"url": @"https://github.com/googlemaps/google-maps-ios-utils",
       @"license":
           @"Copyright (c) 2016 Google Inc.\n"
           "\n"
           "Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at\n"
           "\n"
           "http://www.apache.org/licenses/LICENSE-2.0\n"
           "\n"
           "Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License."
     }];
    [self.texts addObject:@{
        @"name": @"Reachability",
        @"copyright": @"Copyright (C) 2015 Apple Inc. All Rights Reserved.",
        @"url": @"http://developer.apple.com/library/ios/samplecode/Reachability/index.html",
        @"license":
            @"IMPORTANT:  This Apple software is supplied to you by Apple Inc. (\"Apple\") in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.\n"
            "\n"
            "In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple's copyrights in this original Apple software (the \"Apple Software\"), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software. Neither the name, trademarks, service marks or logos of Apple Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.\n"
            "\n"
            "The Apple Software is provided by Apple on an \"AS IS\" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.\n"
            "\n"
            "IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",
     }];
    [self.texts addObject:@{
        @"name": @"RNCryptor-objc",
        @"copyright": @"Copyright (c) 2012 Rob Napier",
        @"url": @"https://github.com/RNCryptor/RNCryptor-objc",
        @"license":
            @"Except where otherwise indicated in the source code, this code is licensed under the MIT License:\n"
            "\n"
            "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
     }];
    [self.texts addObject:@{
        @"name": @"Simple-KML",
        @"copyright": @"Copyright (c) 2010-2013 MapBox.",
        @"url": @"https://github.com/mapbox/Simple-KML",
        @"license":
            @"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
            "\n"
            "* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
            "* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
            "* Neither the name of MapBox, nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n"
            "\n"
            "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",
     }];
    [self.texts addObject:@{
        @"name": @"SSZipArchive",
        @"copyright": @"Copyright (c) 2010-2015, Sam Soffes, http://soff.es",
        @"url": @"https://github.com/iosphere/ssziparchive",
        @"license":
            @"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
     }];
    [self.texts addObject:@{
        @"name": @"SVProgressHUD",
        @"copyright": @"Copyright (c) 2011-2016 Sam Vermette and contributors. All rights reserved.",
        @"url": @"https://github.com/SVProgressHUD/SVProgressHUD",
        @"license":
            @"SVProgressHUD is distributed under the terms and conditions of the MIT license (https://github.com/SVProgressHUD/SVProgressHUD/blob/master/LICENSE.txt). The success, error and info icons are made by Freepik (http://www.freepik.com) from Flaticon (http://www.flaticon.com) and are licensed under Creative Commons BY 3.0 (http://creativecommons.org/licenses/by/3.0/).",
     }];
    [self.texts addObject:@{
        @"name": @"TFHpple",
        @"copyright": @"Created by Geoffrey Grosenbach on 1/31/09, Copyright (c) 2009 Topfunky Corporation, http://topfunky.com",
        @"url": @"https://github.com/topfunky/hpple",
        @"license":
            @"MIT LICENSE\n"
            "\n"
            "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
     }];
    [self.texts addObject:@{
        @"name": @"THLabel",
        @"copyright": @"Copyright (c) 2012-2016 Tobias Hagemann, tobiha.de",
        @"url": @"https://github.com/MuscleRumble/THLabel",
        @"license":
            @"This software is provided 'as-is', without any express or implied warranty.  In no event will the authors be held liable for any damages arising from the use of this software.\n"
            "\n"
            "Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:\n"
            "\n"
            "1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.\n"
            "2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software."
            "3. This notice may not be removed or altered from any source distribution.",
     }];
    [self.texts addObject:@{
        @"name": @"TouchXML",
        @"copyright": @"Copyright 2011 Jonathan Wight. All rights reserved.",
        @"url": @"https://github.com/TouchCode/TouchXML",
        @"license":
            @"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
            "\n"
            "1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
            "2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
            "\n"
            "THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n"
            "The views and conclusions contained in the software and documentation are those of the authors and should not be interpreted as representing official policies, either expressed or implied, of Jonathan Wight."
     }];
    [self.texts addObject:@{
        @"name": @"VKSideMenu",
        @"copyright": @"Copyright © 2016 WOOPSS.com (http://woopss.com/) Created by Vladislav Kovalyov on 2/7/16.",
        @"url": @"https://github.com/vladislav-k/VKSideMenu",
        @"license":
            @"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n"
            "\n"
            "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n"
            "\n"
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
     }];
    [self.texts addObject:@{
        @"name": @"YIPopupTextView",
        @"copyright": @"Copyright (c) 2012 Yasuhiro Inami. All rights reserved.",
        @"url": @"https://github.com/inamiy/YIPopupTextView)",
        @"license": @"`YIPopupTextView` is available under the [Beerware](http://en.wikipedia.org/wiki/Beerware) license. If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.",
     }];
}

#pragma clang diagnostic pop

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Geocube";
    else
        return _(@"helpaboutviewcontroller-Licensed modules");
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return [self.texts count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HelpAboutTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_HELPABOUTTABLEVIEWCELL forIndexPath:indexPath];

    if (indexPath.section == 0) {
        NSString *s = [NSString stringWithFormat:@"Geocube Version %@(%@)\nBuild on %s %s",
                       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                       __DATE__, __TIME__];
        cell.name.text = s;
        cell.url.text = _(@"helpaboutviewcontroller-https://geocube.mavetju.org/");
        cell.copyright.text = @"";
        cell.license.text = @"";
    }

    if (indexPath.section == 1) {
        NSString *s = nil;
        NSDictionary *d = [self.texts objectAtIndex:indexPath.row];
        cell.name.text = [d objectForKey:@"name"];
        if ((s = [d objectForKey:@"url"]) != nil)
            cell.url.text = [NSString stringWithFormat:@"%@: %@", _(@"URL"), s];
        if ((s = [d objectForKey:@"copyright"]) != nil)
            cell.copyright.text = [NSString stringWithFormat:@"%@: %@", _(@"helpaboutviewcontroller-Copyright"), s];
        if ((s = [d objectForKey:@"license"]) != nil)
            cell.license.text = [NSString stringWithFormat:@"%@:\n%@", _(@"helpaboutviewcontroller-License"), s];
    }

    [cell setUserInteractionEnabled:NO];

    return cell;
}

@end
