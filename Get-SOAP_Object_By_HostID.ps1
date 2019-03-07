Clear-Host
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$Credentials = (Get-Content "$PSScriptRoot\DS-Config.json" -Raw) | ConvertFrom-Json

$Manager = $Credentials.MANAGER
$Port = $Credentials.PORT
$Tenant = $Credentials.TENANT
$UserName = $Credentials.USER_NAME
$Password = $Credentials.PASSWORD
$APIKEY = $Credentials.APIKEY

$ErrorActionPreference = 'Stop'

$WSDL = "/webservice/Manager?WSDL"
$DSM_URI = "https://" + $Manager+ ":" + $Port + $WSDL

$HostID = ""
$sID = ""

[xml] $SoapRequest = '
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Manager">
   <soapenv:Header/>
   <soapenv:Body>
      <urn:hostDetailRetrieve>
         <urn:hostFilter>
            <urn:hostID></urn:hostID>
            <urn:type>SPECIFIC_HOST</urn:type>
         </urn:hostFilter>
         <urn:hostDetailLevel>LOW</urn:hostDetailLevel>
         <urn:sID></urn:sID>
      </urn:hostDetailRetrieve>
   </soapenv:Body>
</soapenv:Envelope>
'

$SoapRequest.Envelope.Body.hostDetailRetrieve.hostFilter.hostID = $HostID
$SoapRequest.Envelope.Body.hostDetailRetrieve.sID = $sID

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "text/xml")
$headers.Add("soapaction", "hostDetailRetrieve")

[xml] $obj_Manager = Invoke-WebRequest -Uri $DSM_URI -Headers $headers -Method Post -Body $SoapRequest -SkipHeaderValidation

$Results = $obj_Manager.Envelope.Body.hostDetailRetrieveResponse.hostDetailRetrieveReturn
$LastRecommendationScan = $Results.overallLastRecommendationScan

If ($LastRecommendationScan.IsEmpty){
   Write-Host "No Recommendation scan exist"
}Else{
   Write-Host $LastRecommendationScan
}



