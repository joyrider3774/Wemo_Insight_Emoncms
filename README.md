# Wemo Insight Emoncms

Read wemo insight power usuage and send the data to emoncms

## Build
Make sure you use Delphi XE, open the dpr file from the source directory and compile. It was written using delphi XE 7.

Next, create a config file per wemo insight you have.

## Prebuild version
A Prebuild windows version is availible here in the Release directory (https://github.com/joyrider3774/Wemo_Insight_Emoncms/blob/master/Releases/WemoInsightEmoncms-1.0.zip?raw=true)

## Usage
```
WemoInsightEmoncms.exe 
  -conf filename.conf : Specify the config file to be used, if this parameter is omitted WemoInsightEmoncms.conf will be used 
```

## Configfile
See WemoInsight1.conf (https://github.com/joyrider3774/Wemo_Insight_Emoncms/blob/master/Example_configs/WemoInsight1.conf)

```
Debug:      can ben 1 or 0 to display more data while running (i leave it mostly at 1) 
Delay:      How long to wait in seconds between each run (io getting the power usage and sending it to emoncms) for example 5
EmonNode:   The node to be used in your emoncms installation, if the node does not exist it will be created for example 5
EmonUrl:    The url pointing at the root of your emoncms installation, this can be a local or online version for example Http://localhost:8083/emoncmsnew
EmonApiKey: Your emoncms write api key
WemoIp:     The ip adress of your wemo insight, it might be a good idea to give it a fixed ip based on the mac address in your router. For example 192.168.0.114
WemoPort:   The port to connect to the wemo for example 49153, 49154, 49155. The wemo insight seems to switch ports from time to time. 
            The program does not detect this and you'll have to change the config when this happens
```

If WemoInsightEmoncms.conf exists in the current directory it will be used, otherwise a config file can specified using the -conf flag  
 
## Watchdog
Somtimes WemoInsightEmoncms will not be able to connect to the device and will quit when this happens. A sample windows batch file is included to start 
WemoInsightEmoncms in a loop so that whenever WemoInsightEmoncms quits it is automatically restarted (see https://github.com/joyrider3774/Wemo_Insight_Emoncms/blob/master/Example_configs/WemoInsight1.bat)
It is advised to use this method, otherwise you will need to restart the program a lot of times manually whenever any kind of error happens. The program
is setup in such a way that it quits whenever an error occurred

## Flaw / not implemented
The wemo insight does not use a fixed port, it alternates ports after some period of time. Ive seen it use the following ports already 49153, 49154, 49155. 
When the port changes while the program is running it won't be able to connect anymore until you change the port to the correct one in the config file. I have not (yet) implemented
a way to automatically change ports or specify multiple ports to try in the config 