# B2BLogicApps
Samples for multiple scenario of Logic Apps E2E

Prerequisites: 

Latest Azure SDK (2.9.1 or greater)
Azure PowerShell

There are Four different scenario logic apps E2E with Deployment, artifacts ( agreements, Certs, Schemas and transform) and sample Message were also added.

Scenario 1: Individual Encode/Send/Outbound message and Decode/Receive/Inbound

      Steps: 	Copy IndividualDecodeand EncodeLogicApps to local machine.
    Open PowerShell or PowerShell ISE as Admin.
    Navigate to the copied local folder and open “Deploy-AzureResourceGroup.ps1”.
    Update the below parameters in “Deploy-AzureResourceGroup.ps1” file.
    $ResourceGroupName  (“Name of the Resource Group Does not have to be already deployed”)
    $ResourceGroupLocation (“Location of the Resource Group)
    $SubscriptionId (“Subscription Id”)
        Execute the PowerShell script.
        For sending a message to Send/OutBound/Encode logic app (EncodeB2BLA) get the URL of the Http Request and use the message from “EncodeLAInputMessage.txt” file.
          AS2 Signing, Encryption and Compression are enabled for this flow.
        For sending a message to Receive/Inbound/Decode logic app (DecodeB2BLA) get the URL of the Http Request and use the message from “DecodeLAInputMessage.txt” file.

Scenario 2: B2B Message flow E2E Inbound/Receive/Decode => OutBound/Send/Encode 

	Steps: 	Copy E2EB2BMessageFlowWhenaMesageIsReceived to local machine.
      Open PowerShell or PowerShell ISE as Admin.
      Navigate to the copied local folder and open “Deploy-AzureResourceGroup.ps1”.
      Update the below parameters in “Deploy-AzureResourceGroup.ps1” file.
      $ResourceGroupName  (“Name of the Resource Group Does not have to be already deployed”)
      $ResourceGroupLocation (“Location of the Resource Group)
      $SubscriptionId (“Subscription Id”)
          Execute the PowerShell script.
          Send a message to Receive/Inbound/Decode logic app (DecodeB2BLA) get the URL of the Http Request and use the message from “DecodeLAInputMessage.txt” file.
            AS2 Signing, Encryption and Compression are enabled for Encode flow.

Scenario 3: B2B Message flow OutBound/Send/Encode => E2E Inbound/Receive/Decode 

	Steps: 	Copy E2EB2BMessageFlowWhenaMesageIsSentto local machine.
    Open PowerShell or PowerShell ISE as Admin.
    Navigate to the copied local folder and open “Deploy-AzureResourceGroup.ps1”.
    Update the below parameters in “Deploy-AzureResourceGroup.ps1” file.
    $ResourceGroupName  (“Name of the Resource Group Does not have to be already deployed”)
    $ResourceGroupLocation (“Location of the Resource Group)
    $SubscriptionId (“Subscription Id”)
        Execute the PowerShell script.
        Send a message to Receive/Inbound/Decode logic app (EncodeB2BLA) get the URL of the Http Request and use the message from “EncodeLAInputMessage.txt” file.
          AS2 Signing, Encryption and Compression are enabled for Encode and Decode flow.


Scenario 4: This includes Scenario 2 , 3 with Primary and secondary resource groups. Also includes DR x12 and As2 sync logic apps for the DR exercise.
		With this scenario deployment we will have DR sync logic apps in both Resource groups but the primary will be disabled.
		Documentation for DR scenario can be found here (https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-enterprise-integration-b2b-business-continuity)

              Steps: 	Copy E2EB2BMessageFlowWhenaMesageIsSentto local machine.
            Open PowerShell or PowerShell ISE as Admin.
            Navigate to the copied local folder and open “Deploy-AzureResourceGroup.ps1”.
            Update the below parameters in “Deploy-AzureResourceGroup.ps1” file for primary Region.
            $ResourceGroupName  (“Name of the Resource Group Does not have to be already deployed”)
            $ResourceGroupLocation (“Location of the Resource Group)
            $SubscriptionId (“Subscription Id”)
                Execute the PowerShell script.
            Update the below parameters in “Deploy-AzureResourceGroup.ps1” file for secondary Region.
            $ResourceGroupName  (“Name of the Resource Group Does not have to be already deployed”)
            $ResourceGroupLocation (“Location of the Resource Group)
            $SubscriptionId (“Subscription Id”)
                Execute the PowerShell script.
            Update the below parameters in “DR-Deploy-AzureResourceGroup.ps1” file.
            $ResourceGroupName  (“Name of the Resource Group Does not have to be already deployed”)
            $ResourceGroupLocation (“Location of the Resource Group)
            $SubscriptionId (“Subscription Id”)
            $SecondaryResourceGroupName  (“secondary Resource group name”)
            $SecondaryResourceGroupLocation  (“secondary Resource group Location”)

          Send a message to Receive/Inbound/Decode logic app (EncodeB2BLA) get the URL of the Http Request and use the message from “EncodeLAInputMessage.txt” file.
            AS2 Signing, Encryption and Compression are enabled for Encode and Decode flow.
          Send a message to Receive/Inbound/Decode logic app (DecodeB2BLAE2E) get the URL of the Http Request and use the message from “DecodeLAInputMessage.txt” file.
            AS2 Signing, Encryption and Compression are enabled for Encode and Decode flow.
          We can do the above two steps in both primary and secondary resource groups.





