######################################################################################################################
###                                                                                                                ###
###  	Script by Terry Munro -                                                                                    ###
###     Technical Blog -               http://365admin.com.au                                                      ###
###     Webpage -                      https://www.linkedin.com/in/terry-munro/                                    ###
###     TechNet Gallery Scripts -      http://tinyurl.com/TerryMunroTechNet                                        ###
###     Version -                      Version 1.0                                                                 ###
###     Version History                Version 1.0 - 26/11/2017                                                    ###
###                                    Version 1.1 - Added PowerShell variable - to prevent truncation of results  ###
###                                                                                                                ###
###     Support                        http://www.365admin.com.au/2017/11/how-to-document-local-exchange.html      ###
###                                                                                                                ###
###     Download Link                  https://gallery.technet.microsoft.com/Exchange-Org-documentation-9b8ca5ef   ###
###                                                                                                                ###
######################################################################################################################

##############################################################################################################################
###                                                                                                                        ###
###  	Script Notes                                                                                                       ###
###     Script has been created to document the current local Exchange environment                                         ###
###     Script has been tested on Exchange 2007 - Server 2008                                                              ###
###                                                                                                                        ###
###     Note, you must run Exchange 2007 Exchange Management Shell as Administrator                                        ###
###                                                                                                                        ###
###     Update the variable - $logpath - to set the location you want the reports to be generated                          ###
###                                                                                                                        ###
##############################################################################################################################


### Update the log path variables below before running the script ####

$logpath = "c:\reports"


########################################################

### Do not change the variable below


$FormatEnumerationLimit=-1

########################################################





Get-ExchangeCertificate | Where {($_.IsSelfSigned -eq $False)} | Select CertificateDomains, Issuer, NotAfter, RootCAType, Services, Status, Subject | Out-File "$logpath\01.ExchangeCertificate.txt" -NoClobber -Append

Get-OwaVirtualDirectory | Select Name,Server,InternalURL,ExternalURL | Out-String -Width 4096 | Out-File "$logpath\02.OwaVirtualDirectory.txt" -NoClobber -Append

Get-ActiveSyncVirtualDirectory | Select Name,Server,InternalURL,ExternalURL | Out-String -Width 4096 | Out-File "$logpath\03.ActiveSyncVirtualDirectory.txt" -NoClobber -Append

Get-ClientAccessServer | Select  Name,AutoDiscoverServiceCN,AutoDiscoverServiceInternalUri,OutlookAnywhereEnabled | Out-String -Width 4096 | Out-File "$logpath\04.OutlookAnywhere.txt" -NoClobber -Append

Get-AutodiscoverVirtualDirectory | Select Name,Server,InternalUrl,ExternalURL | Out-String -Width 4096 | Out-File "$logpath\05.AutodiscoverVirtualDirectory.txt" -NoClobber -Append

Get-OabVirtualDirectory | Select Name,Server,InternalURL,ExternalURL | Out-String -Width 4096 | Out-File "$logpath\06.OabVirtualDirectory.txt" -NoClobber -Append

Get-WebServicesVirtualDirectory | Select Name,Server,InternalURL,ExternalURL | Out-String -Width 4096 | Out-File "$logpath\07.WebServicesVirtualDirectory.txt" -NoClobber -Append

Get-AcceptedDomain | Out-File "$logpath\08.AcceptedDomain.txt" -NoClobber -Append

Get-EmailAddressPolicy | Select Name,RecipientFilter,RecipientFilterApplied,IncludeRecipients,EnabledPrimarySMTPAddressTemplate,EnabledEmailAddressTemplates,Enabled,IsValid | Out-File "$logpath\09.EmailAddressPolicy.txt" -NoClobber -Append

Get-ReceiveConnector | Select Name,Enabled,ProtocolLoggingLevel,FQDN,MaxMessageSize,Bindings,RemoteIPRanges,AuthMechanism,PermissionGroups | Out-File "$logpath\10.ReceiveConnectors.txt" -NoClobber -Append

Get-SendConnector | Select Name,Enabled,ProtocolLoggingLevel,SmartHostsString,FQDN,MaxMessageSize,AddressSpaces,SourceTransportServers | Out-File "$logpath\11.SendConnectors.txt" -NoClobber -Append

Get-TransportServer | Select Name,InternalDNSServers,ExternalDNSServers,OutboundConnectionFailureRetryInterval,TransientFailureRetryInterval,TransientFailureRetryCount,MessageExpirationTimeout,DelayNotificationTimeout,MaxOutboundConnections,MaxPerDomainOutboundConnections,MessageTrackingLogEnabled,MessageTrackingLogPath,ConnectivityLogEnabled,ConnectivityLogPath,SendProtocolLogPath,ReceiveProtocolLogPath | Out-File "$logpath\12.TransportConfiguration.txt" -NoClobber -Append

Get-Mailboxdatabase | Select Servers,Name,EDBFilePath,LogFolderPath,MaintenanceSchedule,JournalRecipient,CircularLoggingEnabled,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota,DeletedItemRetention,MailboxRetention,RetainDeletedItemsUntilBackup,OfflineAddressBook,LastFullBackup,LastIncrementalBackup,LastDifferentialBackup,DatabaseSize | Out-String -Width 4096 | Out-File "$logpath\13.MailboxDatabaseConfigs.txt" -NoClobber -Append

Get-ExchangeServer | Select Name,Server,Domain,FQDN,ServerRole,IsMemberOfCluster,AdminDisplayVersion | Out-String -Width 4096 | Out-File "$logpath\14.ExchangeServer.txt" -NoClobber -Append

Get-ActiveSyncMailboxPolicy | Select Name,AllowNonProvisionableDevices,DevicePolicyRefreshInterval,PasswordEnabled,MaxCalendarAgeFilter,MaxEmailAgeFilter,MaxAttachmentSize,RequireManualSyncWhenRoaming,AllowHTMLEmail,AttachmentsEnabled,AllowStorageCard,AllowCameraTrue,AllowWiFi,AllowIrDA,AllowInternetSharing,AllowRemoteDesktop,AllowDesktopSync,AllowBluetooth,AllowBrowser,AllowConsumerEmail,AllowUnsignedApplications,AllowUnsignedInstallationPackages | Out-File "$logpath\15.ActiveSyncMailboxPolices.txt" -NoClobber -Append

Get-TransportRule | Select Name,Priority,Description,Comments,State | Out-File "$logpath\16.TransportRules.txt" -NoClobber -Append

Get-ExchangeAdministrator | Out-File "$logpath\17.ExchangeAdministrators.txt" -NoClobber -Append

### The following scripts output mailbox permissions ###

Get-Mailbox | Get-ADPermission | where {($_.ExtendedRights -like "*Send-As*") -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF")} | Select Identity,Trustee,AccessRights | Export-Csv -NoTypeInformation "$logpath\MailboxSendAsAccess-LocalExchange.csv"

Get-Mailbox -ResultSize Unlimited |  ? {$_.GrantSendOnBehalfTo -ne $null} | select Name,Alias,UserPrincipalName,PrimarySmtpAddress,GrantSendOnBehalfTo | export-csv -NoTypeInformation "$logpath\MailboxSendOnBehalfAccess-LocalExchange.csv"

$a = Get-Mailbox $a | Get-MailboxPermission | Where { ($_.IsInherited -eq $False) -and -not ($_.User -like “NT AUTHORITY\SELF”) -and -not ($_.User -like '*Discovery Management*') } | Select Identity, user | Export-Csv -NoTypeInformation "$logpath\MailboxFullAccess-LocalExchange.csv"



### The following scripts output mailbox statistics ###

$MailboxStats = get-mailbox | group-object recipienttypedetails | select count, name
$MailboxStats | Out-File "$logpath\MailboxStats.txt" -NoClobber -Append


### The following scripts output mailbox details including datbase ###
Get-Mailbox | Select DisplayName,Alias,PrimarySMTPAddress,Database | export-csv -NoTypeInformation "$logpath\MailboxDetails.csv"


### The following scripts output any forwarders configured on mailboxes ###
Get-Mailbox -ResultSize Unlimited | Where {($_.ForwardingAddress -ne $Null) -or ($_.ForwardingsmtpAddress -ne $Null)} | Select Name, DisplayName, PrimarySMTPAddress, UserPrincipalName, ForwardingAddress, ForwardingSmtpAddress, DeliverToMailboxAndForward | export-csv -NoTypeInformation "$logpath\MailboxesWithForwarding.csv"

