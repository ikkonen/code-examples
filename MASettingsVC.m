//
//  MASettingsVC.m
//  MOJEALZA
//
//  Created by Alexandra Shmidt on 25.10.13.
//  Copyright (c) 2013 Zentity. All rights reserved.
//

#import "MASettingsVC.h"
#import "MALocalStoreManager.h"
#import "MAMetadataClient.h"
#import "ZENDataFormatter.h"
#import "MALoginVC.h"

@interface MASettingsVC ()

@end

@implementation MASettingsVC

#pragma mark - Life style

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarItem.title = ZENLocalized(@"Settings");
    
    _downloadingLabel.text = ZENLocalized(@"Downloading data");
    _downloadingLabel2.text = ZENLocalized(@"Downloading data");
    _settingsWiFiLabel.text = ZENLocalized(@"Download only with WiFi");
    [_showDownloadedDataBtn setTitle:ZENLocalized(@"Show downloaded data list") forState:UIControlStateNormal];
    
    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    tmpLabel.backgroundColor = [UIColor clearColor];
    tmpLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tmpLabel.text = ZENLocalized(@"Settings");
    [tmpLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.f]];
    [tmpLabel setTextAlignment:NSTextAlignmentCenter];
    [tmpLabel setTextColor:kDarkBlueTitleColor];
    self.navigationItem.titleView = tmpLabel;
    
    //setup design
    UIImage *loginBtnBg = [[UIImage imageNamed:@"button_prihlasit"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [_loginBtn setBackgroundImage:loginBtnBg forState:UIControlStateNormal];
    
    BOOL useWiFiOnlyConfig = [[[NSUserDefaults standardUserDefaults] valueForKey:kUseWiFiOnlyConfig] boolValue];
    _switchWiFiUsage.on = useWiFiOnlyConfig;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"settings_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) ? @"" : ZENLocalized(@"Back");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // set login button title
    MAMetadataClient *client = [MAMetadataClient instance];
    if (!client.isUserLoggedIn) {
        NSMutableAttributedString *loginStr = [[NSMutableAttributedString alloc] initWithString:ZENLocalized(@"Sign in")];
        [loginStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor colorWithRed:0.0f green:0.314f blue:0.0314f alpha:1.0f]} range:NSMakeRange(0, loginStr.length)];
        [_loginBtn setAttributedTitle:loginStr forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    } else{
        NSMutableAttributedString *logoutStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", ZENLocalized(@"Logout"),(client.userName) ? client.userName : @""]];
        NSMutableDictionary *attributes = [@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor colorWithRed:0.329f green:0.329f blue:0.329f alpha:1.0f]} mutableCopy];
        [logoutStr addAttributes:attributes range:NSMakeRange(0, ZENLocalized(@"Logout").length)];
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:12];
        [logoutStr addAttributes:attributes range:NSMakeRange(ZENLocalized(@"Logout").length+1, client.userName.length+2)];

        [_loginBtn setAttributedTitle:logoutStr forState:UIControlStateNormal];
        
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"logoutBtn"] forState:UIControlStateNormal];
    }

    if ([[MALocalStoreManager instance] totalContentSize].floatValue != 0.0f) {
        NSString *size =  [[ZENDataFormatter instance] formatNumberValue:[[MALocalStoreManager instance] totalContentSize]];
        NSString *removeBtnTitle = [NSString stringWithFormat:@"%@ (%@)", ZENLocalized(@"Remove all"), size];
        [_removeDataBtn setTitle:removeBtnTitle forState:UIControlStateNormal];
        _removeDataBtn.hidden = NO;
        _removeDataLine.hidden = NO;
    } else {
        _removeDataBtn.hidden = YES;
        _removeDataLine.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Actions

- (IBAction)switchValueWasChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@(_switchWiFiUsage.on) forKey:kUseWiFiOnlyConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWiFiUsageSettingsWereChanged object:nil];
}

- (IBAction)removeAllContent:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ZENLocalized(@"Attention!")
                               message:ZENLocalized(@"Are you sure, you want to remove all data?")
                              delegate:self
                     cancelButtonTitle:ZENLocalized(@"Cancel")
                     otherButtonTitles:ZENLocalized(@"Remove"), nil];
    [alert show];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[MALocalStoreManager instance] removeAllData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAllDataWereRemoved object:nil];
        [self viewWillAppear:YES];
    }
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"logout"] && [MAMetadataClient instance].isUserLoggedIn == YES) {
        [[MAMetadataClient instance] logout];
        
         MALoginVC *loginVC = (MALoginVC *)segue.destinationViewController;
        [loginVC cleanCredentials];
    }
}

@end
