//
//  ViewController.m
//  Json2Model
//
//  Created by Chanbo on 15/11/10.
//  Copyright (c) 2015年 Chanbo. All rights reserved.
//

#import "ViewController.h"

#define COMMENT_DESC    @"/**\r\n *  <#Description#>\r\n */"

@interface ViewController ()
@property (weak) IBOutlet NSTextField *txtModelName;
@property (unsafe_unretained) IBOutlet NSTextView *txtJson;
@property (unsafe_unretained) IBOutlet NSTextView *txtModel;
@property (unsafe_unretained) IBOutlet NSTextView *txtImpModel;
@property (weak) IBOutlet NSTextField *txtSaveDir;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
    
}

- (IBAction)selectDir:(NSButton *)sender {
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:NO];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSModalResponseOK )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSURL* file = [openDlg URL];
        _txtSaveDir.stringValue = file.path;
    }
}

- (IBAction)textSelector:(NSTextField *)sender {
    NSLog(@"22");
}

- (NSDictionary *)getDictionary:(NSString *)jsonStr
{
    NSError *error = nil;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!jsonData) {
        return nil;
    }
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        return nil;
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return obj;
}

- (IBAction)save:(id)sender {
    NSString *header = _txtModel.string;
    NSString *impl = _txtImpModel.string;
    NSString *modelName = _txtModelName.stringValue;
    NSString *path = _txtSaveDir.stringValue;
    
    NSString *path1 = [NSString stringWithFormat:@"%@/%@.h",path,modelName];
    NSString *path2 = [NSString stringWithFormat:@"%@/%@.m",path,modelName];
    
    [header writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [impl writeToFile:path2 atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (IBAction)convertModel:(id)sender {
    
    NSString *modelName = _txtModelName.stringValue;
    NSString *jsonStr = _txtJson.string;
    NSMutableString *modelHeaderStr = [NSMutableString stringWithCapacity:1024 * 10];
    NSMutableString *modelImplStr = [NSMutableString stringWithCapacity:1024 * 10];
    
    NSDictionary *dict = [self getDictionary:jsonStr];
    if (!dict) {
        return;
    }
    
    NSString *header = [NSString stringWithFormat:@"//\r\n//  %@.h\r\n//  Json2Model Autogen\r\n//\r\n//  Created by Json2Model.\r\n//  Copyright (c) 2015年 All rights reserved.\r\n//\r\n\r\n#import \"BaseModel.h\"\r\n\r\n%@\r\n@interface %@ : BaseModel\r\n",modelName, COMMENT_DESC, modelName];
    [modelHeaderStr appendString:header];
    
    
    header = [NSString stringWithFormat:@"//\r\n//  %@.m\r\n//  Json2Model Autogen\r\n//\r\n//  Created by Json2Model.\r\n//  Copyright (c) 2015年 All rights reserved.\r\n//\r\n\r\n#import \"%@.h\"\r\n\r\n@implementation %@\r\n\r\nCreate_Model_Imp(%@);\r\n\r\n\r\n+ (NSDictionary *)JSONKeyPathsByPropertyKey {\r\n\treturn @{\r\n",modelName,modelName,modelName,modelName];
    [modelImplStr appendString:header];
    
    NSString *template = @"\r\n%@\r\n@property (nonatomic,%@) %@%@;\r\n";
    NSString *template2 = @"\t\t\t\t@\"%@\" : @\"%@\",\r\n";
    
    for (NSString *key in dict) {
        id value = dict[key];
        NSString *line = nil;
        NSString *line2 = nil;
        NSString *type = nil;
        NSString *mode = nil;
        if ([value isKindOfClass:[NSString class]]) {
            mode = @"strong";
            type = @"NSString *";
        }
        else if ([value isKindOfClass:[NSNumber class]]){
            mode = @"assign";
            
            // 数值类型
            if (strcmp([value objCType], @encode(float)) == 0) {
                type = @"CGFloat ";
            }
            else if (strcmp([value objCType], @encode(double)) == 0){
                type = @"double ";
            }
            else if (strcmp([value objCType], @encode(NSInteger)) == 0 ){
                type = @"NSInteger ";
            }
            else if (strcmp([value objCType], @encode(long long)) == 0){
                type = @"long long ";
            }
            else if (strcmp([value objCType], @encode(long)) == 0){
                type = @"NSUInteger ";
            }
            else if (strcmp([value objCType], @encode(BOOL)) == 0){
                type = @"BOOL ";
            }
            else{
                type = @"NSNumber ";
            }
            
        }
        else if ([value isKindOfClass:[NSArray class]]){
            mode = @"strong";
            type = @"NSArray *";
        }
        else if ([value isKindOfClass:[NSDictionary class]]){
            mode = @"strong";
            type = @"NSDictionary *";
        }
        if (mode && type) {
            NSString *mkey = key;
            if([key isEqualToString:@"id"]){
                mkey = @"did";
            }
            else if ([key isEqualToString:@"description"]){
                mkey = @"desc";
            }
            line = [NSString stringWithFormat:template, COMMENT_DESC, mode, type, mkey];
            line2 = [NSString stringWithFormat:template2, mkey, key];
        }
        if (line) {
            [modelHeaderStr appendString:line];
        }
        if (line2) {
            [modelImplStr appendString:line2];
        }
    }
    [modelHeaderStr appendFormat:@"\r\nCreate_Model_Def(%@);\r\n\r\n@end",modelName];
    [modelImplStr appendString:@"\t\t};\r\n}\r\n\r\n@end\r\n"];
    
    [_txtModel setString:modelHeaderStr];
    [_txtImpModel setString:modelImplStr];
    
}

@end
