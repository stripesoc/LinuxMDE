#Bash script which configures the MDATP for Linux
#############################################################################################################
# Version  Author                 Description                   Company
#############################################################################################################
# 1.0      Liam Jones             Initial version              Stripe OLT
#############################################################################################################

#Variables
statusCodeInformation="[i]"
statusCodeSuccess="[+]"
statusCodeError="[-]"
statusCodeWarning="[!]"
statusCodeQuestion="[?]"

#############################################################################################################
#Get MDATP for Linux - Uses Microsofts automatic script
#############################################################################################################
echo "$statusCodeInformation Getting MDATP for Linux"
curl https://raw.githubusercontent.com/microsoft/mdatp-xplat/master/linux/installation/mde_installer.sh > mdatp_installer.sh
chmod +x mdatp_installer.sh

#check for a script called onboarding script.py located in the same directory
if [ -f "onboarding_script.py" ]; then
    #Output to the command Line infromation code plue Onboarding script found
    echo "$statusCodeSuccess Onboarding script found. Continuing..."
    #continue running the script
else
    #Output to the command Line infromation code plue Onboarding script not found
    echo "$statusCodeError Onboarding script not found, please download the onboarding script from the MDATP portal and place it in the same directory as this script."
    echo "$statusCodeInformation The onboarding script should be named 'onboarding_script.py'"
    echo "$statusCodeError Terminating"
    exit 1
fi

echo "$statusCodeInformation Installing MDATP for Linux"
sudo ./mdatp_installer.sh --install --channel prod --onboard ./onboarding_script.py

#get the process id of the last command and wait for that to finish before continuing
wait $!

#Output to the command Line infromation code plue Configuring MDATP for Linux
echo "$statusCodeInformation Configuring MDATP for Linux to Stripe OLT standards"


#############################################################################################################
# Check MDATP for Linux is installed and healthy
#############################################################################################################

echo "$statusCodeInformation Checking if MDATP for Linux is installed correctly"

#Check if the MDATP for Linux is installed by running the command mdatp and then checking to see if the next line of output is Expected one of:
#help, config, health, list, scan, isolate, unisolate, run, version, update, quarantine, unquarantine, restore, delete, log, service, and debug.
if [ "$(mdatp | awk 'NR==1')" = "Expected one of:" ]; then
    #Output to the command Line infromation code plue MDATP for Linux is installed
    echo "$statusCodeSuccess MDATP for Linux is installed"
    #continue running the script
else
    #Exit the config script
    echo "$statusCodeError MDATP for Linux is not installed, please check your installation and try again."
    echo "$statusCodeError Terminating"
    exit 1
fi

#check that the Organisation ID is set
#run the command mdatp health --field org_id and check it's not empty
if [ -z "$(mdatp health --field org_id)" ]; then
    #Output to the command Line infromation code plue Organisation ID is not set
    echo "$statusCodeError Organisation ID is not set"
    echo "$statusCodeQuestion Have you run the onboarding script?"
    echo "$statusCodeError Terminating"
    exit 1
else
    #Output to the command Line infromation code plue Organisation ID is set
    echo "$statusCodeSuccess Organisation ID is set"
    #continue running the script
fi

#Check that MDATP is healthy by running command mdatp health --field healthy if 1 then healthy
if [ "$(mdatp health --field healthy)" = "true" ]; then
    #Output to the command Line infromation code plue MDATP is healthy
    echo "$statusCodeSuccess MDATP is healthy. Continuing with configuration..."
    #continue running the script
else
    #Output to the command Line infromation code plue MDATP is not healthy
    echo "$statusCodeError MDATP is not healthy, check the MDATP service is running correctly."
    echo "$statusCodeWarning $(mdatp health --field health_issues)"
    echo "$statusCodeError Terminating"
    exit 1
fi

echo "$statusCodeInformation MDATP running and healthy, beginning configuration"

#############################################################################################################
# Configure MDATP for Linux - Root permissions required
#############################################################################################################
echo "$statusCodeInformation Configuring MDATP real-time protection"
#run command mdatp config real-time-protection --value enabled
sudo mdatp config real-time-protection --value enabled

echo "$statusCodeInformation Configuring MDATP to Block Potenially Unwanted Applications (PUA)"
sudo mdatp threat policy set --type potentially_unwanted_application --action block

#Configure Cloud protection
echo "$statusCodeInformation Configuring MDATP cloud protection"
#run command mdatp config cloud-protection --value enabled
sudo mdatp config cloud --value enabled

#run command mdatp config behavior-monitoring --value enabled
echo "$statusCodeInformation Configuring MDATP behavior monitoring"
sudo mdatp config behavior-monitoring --value enabled

echo "$statusCodeInformation Configuring MDATP network protection to audit mode"
sudo mdatp config network-protection enforcement-level --value audit

echo "$statusCodeInformation Configuring MDATP automatic definition updates"
#run command mdatp config automatic-updates --value enabled
sudo sudo mdatp config automatic-definitions-update --value enabled

echo "$statusCodeInformation Configuring maximum log size to 10Gb"
#run command mdatp config log-rotation-parameters max-rotated-size --size 10000
sudo mdatp config log-rotation-parameters max-rotated-size --size 10000

echo "$statusCodeSuccess Basic configuration complete"

#############################################################################################################
#Configure Additional Values - Root permissions not required
#############################################################################################################

echo "$statusCodeInformation Configuring Log Level"
# run command mdatp log level persist --level info
sudo mdatp log level persist --level info

echo "$statusCodeInformation Configure Block Mode"
sudo mdatp config passive-mode --value disabled

echo "$statusCodeInformation Running initial scan"
sudo mdatp scan full












