//
//  NotesService.m
//  NNotes
//
//  Created by Olga Vyrostko on 25.07.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import "NotesService.h"
#import "Note.h"
#import "AFNetworking.h"

@interface NotesService()

@property (nonatomic, strong) AFURLSessionManager * manager;

@end

@implementation NotesService

+(NSString *) serverUrl {
    return @"http://notes.illi-studio.ru/apzzz/notes";
}

+(NSString *) serverUrlTemplateWithId: (NSString *) noteId {
    return [NSString stringWithFormat: @"%@/%@", [NotesService serverUrl], noteId];
}

-(AFURLSessionManager *) manager {
    if (!_manager) {
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: configuration];
        _manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingAllowFragments];
    }
    return _manager;
}

-(void) sendNotesToServer: (NSArray *) notes {
    dispatch_group_t group = dispatch_group_create();
    
    NSURLRequest * request;
    NSURLSessionDataTask * dataTask;
    __block BOOL success = YES;
    for (Note * note in notes) {
        NSString * oldId = note.noteId;
        if ( [oldId rangeOfString: @"x-coredata"].location == 0)
            request = [[AFJSONRequestSerializer serializer] requestWithMethod: @"POST" URLString: [NotesService serverUrl] parameters: [self prepareToSendNote: note] error: nil];
        else
            request = [[AFJSONRequestSerializer serializer] requestWithMethod: @"PUT" URLString: [NotesService serverUrlTemplateWithId: oldId] parameters: [self prepareToSendNote: note] error: nil];
        
        dispatch_group_enter(group);
        dataTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error && error.code != 3840) {
                NSLog(@"Error: %@", error);
                success = NO;
            }
            else {
                NSHTTPURLResponse * resp = (NSHTTPURLResponse *) response;
                NSString * location = [[resp allHeaderFields] objectForKey: @"Location"];
                NSRange range = [location rangeOfString: @"/" options: NSBackwardsSearch];
                location = [location substringFromIndex: range.location + 1];
                NSString * oldId = note.noteId;
                if (nil != location) {
                    note.noteId = location;
                    [self.notesDisplayerDelegate updateNote: note withId: oldId];
                }
                NSLog(@"%@ %@", location, responseObject);
            }
            dispatch_group_leave(group);
        }];
        [dataTask resume];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.notesDisplayerDelegate notifyThatNotesAreSentSuccessfully: success];
    });
}

-(NSDictionary *) prepareToSendNote: (Note *) note {
    NSMutableDictionary * dictNote = [[NSMutableDictionary alloc] init];
    [dictNote setValue: note.noteId forKey: @"noteId"];
    [dictNote setValue: note.title forKey: @"title"];
    [dictNote setValue: note.text forKey: @"text"];
    [dictNote setValue: note.colorR forKey: @"colorR"];
    [dictNote setValue: note.colorG forKey: @"colorG"];
    [dictNote setValue: note.colorB forKey: @"colorB"];
    [dictNote setValue: [[NSUserDefaults standardUserDefaults] objectForKey: @"userName"] forKey: @"userName"];
    return [NSDictionary dictionaryWithDictionary: dictNote];
}

-(void) loadNotesFromServer {
    NSMutableArray * gotNotes = [[NSMutableArray alloc] init];
    NSURLRequest * request = [[AFJSONRequestSerializer serializer] requestWithMethod: @"GET" URLString: [NotesService serverUrl] parameters: [[NSDictionary alloc] initWithObjects: @[[NSString stringWithFormat: @"{\"userName\":\"%@\"}", [[NSUserDefaults standardUserDefaults] objectForKey: @"userName"] ]] forKeys: @[@"query"]] error: nil];
    NSURLSessionDataTask * dataTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error while getting notes");
        }
        else {
            NSArray * resp = (NSArray *) responseObject;
            for (NSDictionary * dictNote in resp) {
                //if (![self.dataCtrl selectNoteById: [dictNote objectForKey: @"_id"]]) {
                Note * note = [[Note alloc] init];
                note.noteId = [dictNote objectForKey: @"_id"];
                note.title = [dictNote objectForKey: @"title"];
                note.text = [dictNote objectForKey: @"text"];
                note.colorR = [dictNote objectForKey: @"colorR"];
                note.colorB = [dictNote objectForKey: @"colorB"];
                note.colorG = [dictNote objectForKey: @"colorG"];
                [gotNotes addObject: note];
                //}
            }
            [self.notesDisplayerDelegate addNotesToList: gotNotes];
        }
    }];
    [dataTask resume];
}


@end
