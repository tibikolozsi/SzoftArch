//
//  DetailViewController.m
//  SzoftverArch
//
//  Created by Tibi Kolozsi on 21/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

#import "DetailViewController.h"
#import "SzoftverArch-Swift.h"
#import "Data.h"

@interface DetailViewController () <LineChartDataSource>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet LineChartView *LineChartView;
@property (nonatomic) NSMutableArray* data;
@end

@implementation DetailViewController
- (IBAction)logoutButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.LineChartView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateDetailWithType:(DetailType)type dictionary:(NSDictionary *)dictionary
{
    switch (type) {
        case DetailTypeAllGroups:
            self.navigationItem.title = @"All groups";
            break;
        case DetailTypeSelectedGroup:
            self.navigationItem.title = [dictionary objectForKey:@"groupname"];
            break;
        case DetailTypeSelectedUser:
        {
            NSString* username = [dictionary objectForKey:@"username"];
            NSString* groupname = [dictionary objectForKey:@"groupname"];
            self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",groupname,username];
            break;
        }
        default:
            break;
    }
    self.data = [NSMutableArray array];
    for (int i = 0 ; i< 10; i++) {
        [self.data addObject:[[Data alloc] initWithValue:arc4random() text:[NSString stringWithFormat:@"Text %d",i]]];
    }
    [self.LineChartView reloadData];
    self.label.text = [self stringValueFromDetailType:type];
}

- (NSString*)stringValueFromDetailType:(DetailType)type
{
    NSString* stringValue;
    switch (type) {
        case DetailTypeAllGroups:
            stringValue = @"DetailTypeAllGroup";
            break;
        case DetailTypeSelectedGroup:
            stringValue = @"DetailTypeSelectedGroup";
            break;
        case DetailTypeSelectedUser:
            stringValue = @"DetailTypeSelectedUser";
            break;
        default:
            stringValue = @"Default, maybe something is wrong";
            break;
    }
    return stringValue;
}

- (NSInteger)lineChartNumberOfData:(LineChartView *)lineChart
{
    return [self.data count];
}

- (float)lineChartValueForData:(LineChartView *)linechart index:(NSInteger)index
{
    Data* currentData = [self.data objectAtIndex:index];
    return currentData.value;
}

- (NSString *)lineChartTextForData:(LineChartView *)lineChart index:(NSInteger)index
{
    Data* currentData = [self.data objectAtIndex:index];
    return currentData.text;
}

- (UIColor *)lineChartDotColorForData:(LineChartView *)lineChart index:(NSInteger)index
{
    return [UIColor blueColor];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
