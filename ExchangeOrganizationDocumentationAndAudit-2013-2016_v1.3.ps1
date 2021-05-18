######################################################################################################################
###                                                                                                                ###
###  	Script by Terry Munro -                                                                                    ###
###     Technical Blog -               http://365admin.com.au                                                      ###
###     Webpage -                      https://www.linkedin.com/in/terry-munro/                                    ###
###     TechNet Gallery Scripts -      http://tinyurl.com/TerryMunroTechNet                                        ###
###     Version -                      Version 1.1                                                                 ###
###     Version History                Version 1.0 - 26/11/2017                                                    ###
###                                    Version 1.1 - 02/12/2017                                                    ###
###                                    Version 1.2 - 17/03/2018                                                    ###
###     Support                        http://www.365admin.com.au/2017/11/how-to-document-local-exchange.html      ###
###                                                                                                                ###
###     Download Link                  https://gallery.technet.microsoft.com/Exchange-Org-documentation-9b8ca5ef   ###
###                                                                                                                ###
###     Version Changes                Version 1.1 - Remove DNSZone query to simplify the script                   ###
###                                                - Removed AutoDiscover URL as not needed                        ###
###                                                - Updated output file name for Get-ClientAccessServer           ###
###                                                - Removed prefix numbers in reports                             ###
###                                                - Updated with -ResultSize Unlimited                            ###
###                                                                                                                ###
###                                    Version 1.2 - Updated to run Get-Mailbox once                               ###
###                                    Version 1.3 - Added PowerShell variable - to prevent truncation of results  ###
###                                                                                                                ###
######################################################################################################################

##############################################################################################################################
###                                                                                                                        ###
###  	Script Notes                                                                                                       ###
###     Script has been created to document the current local Exchange environment                                         ###
###     Script has been tested on Exchange 2013 and Exchange 2016                                                          ###
###                                                                                                                        ###
###     *** Important - Run this script in Exchange Management Shell                                                       ###
###                                                                                                                        ###
###     Update the variable - $logpath - to set the location you want the reports to be generated                          ###
###                                                                                                                        ###
##############################################################################################################################


### Update the log path variables below before running the script ####

$logpath = "c:\reports"


########################################################

### Do not change the variables below


$Mailboxes = get-mailbox -ResultSize Unlimited

$FormatEnumerationLimit=-1

########################################################

Import-Module ActiveDirectory

$Mailboxes | Get-ADPermission | where {($_.ExtendedRights -like "*Send-As*") -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF")} | Select Identity,User,RecipientTypeDetails | Export-Csv -NoTypeInformation "$logpath\MailboxSendAsAccess-LocalExchange.csv"

$Mailboxes | Where-Object {$_.GrantSendOnBehalfTo} | select Name,@{Name='GrantSendOnBehalfTo';Expression={($_ | Select -ExpandProperty GrantSendOnBehalfTo | Select -ExpandProperty Name) -join ","}} | export-csv -notypeinformation "$logpath\MailboxSendOnBehalf-LocalExchange.csv"

$Mailboxes | Get-MailboxPermission | Where { ($_.IsInherited -eq $False) -and -not ($_.User -like “NT AUTHORITY\SELF”) -and -not ($_.User -like '*Discovery Management*') } | Select Identity, user,RecipientTypeDetails | Export-Csv -NoTypeInformation "$logpath\MailboxFullAccess-LocalExchange.csv"

########################################################

Get-ExchangeCertificate | Where {($_.IsSelfSigned -eq $False)} | Select CertificateDomains, Issuer, NotAfter, RootCAType, Services, Status, Subject | Out-File "$logpath\ExchangeCertificate-LocalExchange.txt" -NoClobber -Append

Get-OwaVirtualDirectory | Select Name,Server,InternalURL,ExternalURL  | FL | Out-File "$logpath\OWA-VirtualDirectory-LocalExchange.txt"

Get-PowerShellVirtualDirectory | Select Name,Server,InternalURL,ExternalURL | FL | Out-File "$logpath\PowerShellVirtualDirectory-LocalExchange.txt"

Get-ActiveSyncVirtualDirectory | Select Name,Server,InternalURL,ExternalURL | FL | Out-File "$logpath\ActiveSyncVirtualDirectory-LocalExchange.txt"

Get-ClientAccessServer | Select  Name,AutoDiscoverServiceCN,AutoDiscoverServiceInternalUri,OutlookAnywhereEnabled | FL | Out-File "$logpath\AutoDiscoverSCPandOutlookAnywhere-LocalExchange.txt"

Get-OabVirtualDirectory | Select Name,Server,InternalURL,ExternalURL | FL | Out-File "$logpath\OABVirtualDirectory-LocalExchange.txt"

Get-WebServicesVirtualDirectory | Select Name,Server,InternalURL,ExternalURL | FL | Out-File "$logpath\WebServicesVirtualDirectory-LocalExchange.txt"

Get-AcceptedDomain | Select Name,DomainName,DomainType,Default | Out-File "$logpath\AcceptedDomains-LocalExchange.txt"

Get-EmailAddressPolicy | Select Name,Priority,RecipientFilter,RecipientFilterApplied,IncludeRecipients,EnabledPrimarySMTPAddressTemplate,EnabledEmailAddressTemplates,Enabled,IsValid | Out-File "$logpath\EmailAddressPolicy-LocalExchange.txt"

Get-ReceiveConnector | Select Name,Enabled,ProtocolLoggingLevel,FQDN,MaxMessageSize,Bindings,RemoteIPRanges,AuthMechanism,PermissionGroups | Out-File "$logpath\ReceiveConnectors-LocalExchange.txt"

Get-SendConnector | Select Name,Enabled,ProtocolLoggingLevel,SmartHostsString,FQDN,MaxMessageSize,AddressSpaces,SourceTransportServers |  Out-File "$logpath\SendConnectors-LocalExchange.txt"

Get-TransportService | Select Name,InternalDNSServers,ExternalDNSServers,OutboundConnectionFailureRetryInterval,TransientFailureRetryInterval,TransientFailureRetryCount,MessageExpirationTimeout,DelayNotificationTimeout,MaxOutboundConnections,MaxPerDomainOutboundConnections,MessageTrackingLogEnabled,MessageTrackingLogPath,ConnectivityLogEnabled,ConnectivityLogPath,SendProtocolLogPath,ReceiveProtocolLogPath | Out-File "$logpath\TransportConfiguration-LocalExchange.txt"

Get-Mailboxdatabase | Select Servers,Name,EDBFilePath,LogFolderPath,MaintenanceSchedule,JournalRecipient,CircularLoggingEnabled,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota,DeletedItemRetention,MailboxRetention,RetainDeletedItemsUntilBackup,OfflineAddressBook,LastFullBackup,LastIncrementalBackup,LastDifferentialBackup,DatabaseSize | Out-File "$logpath\MailboxDatabaseConfigs-LocalExchange.txt"

Get-ExchangeServer | Select Name,Server,Domain,FQDN,ServerRole,IsMemberOfCluster,AdminDisplayVersion | Out-File "$logpath\ExchangeServer-LocalExchange.txt"

Get-OwaMailboxPolicy | Select Name,ActiveSyncIntegrationEnabled,AllAddressListsEnabled,CalendarEnabled,ContactsEnabled,JournalEnabled,JunkEmailEnabled,RemindersAndNotificationsEnabled,NotesEnabled,PremiumClientEnabled,SearchFoldersEnabled,SignaturesEnabled,SpellCheckerEnabled,TasksEnabled,ThemeSelectionEnabled,UMIntegrationEnabled,ChangePasswordEnabled,RulesEnabled,PublicFoldersEnabled,SMimeEnabled,RecoverDeletedItemsEnabled,InstantMessagingEnabled,TextMessagingEnabled,DirectFileAccessOnPublicComputersEnabled,WebReadyDocumentViewingOnPublicComputersEnabled,DirectFileAccessOnPrivateComputersEnabled,WebReadyDocumentViewingOnPrivateComputersEnabled | Out-File "$logpath\OWAMailboxPolicies-LocalExchange.txt"

Get-MobileDeviceMailboxPolicy | Select Name,AllowNonProvisionableDevices,DevicePolicyRefreshInterval,PasswordEnabled,MaxCalendarAgeFilter,MaxEmailAgeFilter,MaxAttachmentSize,RequireManualSyncWhenRoaming,AllowHTMLEmail,AttachmentsEnabled,AllowStorageCard,AllowCameraTrue,AllowWiFi,AllowIrDA,AllowInternetSharing,AllowRemoteDesktop,AllowDesktopSync,AllowBluetooth,AllowBrowser,AllowConsumerEmail,AllowUnsignedApplications,AllowUnsignedInstallationPackages | Out-File "$logpath\MobileDevicePolicies-LocalExchange.txt"

Get-TransportRule | Select Name,Priority,Description,Comments,State | Out-File "$logpath\TransportRules-LocalExchange.txt"

Get-RoleGroupMember "Organization Management" | Out-File "$logpath\ExchangeAdmins-LocalExchange.txt"



### The following scripts output mailbox statistics ###

$MailboxStats = $Mailboxes | group-object recipienttypedetails | select count, name
$MailboxStats | Out-File "$logpath\MailboxStats-LocalExchange.txt"


### The following scripts output mailbox details including database ###
$Mailboxes | Select DisplayName,Alias,PrimarySMTPAddress,Database | export-csv -NoTypeInformation "$logpath\MailboxDetails-LocalExchange.csv"


### The following scripts output any forwarders configured on mailboxes ###
$Mailboxes | Where {($_.ForwardingAddress -ne $Null) -or ($_.ForwardingsmtpAddress -ne $Null)} | Select Name, DisplayName, PrimarySMTPAddress, UserPrincipalName, ForwardingAddress, ForwardingSmtpAddress, DeliverToMailboxAndForward | export-csv -NoTypeInformation "$logpath\MailboxesWithForwarding-LocalExchange.csv"

