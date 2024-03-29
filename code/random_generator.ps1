param( [Parameter(Mandatory=$true)] $OutputJSONFile)


$group_names = [System.Collections.ArrayList](Get-Content "C:\Users\local_admin\active_directory\code\data\group_names.txt")
$first_names = [System.Collections.ArrayList](Get-Content "C:\Users\local_admin\active_directory\code\data\firstname_list.txt")
$last_names = [System.Collections.ArrayList](Get-Content "C:\Users\local_admin\active_directory\code\data\lastname_list.txt")
$passwords = [System.Collections.ArrayList](Get-Content "C:\Users\local_admin\active_directory\code\data\passwords.txt")


$groups = @()
$users = @()
$num_groups = 10

# echo (Get-Random -InputObject $group_names)
for ($i = 0; $i -lt $num_groups; $i++) {
    $new_group = (Get-Random -InputObject $group_names)
    $groups += @{ "name"="$new_group"}
    $group_names.Remove($new_group)

}

$num_users = 100
for ($i = 0; $i -lt $num_users; $i++) {
    $first_name = (Get-Random -InputObject $first_names)
    $last_name = (Get-Random -InputObject $last_names)
    $password = (Get-Random -InputObject $passwords)
    $new_user = @{
        "name"="$first_name $last_name"
        "password"="$password"
        "groups"= @((Get-Random -InputObject $groups).name)
    }
    # $groups += $new_group
    $users += $new_user
    $first_names.Remove($first_name)
    $last_names.Remove($last_name)
    $passwords.Remove($password)

}

@{
    "domain"="xyz.com"
    "groups"=$groups
    "users"=$users
} | ConvertTo-Json | Out-File $OutputJSONFile