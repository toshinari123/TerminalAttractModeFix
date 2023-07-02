param(
    # The `Name` of the MicrosoftTerminal Profile.
    [Parameter(Mandatory = $true, Position = 0)]
    [string]
    [Alias('Profile')]
    $Name,

    # The `Path` of the your awesome gifs that are clearly not copyrighted an totally appropriate to use in an OSS project.
    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    [Alias('GifFolderPath')]
    $Path,

    [Parameter(Mandatory = $false, Position = 2)]
    [int]
    [Alias('SleepSecs')]
    $sleepseconds = 55,

    [Parameter(Mandatory = $false, Position = 3)]
    [int]
    [Alias('ActiveSecs')]
    $activeseconds = 5
)

$ErrorActionPreference = "Stop"
$timerMS = 0;
$gifposition = 0;
$LoopMS = 30;
$settingspath = 'C:\Users\toshi\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

# Variables only needed if we're going to make the Window move

# determine screen dimensions to restrict our window movement
$gifs = Get-ChildItem $Path #-Filter "*.gif"


function Set-Image {
    param (
        $imgpath
    )
    $settings = Get-Content -Path $settingspath
    $pattern = '"name": "' + $Name + '"'
    $pos = $settings | Select-String -Pattern $pattern
    $randstr = '                "backgroundImage": "' + $imgpath+ '",'
    $randstr = $randstr.replace('\', '\\')
    $notdoneyet = $true
    $up = $pos.LineNumber - 1
    while ($true) {
        if ((($settings | select -first 1 -skip $up) | Select-String -Pattern '"backgroundImage"').Matches.length -eq 1) {
            Write-Host $settings[$up]
            $settings[$up] = $randstr
            Write-Host $settings[$up]
            $notdoneyet = $false
        }
        if (($settings | select -first 1 -skip $up).length -lt 15) {
            break
        }
        $up--
    }
    $down = $pos.LineNumber - 1
    while ($true) {
        if ((($settings | select -first 1 -skip $down) | Select-String -Pattern '"backgroundImage"').Matches.length -eq 1) {
            $settings[$down] = $randstr
            $notdoneyet = $false
        }
        if (($settings | select -first 1 -skip $down).length -lt 15) {
            break
        }
        $down++
    }
    $settings | Set-Content -Path $settingspath
}

while ($true) {
    Start-Sleep -Seconds $sleepseconds
    $rand = Get-Random -Maximum $gifs.length
    Set-Image $gifs[$rand].FullName
    Start-Sleep -Seconds $activeseconds
    Set-Image "https://wallpapers.com/images/hd/pure-black-background-y8wp2r83b15xxdi6.jpg"
}
