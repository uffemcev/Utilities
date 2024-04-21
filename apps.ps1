@(
  	[pscustomobject]@{
		Description = "Adguard DOH"
		Name = "adns"
		Tag = "tweaks"
		Code = {
			$ips = '94.140.14.14', '94.140.15.15', '2a10:50c0::ad1:ff', '2a10:50c0::ad2:ff'
			$doh = "https://dns.adguard-dns.com/dns-query/"
			foreach ($ip in $ips) {
    				Add-DnsClientDohServerAddress -errorAction 0 -ServerAddress $ip -DohTemplate $doh
    				Get-NetAdapter -Physical | ForEach-Object {
        				Set-DnsClientServerAddress $_.InterfaceAlias -ServerAddresses $ips
        				if ($ip -match '\.') {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh\$ip"}
        				if ($ip -match ':') {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh6\$ip"}
        				New-Item -Path $path -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
    				}
			}
			New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'EnableAutoDoh' -Value 2 -PropertyType DWord -Force
			Clear-DnsClientCache
		}
	}		
  	[pscustomobject]@{
		Description = "Cloudflare DOH"
		Name = "cdns"
		Tag = "tweaks"
		Code = {
			$ips = '1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001'
			$doh = "https://cloudflare-dns.com/dns-query/"
			foreach ($ip in $ips) {
    				Add-DnsClientDohServerAddress -errorAction 0 -ServerAddress $ip -DohTemplate $doh
    				Get-NetAdapter -Physical | ForEach-Object {
        				Set-DnsClientServerAddress $_.InterfaceAlias -ServerAddresses $ips
        				if ($ip -match '\.') {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh\$ip"}
        				if ($ip -match ':') {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh6\$ip"}
        				New-Item -Path $path -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
    				}
			}
			New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'EnableAutoDoh' -Value 2 -PropertyType DWord -Force
			Clear-DnsClientCache
		}
	}	
 	[pscustomobject]@{
		Description = "Yandex DOH"
		Name = "ydns"
		Tag = "tweaks"
		Code = {
			$ips = '77.88.8.88', '77.88.8.2', '2a02:6b8::feed:bad', '2a02:6b8:0:1::feed:bad'
			$doh = "https://safe.dot.dns.yandex.net/"
			foreach ($ip in $ips) {
    				Add-DnsClientDohServerAddress -errorAction 0 -ServerAddress $ip -DohTemplate $doh
    				Get-NetAdapter -Physical | ForEach-Object {
        				Set-DnsClientServerAddress $_.InterfaceAlias -ServerAddresses $ips
        				if ($ip -match '\.') {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh\$ip"}
        				if ($ip -match ':') {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh6\$ip"}
        				New-Item -Path $path -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
    				}
			}
			New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'EnableAutoDoh' -Value 2 -PropertyType DWord -Force
			Clear-DnsClientCache
		}
	}
	[pscustomobject]@{
		Description = "Office, Word, Excel licensed"
		Name = "office"
		Tag = "system"
		Code = {
			iwr 'https://github.com/farag2/Office/releases/latest/download/Office.zip' -Useb -OutFile '.\Office.zip'
			Expand-Archive -ErrorAction 0 -Force '.\Office.zip' '.\'
			pushd '.\Office'
			(gc '.\Default.xml').replace('Display Level="Full"', 'Display Level="None"') | sc '.\Default.xml'
			iex '.\Download.ps1 -Branch O365ProPlusRetail -Channel Current -Components Word, Excel, PowerPoint'
			iex '.\Install.ps1'
			& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /KMS-Office /KMS-ActAndRenewalTask /S
			popd
		}
	}
	[pscustomobject]@{
		Description = "SpotX - modified Spotify app"
		Name = "spotx"
		Tag = "audio"
		Code = {
			[Net.ServicePointManager]::SecurityProtocol = 3072
      			iex "& { $(iwr -useb 'https://spotx-official.github.io/run.ps1') } -premium -new_theme -podcasts_on -block_update_on -EnhanceSongs -sp-uninstall"
		}
	}
	[pscustomobject]@{
		Description = "GoodbyeDPI mode 5"
		Name = "dpi"
		Tag = "tweaks"
		Code = {
			$uri = "https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "goodbyedpi.*.zip$" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile '.\goodbyedpi.zip'
			Expand-Archive -ErrorAction 0 -Force '.\goodbyedpi.zip' $Env:Programfiles
   			$dir =  (dir -Path $Env:Programfiles -ErrorAction 0 -Force | where {$_ -match 'goodbyedpi*'}).FullName
			try {iwr "https://antizapret.prostovpn.org:8443/domains-export.txt" -Useb | sc "$dir\russia-blacklist.txt"}
   			catch {(iwr "https://reestr.rublacklist.net/api/v3/domains" -Useb) -split '", "' -replace ('[\[\]"]'), ('') | sc "$dir\russia-blacklist.txt"}
   			"`n" |& "$dir\service_install_russia_blacklist.cmd"
		}
	}
	[pscustomobject]@{
		Description = "Google Chrome"
		Name = "chrome"
		Tag = "web"
		Code = {
			$id = "Google.Chrome"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Vencord - modified Discord app"
		Name = "vencord"
		Tag = "audio"
		Code = {
			$id = "Vendicated.Vencord"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Steam"
		Name = "steam"
		Tag = "games"
		Code = {
			$id = "Valve.Steam"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "qBittorrent"
		Name = "qbit"
		Tag = "storage"
		Code = {
			$id = "qBittorrent.qBittorrent"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "7-Zip"
		Name = "zip"
		Tag = "system"
		Code = {
			$id = "7zip.7zip"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Google Drive"
		Name = "gdrive"
		Tag = "storage"
		Code = {
			$id = "Google.GoogleDrive"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Adguard"
		Name = "adguard"
		Tag = "web"
		Code = {
			$id = "AdGuard.AdGuard"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "SignalRGB"
		Name = "signal"
		Tag = "games"
		Code = {
			$id = "WhirlwindFX.SignalRgb"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "K-Lite Codec Pack Full"
		Name = "codec"
		Tag = "video"
		Code = {
			$id = "CodecGuide.K-LiteCodecPack.Full"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "NVCleanstall"
		Name = "nvidia"
		Tag = "system"
		Code = {
			$id = "TechPowerUp.NVCleanstall"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Rufus portable"
		Name = "rufus"
		Tag = "other"
		Code = {
			$uri = "https://api.github.com/repos/pbatard/rufus/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "rufus.*.exe$" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile ([Environment]::GetFolderPath("Desktop") + ".\rufus.exe")
		}
	}
	[pscustomobject]@{
		Description = "SophiApp Tweaker portable"
		Name = "sophia"
		Tag = "tweaks"
		Code = {
			$uri = "https://api.github.com/repos/Sophia-Community/SophiApp/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "SophiApp.zip" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile ".\SophiApp.zip"
			Expand-Archive -ErrorAction 0 -Force ".\SophiApp.zip" ([Environment]::GetFolderPath("Desktop"))
		}
	}
	[pscustomobject]@{
		Description = "Win 11 23H2 iso folder"
		Name = "win"
		Tag = "other"
		Code = {
			$apps = "WindowsStore", "Purchase", "VCLibs", "Photos", "Notepad", "Terminal", "Installer"
			$options = "AutoStart", "AddUpdates", "Cleanup", "ResetBase", "SkipISO", "SkipWinRE", "CustomList", "AutoExit"
			$id = ((irm "https://api.uupdump.net/fetchupd.php?arch=amd64&ring=retail&build=22631.1").response.updateArray | Sort -Descending -Property $_.foundBuild | Select -First 1).updateId
			while (!(dir -errorAction 0 "UUP.zip")) {start-sleep 5; iwr -Useb -Uri "https://uupdump.net/get.php?id=$id&pack=ru-ru&edition=core" -Method "POST" -Body "autodl=2" -OutFile '.\UUP.zip'}
			Expand-Archive -ErrorAction 0 -Force '.\UUP.zip' '.\'
			(gc ".\ConvertConfig.ini") -replace (' '), ('') | sc ".\ConvertConfig.ini"
			foreach ($option in $options) {
				((gc '.\ConvertConfig.ini') -replace ("^" + $option + "=0"), ($option + "=1")) | sc '.\ConvertConfig.ini'
			}
			start-job -Name ("UUP") -Init ([ScriptBlock]::Create("cd '$pwd'")) -ScriptBlock {iex ".\uup_download_windows.cmd"}			
			while (!(dir -errorAction 0 "CustomAppsList.txt")) {start-sleep 1}
			(gc ".\CustomAppsList.txt") -replace ('^\w'), ('# $&') | sc ".\CustomAppsList.txt"
			foreach ($app in $apps) {
				$file = (gc ".\CustomAppsList.txt") -split "# " | Select-String -Pattern $app
				((gc '.\CustomAppsList.txt') -replace ("# " + $file), ($file)) | sc '.\CustomAppsList.txt'
			}
			get-job -errorAction 0 -name UUP | wait-job
			dir -ErrorAction 0 -Force | where {$_ -match '^*.X64.*$'} | mi -Destination ([Environment]::GetFolderPath("Desktop"))
		}
	}
	[pscustomobject]@{
		Description = "MSEdgeRedirect"
		Name = "redirect"
		Tag = "tweaks"
		Code = {
			$id = "rcmaehl.MSEdgeRedirect"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
)
