param( [Parameter(Mandatory=$true)] $JSONFile)


function CreateADGroup() {
    param( [Parameter(Mandatory=$true)] $groupObject)

    $name = $groupObject.name
    New-ADGroup -name $name -GroupScope Global
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


$json = (Get-Content $JSONFile | ConvertFrom-Json)

$Global:Domain = $json.domain

foreach ($group in $json.groups) {
    CreateADGroup $group
}


foreach ($user in $json.users) {
    CreateADUser $user
}