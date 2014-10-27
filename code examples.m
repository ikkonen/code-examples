#pragma mark - Setup Reachability
- (void (^)(AFNetworkReachabilityStatus status))reachabilityStatusChangeBlockWithWiFi{
    __block MAMetadataClient *blockSelf = self;
    return ^(AFNetworkReachabilityStatus status) {
        //read user settings for internet connection
        BOOL useWiFiOnlyConfig = [[[NSUserDefaults standardUserDefaults] valueForKey:kUseWiFiOnlyConfig] boolValue];
        
        //check if internet connection was disappeared:
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [blockSelf.operationQueue setSuspended:YES];
            NSLog(@"Not connected to the internet");
        } else if (useWiFiOnlyConfig == YES && status != AFNetworkReachabilityStatusReachableViaWiFi) {
            //check if user selected via WiFi
            [blockSelf.operationQueue setSuspended:YES];
            NSLog(@"Not connected to the wifi");
        } else{
            [blockSelf.operationQueue setSuspended:NO];
            [[MADownloadManager instance] reloadUnfinishedItems];
        }
    };
}

//....

- (void)reinitDownloadedItemList{
    void(^readOfflineDataOrCreateIndex)(Class class, NSString *path, NSMutableArray **storeData, NSMutableArray **parsedData) = ^(Class class, NSString *path, NSMutableArray **storeData, NSMutableArray **parsedData){
        NSLog(@"%s\n%@", __PRETTY_FUNCTION__, path);
        NSLog(@"%@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil]);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            *storeData = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:0
                                                            error:nil] mutableCopy];
            *parsedData = [NSMutableArray arrayWithCapacity:(*storeData).count];
            [*storeData enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
                [*parsedData addObject:[[class alloc] initWithJSONDictionary:data]];
            }];
        } else {
            *storeData = [NSMutableArray array];
            *parsedData = [NSMutableArray array];
        }
    };
    
    // read offline data for e-books or create empty index objects
    NSString *eBooksIndexPath = [[self eBooksDir] stringByAppendingPathComponent:@"index"];
    NSMutableArray *storeData, *parsedData;
    readOfflineDataOrCreateIndex([EBookVO class], eBooksIndexPath, &storeData, &parsedData);
    _storeEBooksData = storeData;
    _parsedEBooksData = parsedData;
    
    // read offline data for free e-books or create empty index objects
    NSString *eBooksFreeIndexPath = [[self eBooksFreeDir] stringByAppendingPathComponent:@"index"];
    readOfflineDataOrCreateIndex([EBookVO class], eBooksFreeIndexPath, &storeData, &parsedData);
    _storeEBooksFreeData = storeData;
    _parsedEBooksFreeData = parsedData;
    
    // read offline data for audio books or create empty index objects
    NSString *audioBooksIndexPath = [[self audioBooksDir] stringByAppendingPathComponent:@"index"];
    readOfflineDataOrCreateIndex([AudioBookVO class], audioBooksIndexPath, &storeData, &parsedData);
    _storeAudioBooksData = storeData;
    _parsedAudioBooksData = parsedData;
    
    // read offline data for free audio books or create empty index objects
    NSString *audioBooksFreeIndexPath = [[self audioBooksFreeDir] stringByAppendingPathComponent:@"index"];
    readOfflineDataOrCreateIndex([AudioBookVO class], audioBooksFreeIndexPath, &storeData, &parsedData);
    _storeAudioBooksFreeData = storeData;
    _parsedAudioBooksFreeData = parsedData;
    
    // read offline data for audio books or create empty index objects
    NSString *musicAlbumsIndexPath = [[self albumsDir] stringByAppendingPathComponent:@"index"];
    readOfflineDataOrCreateIndex([MAMusicAlbumVO class], musicAlbumsIndexPath, &storeData, &parsedData);
    _storeAlbumsData = storeData;
    _parsedAlbumsData = parsedData;
    
    // read offline data for free audio books or create empty index objects
    NSString *musicAlbumsFreeIndexPath = [[self albumsFreeDir] stringByAppendingPathComponent:@"index"];
    readOfflineDataOrCreateIndex([MAMusicAlbumVO class], musicAlbumsFreeIndexPath, &storeData, &parsedData);
    _storeAlbumsFreeData = storeData;
    _parsedAlbumsFreeData = parsedData;
    
    NSString * downloadedBooksIndexPath = [[self rootStoreDir] stringByAppendingPathComponent:@"localIndex.bin"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedBooksIndexPath]) {
        _downloadedItems = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:downloadedBooksIndexPath]];
    } else {
        _downloadedItems = [NSMutableArray array];
    }
}
