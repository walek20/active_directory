param( 
    [Parameter(Mandatory=$true)] $JSONFile,
    [switch] $Undo

)


function CreateADGroup() {
    param( [Parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
}

function RemoveADGroup() {
    param( [Parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    Remove-ADGroup -Identity $name -Confirm:$false
}

function RemoveADUser() {
    param( [Parameter(Mandatory=$true)] $userObject)

    $name = $userObject.name
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()

    $samAccountName = $username
    Remove-ADUser -Identity $samAccountName -Confirm:$false
}

function CreateADUser() {
    param( [Parameter(Mandatory=$true)] $userObject)
    
    # Pull out the name from the JSON object
    $name = $userObject.name
    $password = $userObject.password

    # Generate data
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()

    $samAccountName = $username
    $principlaName = $username

    # Actually create the AD user object
    New-ADUser -Name $name -GivenName $firstname -Surname $lastname -SamAccountName $samAccountName -UserPrincipalName $principlaName@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    # add user to the group
    foreach ($group in $userObject.groups) {
        try {
            Get-ADGroup -Identity "$group"
            Add-ADGroupMember -Identity $group -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIndentityNotFoundException] {
            Write-Warning "User $name NOT added to group $grooup, because group does not exist"
        }
           
    }
    # echo $userObject
}

function WeakenPasswordPolicy() {
    secinit.exe /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).Replace("PasswordComplexity = 1", "PasswordComplexity = 0").Replace("MinimumPaswordLength = 7", "MinimumPaswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg
    secinit.exe /configure /db C:\Windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -Force C:\Windows\Tasks\secpol.cfg -Confirm:$false
}

function StrengthenPasswordPolicy() {
    secinit.exe /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).Replace("PasswordComplexity = 0", "PasswordComplexity = 1").Replace("MinimumPaswordLength = 1", "MinimumPaswordLength = 7") | Out-File C:\Windows\Tasks\secpol.cfg
    secinit.exe /configure /db C:\Windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -Force C:\Windows\Tasks\secpol.cfg -Confirm:$false
}



$json = (Get-Content $JSONFile | ConvertFrom-Json)
$Global:Domain = $json.domain

if (-not $Undo) {
    WeakenPasswordPolicy

    foreach ($group in $json.groups) {
        CreateADGroup $group
    }
    
    
    foreach ($user in $json.users) {
        CreateADUser $user
    }
}
else {
    StrengthenPasswordPolicy

    foreach ($user in $json.users) {
        RemoveADUser $user
    }

    foreach ($group in $json.groups) {
        RemoveADGroup $group
    }
    
    
    
}


