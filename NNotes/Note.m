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

- (id) initWithTitle: (NSString *) title Text: (NSString *) text andColor:(NSNumber *)color {
    self = [self init];
    self.title = title;
    self.text = text;
    self.color = color;
    return self;
}

@end
