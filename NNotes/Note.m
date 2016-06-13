//
//  Note.m
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import "Note.h"

@implementation Note

- (id)init {
    self = [super init];
    return self;
}

- (id) initWithTitle: (NSString *) title Text: (NSString *) text ColorR:(NSNumber *)colorR ColorG:(NSNumber *)colorG andColorB:(NSNumber *)colorB {
    self = [self init];
    self.title = title;
    self.text = text;
    self.colorR = colorR;
    self.colorG = colorG;
    self.colorB = colorB;
    return self;
}

@end
