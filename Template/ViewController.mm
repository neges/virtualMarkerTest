//
//  ViewController.m
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//


//-------------------
//Template für metaio5.5beta
//-------------------


#import "ViewController.h"



@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    markerArray = [[NSArray alloc]init];
    
    [self createLogFile];
	   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createLogFile
{

    //Log File erzeugen
    
    //Documents Ornder abfragen
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    
    //Zeitstempel abfragen
    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH_mm_ss__ddMMyy"];
    NSString* str = [formatter stringFromDate:date];
    
    NSString *logFilename = [NSString stringWithFormat:@"%@.txt", str];
    
    //Log Datei
    logFile = [documentsDirectory stringByAppendingPathComponent:logFilename];
    
    [[NSFileManager defaultManager] createFileAtPath:logFile contents:[NSData data] attributes:nil];
    
    //erste Zeile schreiben
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logFile];
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    [handle writeData:[[NSString stringWithFormat:@"ID;TranslationX;TranslationY;TranslationZ;RotationX;RotationY;RotationZ;Pattern\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

    
}

-(IBAction)newLog:(id)sender
{
    [self createLogFile];
}


-(void)initCamera
{
	
	NSString *cameraParameters;
		
		
	//Parameter Abfragen
		cameraParameters = [NSString stringWithCString: m_metaioSDK->getCameraParameters(metaio::ECT_TRACKING).c_str()
											  encoding:[NSString defaultCStringEncoding]];
    
    NSLog(@"CameraParameters at Startup: %@",cameraParameters);
		
	//Setzen der idealen Kamera
    int resX = 1920;
    int resY = 1080;
    
		metaio::Vector2di imageResolution = metaio::Vector2di(resX,resY);
		metaio::Vector2d focalLength = metaio::Vector2d(resX,resX);
		metaio::Vector2d principalPoint = metaio::Vector2d (resX/2,resY/2);
		metaio::Vector4d distortion = metaio::Vector4d (0,0,0,0);

		m_metaioSDK->setCameraParameters(imageResolution, focalLength, principalPoint, distortion);
    
    
    
    
    
    m_metaioSDK->setCameraParameters(imageResolution, focalLength, principalPoint, distortion);
    
	
	
	//Parameter erneut abfragen
		cameraParameters = [NSString stringWithCString: m_metaioSDK->getCameraParameters(metaio::ECT_TRACKING).c_str()
											  encoding:[NSString defaultCStringEncoding]];

		NSLog(@"CameraParameters: %@",cameraParameters);
	
	
	
}

-(void)initTracking
{
	
	// load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_Marker" ofType:@"xml" inDirectory:@"Assets"];
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
	
	
}
-(void)loadTrackingImage:(NSString*)imgagefile
{

    
	//virtuelles Tracking
    markerPattern = imgagefile;
	NSString* trackingImage = [[NSBundle mainBundle] pathForResource:markerPattern ofType:@"jpg" inDirectory:@"Assets/marker"];
    m_metaioSDK->setImage([trackingImage UTF8String]);
	   
    
}

-(IBAction)getCameraParameters:(id)sender
{

	NSString *cameraParameters;
	
	//Parameter Abfragen
	cameraParameters = [NSString stringWithCString: m_metaioSDK->getCameraParameters(metaio::ECT_TRACKING).c_str()
										  encoding:[NSString defaultCStringEncoding]];
    
    NSLog(@"CameraParameters at Tracking: %@",cameraParameters);
	

}

#pragma mark - Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    //Marker laden
    NSError *error = nil;
    
    NSString *yourFolderPath = [[[NSBundle mainBundle] resourcePath]
                                stringByAppendingPathComponent:@"Assets/marker"];
    
    markerArray = [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:yourFolderPath error:&error];
    
    
    return markerArray.count;
    

    

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
	}
    
    
    // Configure the cell...
    NSString *cellText = [markerArray objectAtIndex:indexPath.row];
    cellText = [cellText substringToIndex:[cellText length] - 4] ;
    cell.textLabel.text = cellText ;

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self loadTrackingImage:cell.textLabel.text];

}



#pragma mark - Logging

-(void)logging

{
    

	//Qualität abfragen und anzeigen
		if ([logSwitch isOn ])
		{

            
            

			         
            //alle TrackingValues Abfragen
            metaio::stlcompat::Vector<metaio::TrackingValues> allTrackingValues = m_metaioSDK->getTrackingValues();
            
            for (int i = 0; i < allTrackingValues.size(); i++)
            {
                metaio::TrackingValues currentTrackingValues = allTrackingValues[i];
                
            
                
                
                
                if (currentTrackingValues.quality > 0)
                {
                    
                    //Translation  und Rotation abfragen
                    metaio::Vector3d markerTranslation = currentTrackingValues.translation;
                    metaio::Vector3d markerRotation = currentTrackingValues.rotation.getEulerAngleDegrees();
                    
                    
                    NSString *markerPose = [NSString stringWithFormat:@"%d;%1.3f;%1.3f;%1.3f;%1.3f;%1.3f;%1.3f;%@\r\n", i+1, markerTranslation.x, markerTranslation.y, markerTranslation.z, markerRotation.x, markerRotation.y, markerRotation.z,markerPattern];
                    
                    // Schreiben
                    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logFile];
                    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
                    [handle writeData:[markerPose dataUsingEncoding:NSUTF8StringEncoding]];
                    
                }
                
            }
            
            //logswitch nach einem druchlauf deaktivieren
            logSwitch.on = false;
            

            
        }
}




#pragma mark - @protocol metaioSDKDelegate

- (void) drawFrame
{
    [super drawFrame];
    
    [self logging];
    

}

- (void) onSDKReady
{
    NSLog(@"The SDK is ready");
	
    [self initCamera];
	[self initTracking];
}

- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(NSString*) animationName
{
    NSLog(@"animation ended %@", animationName);
}


- (void) onMovieEnd: (metaio::IGeometry*) geometry  andName:(NSString*) movieName
{
	NSLog(@"movie ended %@", movieName);
	
}

- (void) onNewCameraFrame:(metaio::ImageStruct *)cameraFrame
{
    NSLog(@"a new camera frame image is delivered %f", cameraFrame->timestamp);
}

- (void) onCameraImageSaved:(NSString *)filepath
{
    NSLog(@"a new camera frame image is saved to %@", filepath);
}

-(void) onScreenshotImage:(metaio::ImageStruct *)image
{
    
    NSLog(@"screenshot image is received %f", image->timestamp);
}

- (void) onScreenshotImageIOS:(UIImage *)image
{
    NSLog(@"screenshot image is received %@", [image description]);
}

-(void) onScreenshot:(NSString *)filepath
{
    NSLog(@"screenshot is saved to %@", filepath);
}

- (void) onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
    NSLog(@"The tracking time is: %f", trackingValues[0].timeElapsed);
}

- (void) onInstantTrackingEvent:(bool)success file:(NSString*)file
{
    if (success)
    {
        NSLog(@"Instant 3D tracking is successful");
    }
}

- (void) onVisualSearchResult:(bool)success error:(NSString *)errorMsg response:(std::vector<metaio::VisualSearchResponse>)response
{
    if (success)
    {
        NSLog(@"Visual search is successful");
    }
}

- (void) onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
    if (state == metaio::EVSS_SERVER_COMMUNICATION)
    {
        NSLog(@"Visual search is currently communicating with the server");
    }
}

@end
