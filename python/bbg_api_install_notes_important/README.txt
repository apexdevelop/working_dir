Installation:
1.Download Desktop API
2.Set the 'BLPAPI_ROOT' environment variable to the location at which the Bloomberg C++ SDK is installed. For instance, on Windows, this location may be of the form "C:\blp\DAPI\APIv3\C++API\x.x.x.x\" [where x.x.x.x refers to the version of the latest C++ API SDK you installed] 
3.Add the path to the C++ BLPAPI library to your PATH environment variable. Using the above example, the path would be C:\blp\DAPI\APIv3\C++API\x.x.x.x\lib or C:\blp\DAPI\APIv3\C++API\x.x.x.x\bin. 
4.better to use wheel installer directly since the downloaded python api zip file needs extension package in C which involves complicated C++ compiler issue. So follow the Python Wheel Installer Guide word file and just pip install