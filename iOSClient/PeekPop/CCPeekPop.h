//
//  CCPeekPop.h
//  Nextcloud iOS
//
//  Created by Marino Faggiana on 26/08/16.
//  Copyright (c) 2017 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <UIKit/UIKit.h>
#import "OCNetworking.h"

@class tableMetadata;

@protocol CCPeekPopDelegate;

@interface CCPeekPop : UIViewController

@property (nonatomic, weak) id <CCPeekPopDelegate> delegate;

@property (nonatomic, strong) tableMetadata *metadata;

@property (nonatomic, weak) IBOutlet UIImageView *imagePreview;

@end

@protocol CCPeekPopDelegate <NSObject>

@end
