# prtg-sensor-vmware-uag
 Created by [NIOS AG](https://nios.ch)
 
 ## Description
Outputs a PRTG XML structure with multiple information about UAG

## Installation
### Sensor creation
 1. Copy the script file into the PRTG Custom EXEXML sensor directory:
    "C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML"

	- prtg-sensor-vmware-uag.ps1 (PowerShell Sensor Script)

 2. Select the parent device on which you want to check the Status/Statistics and choose Add sensor. Select the sensor type EXE/Script Advanced in the group Custom sensors. Adjust the following settings:

	- **Name:** Enter a name that allows for easy identification of the sensor.
	- **Tags:** Add custom Tag like "VMware-UAG"
	- **EXE/Script:** Select the corresponding script "prtg-sensor-vmware-uag.ps1"
	- **Parameters:** Set the parameters as required. See below for further Information and an example.
	- **Security Context:** Assert that the script is run under a useraccount which can access the server
	- **Result Handling:** For easier troubleshooting, it is advisable to store the result of the sensor in the logs directory, at a minimum if errors occure.

### Parameters
    -url "https://%host:9443/rest/v1/monitor/stats" -username "%windowsuser" -password "%windowspassword"

### Screenshot of sensor creation


### Screenshot of sensor overview


## Troubleshooting
If the sensors report errors please follow this steps to identity the cause:

- Make sure that the sensor stores the EXE result in the file system, so that you can access the error message in the folder C:\ProgramData\Paessler\PRTG Network Monitor\Logs (Sensors).
- Let the PRTG Sensor recheck the McAfee DAT Version.
- Check the LOG files.
