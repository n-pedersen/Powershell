

$script:ErrorActionPreference = 'Ignore'
$script:ProgressPreference = 'SilentlyContinue'

function set-wallPaper ([string]$desktopImagePath)
{   
    Remove-ItemProperty -path "HKCU:\Control Panel\Desktop" -name WallPaper,WallpaperStyle
    
               
    Set-ItemProperty -path "HKCU:\Control Panel\Desktop" -name WallPaper -value $desktopImagePath
    Set-ItemProperty -path "HKCU:\Control Panel\Desktop" -name WallpaperStyle -value "6"
     

    Sleep -seconds 5

     RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True

#Not needed but lets you know it was set correctly  
#         Get-ItemProperty -path "HKCU:\Control Panel\Desktop" 
} # function set-wallPaper


try
{


    $subreddit = "DavidHasselhoff"
    $Pictures = Invoke-RestMethod "https://www.reddit.com/r/$subreddit/hot/.json" -Method Get -Body @{limit="100"} | %{$_.data.children.data.url} | ?{ $_ -match "\.jp?g$" }
    #$Pictures.Count
    
    $destinationFolderPath = "$env:TEMP\$subreddit-Pictures"
    mkdir $destinationFolderPath -ErrorAction SilentlyContinue | Out-Null

    [int]$i = 0
    foreach($imageURL in $Pictures)
    {
        $i++

	    $imageFileName = ($imageURL.split("/"))[-1]
	    echo ([string]"$i Downloading image $imageFileName" + "      $imageURL" ) | Out-null

	    Invoke-WebRequest -Uri $imageURL -OutFile "$destinationFolderPath\$imageFileName" | Out-null
    }

    [array]$PictureArray = Get-ChildItem -Path $destinationFolderPath | Select-Object -ExpandProperty FullName
    [int]$RandomPictureNo = (Get-Random -Minimum 0 -Maximum ($PictureArray.Count) )
    $RandomPicturePath = $PictureArray[$RandomPictureNo]

    Set-Wallpaper -desktopImagePath $RandomPicturePath


    #cursor
    $destinationFolderPath 
    $RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]”CurrentUser”,”$env:COMPUTERNAME”)

    $cursorFileName = "thehoff.cur"
    $cursorPath = "$destinationFolderPath\$cursorFileName"
    Invoke-WebRequest -Uri "http://cur.cursors-4u.net/toons/too-6/too529.cur" -OutFile $cursorPath


    $RegCursors = $RegConnect.OpenSubKey(“Control Panel\Cursors”,$true)

    $RegCursors.SetValue(“Arrow”,$cursorPath)

    $RegCursors.SetValue(“Crosshair”,$cursorPath)

    $RegCursors.SetValue(“Hand”,$cursorPath)

    $RegCursors.Close()

    $RegConnect.Close()


}
finally 
{
    Clear-History
    Get-Process -PID $pid | Stop-Process
}
