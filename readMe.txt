###################################################################
Stripe OLT
Usage Instructions
###################################################################

1. Download your onboarding script for Linux Server from your Security Portal 
https://security.microsoft.com/securitysettings/endpoints/onboarding?tid=<INSERT YOUR TENANT ID HERE>

2. Unzip the folder and save the onboarding script to the same location as the InstallAndConfigure script. 
**Note** The onboarding script must be called: onboarding_script.py

3. Run the InstallAndConfigure.sh script.
This should install mdatp automatically, by reconginising the Linux distribution and downloading the appropriate packages and using the correect commands. The script then waits for this install to complete before configuring MDATP to the required settings and then kicking off an initial scan.

