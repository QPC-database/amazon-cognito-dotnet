﻿# Script parameters
Param(
    [string]
    $PublicKeyTokenToCheck
)

# Functions

Function Get-PublicKeyToken
{
    [CmdletBinding()]
    Param(
        # The assembly in question
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string]
        $AssemblyPath
    )
    $token = $null
    $token = [System.Reflection.Assembly]::LoadFrom($AssemblyPath).GetName().GetPublicKeyToken()
    if ( $token )
    {
        $key = ""
        foreach($b in $token)
        {
            $key += "{0:x2}" -f $b
        }
        return $key
    }
    else
    {
        Write-Error "NO TOKEN!!"
    }
}

Function Copy-SDKAssemblies
{
    [CmdletBinding()]
    Param
    (
        # The root folder containing the core runtime or a service
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string]
        $SourceRoot,

        # The location to copy the built dll and pdb to
        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $Destination,

        # The build type. If not specified defaults to 'release'.
        [Parameter()]
        [string]
        $BuildType = "release",

        # The platforms to copy. Defaults to all if not specified.
        [Parameter()]
        [string[]]
        $Platforms = @("net45","pcl"),
        
        # The public key token that all assemblies should have. Optional.
        [Parameter()]
        [string]
        $PublicKeyToken = ""
    )

    Process
    {
        Write-Verbose "Copying built SDK assemblies beneath $SourceRoot to $Destination"

        if (!(Test-Path $Destination))
        {
            New-Item $Destination -ItemType Directory
        }

        $dir = Get-Item $SourceRoot
        $servicename = $dir.Name

        foreach ($p in $Platforms)
        {
            $platformDestination = Join-Path $Destination $p
            if (!(Test-Path $platformDestination))
            {
                New-Item $platformDestination -ItemType Directory
            }
                        
            $filter = "bin\$BuildType\$p\AWSSDK.SyncManager.*"
            $files = gci -Path $dir.FullName -Filter $filter -ErrorAction Stop

            foreach ($a in $files)
            {
                $assemblyName = $a.Name
                $assemblyExtension = [System.IO.Path]::GetExtension($assemblyName).ToLower()
                if ($assemblyExtension -eq ".dll")
                {
                    $aToken = Get-PublicKeyToken -AssemblyPath $a.FullName
                    Write-Debug "File $assemblyName has token = $aToken"
                    if ($PublicKeyToken -ne $aToken)
                    {
                        $message = "File = {0}, Token = {1}, does not match Expected Token = {2}" -f $a.FullName, $aToken, $PublicKeyToken
                        Write-Error $message
                        return
                    }
                }
                Write-Verbose "Copying $assemblyName..."
                Copy-Item $a.FullName $platformDestination
            }
        }
    }
}

#Script code
#$ErrorActionPreference = "Stop"
Copy-SDKAssemblies -SourceRoot ..\sdk\src\ -Destination ..\Deployment\assemblies -PublicKeyToken $PublicKeyTokenToCheck -Platforms @("net45","pcl","Xamarin.iOS10")

#Write-Verbose "Copying assembly versions manifest..."
#Copy-Item ..\generator\ServiceModels\_sdk-versions.json ..\Deployment\assemblies\_sdk-versions.json
