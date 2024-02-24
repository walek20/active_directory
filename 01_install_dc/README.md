# 01 Installing the Domain Controller

1. Use `sconfig` to:
    - change the hostname - option 2
    - change the IP address to static - option 8
    - change the DNS server to our own IP address

2. Install the Active Directory WIndows Feature

```
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

3. Install Acitve Directory Forest

```
Import-Module ADDSDeployment
Install-ADDSForest
    - domain name - xyz.com 
    - password
```

4. change DNS server IP address - after installation DNS server IP addres is set on loop addres

```
Get-DnsClientServerAddress
Set-DnsClientServerAddress -InterfaceIndex 5 -ServerAddresses 192.168.60.155
```

5. take a snapshot
