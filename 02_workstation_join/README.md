# 02 join the workstation to the domian

1. clone machine from the base windows 11
2. change default DNS server IP address
```
Get-DnsClientServerAddress
Set-DnsClientServerAddress -InterfaceIndex 3 -ServerAddresses 192.168.60.155
```

3. select Access work or school -> Connect -> Join this device to the local Active Directory domain 
Alternatively, use powershell script

```
Add-Computer -DomainName xyz.com -Credential xyz\Administrator -Force -Restart
```
 4. take a snapshot
 
