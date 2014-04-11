//
//  ViewController.m
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//


//-------------------
//Template für metaio5.3
//-------------------


#import "ViewController.h"

class Callback : public metaio::IShaderMaterialOnSetConstantsCallback
{
public:
	Callback(ViewController* vc) :
    m_vc(vc)
	{
	}
    
private:
	virtual void onSetShaderMaterialConstants(const metaio::stlcompat::String& shaderMaterialName, void* extra,
                                              metaio::IShaderMaterialSetConstantsService* constantsService) override
	{
    // This will be identical to m_pModel since we only assigned this callback to that single geometry:
    // metaio::IGeometry* geometry = static_cast<metaio::IGeometry*>(extra);
    
    // We just pass the positive sinus (range [0;1]) of absolute time in seconds so that we can
    // use it to fade our effect in and out.
    const float time[1] = { 0.5f * (1.0f + (float)sin(CACurrentMediaTime())) };
    constantsService->setShaderUniformF("myValue", time, 1);
}

// This is here in case you need access to the view controller's methods (not used in this example)
ViewController*	m_vc;
};



@interface ViewController ()

@end

@implementation ViewController
{
	Callback*		m_pCallback;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
	
	if( !m_metaioSDK )
    {
        NSLog(@"SDK instance is 0x0. Please check the license string");
        return;
    }
	
    [self initCamera];
	[self initTracking];
	
	
    //[self initContent ];
    //[self initLight];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initCamera
{
	
	NSString *cameraParameters;
		
		
	//Parameter Abfragen
		cameraParameters = [NSString stringWithCString: m_metaioSDK->getCameraParameters(metaio::ECT_TRACKING).c_str()
											  encoding:[NSString defaultCStringEncoding]];

		NSLog(@"Standard: %@",cameraParameters);
		
		
	//Setzen der idealen Kamera
		metaio::Vector2di imageResolution = metaio::Vector2di(640,400);
		metaio::Vector2d focalLength = metaio::Vector2d(640,640);
		metaio::Vector2d principalPoint = metaio::Vector2d (320,200);
		metaio::Vector4d distortion = metaio::Vector4d (0,0,0,0);

		m_metaioSDK->setCameraParameters(imageResolution, focalLength, principalPoint, distortion);
	
	
	//Parameter erneut abfragen
		cameraParameters = [NSString stringWithCString: m_metaioSDK->getCameraParameters(metaio::ECT_TRACKING).c_str()
											  encoding:[NSString defaultCStringEncoding]];

		NSLog(@"Ideal: %@",cameraParameters);
	
	
	
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
	
	//virtuelles Tracking
	NSString* trackingImage = [[NSBundle mainBundle] pathForResource:@"ID" ofType:@"jpg" inDirectory:@"Assets"];
	NSLog(@"%@", trackingImage);
	metaio::Vector2di currentImageSize = m_metaioSDK->setImage([trackingImage UTF8String]);
	NSLog(@"Image Size : %d / %d", currentImageSize.x, currentImageSize.y);
	
}


-(void)initContent
{
    
    
    // load content
    NSString* model = [[NSBundle mainBundle] pathForResource:@"agrm" ofType:@"obj" inDirectory:@"Assets/3D"];
    
    
    
    metaio::IGeometry* theLoadedModel;
	if(model)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        theLoadedModel =  m_metaioSDK->createGeometry([model UTF8String]);
        if( theLoadedModel )
        {
            // scale it a bit down
            theLoadedModel->setScale(metaio::Vector3d(1,1,1));
        }
        else
        {
            NSLog(@"error, could not load %@", model);
        }
        
    }
    
    NSString* shaderMaterialsFilename = [[NSBundle mainBundle] pathForResource:@"shader_materials" ofType:@"xml" inDirectory:@"Assets/Shader"];
    
	if (shaderMaterialsFilename)
	{
		if (!m_metaioSDK->loadShaderMaterials([shaderMaterialsFilename UTF8String]))
		{
			NSLog(@"Failed to load shader materials from %@", shaderMaterialsFilename);
		}
		else
		{
			// Successfully loaded shader materials
			if (model)
			{
				theLoadedModel->setShaderMaterial("tutorial11");
                
				m_pCallback = new Callback(self);
                
				theLoadedModel->setShaderMaterialOnSetConstantsCallback(m_pCallback);
			}
		}
    }
	else
		NSLog(@"Shader materials XML file not found");
    
    


}

#pragma mark - Light

-(void)initLight
{

    metaio::ILight*		m_pLight;
    
    m_pLight = m_metaioSDK->createLight();
    m_pLight->setType(metaio::ELIGHT_TYPE_DIRECTIONAL);
    
    m_metaioSDK->setAmbientLight(metaio::Vector3d(0.05f));
    m_pLight->setDiffuseColor(metaio::Vector3d(1, 1, 1)); // white
    
    m_pLight->setCoordinateSystemID(0);

    
}





#pragma mark - @protocol metaioSDKDelegate

- (void) drawFrame
{
    [super drawFrame];
    

}

- (void) onSDKReady
{
    NSLog(@"The SDK is ready");
	
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
