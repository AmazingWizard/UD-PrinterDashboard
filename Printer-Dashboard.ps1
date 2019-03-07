Import-Module UniversalDashboard.Community

$Config = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName config.psd1
$FileName = $Config.FileName + ".json"
$DataPath = Join-Path -Path $Config.DataLocation -ChildPath $FileName

if ($i -eq $null) {$i = 8080}
$i++

$Colors = @{
    BackgroundColor = "#eaeaea"
    FontColor       = "Black"
}

$Printers = Get-Content "$DataPath" | ConvertFrom-Json

$Dashboard = New-UDDashboard -Title $Config.DashboardName -NavBarColor '#011721' -NavBarFontColor "#CCEDFD" -BackgroundColor "White" -FontColor "#011721" -Content {
    New-UDRow {
        New-UDColumn -Size 3 {
            New-UDCounter -AutoRefresh -RefreshInterval 5 -Title "Black Below 10%" -BackgroundColor "#1d1e21" -FontColor "#eaeaea" -Endpoint {
                (((get-content -Path "$DataPath" | ConvertFrom-json).Toner | Where-Object {$_.Black -lt 10}) | Measure-Object).Count
            }
        }
        New-UDColumn -Size 3 {
            New-UDCounter -AutoRefresh -RefreshInterval 5 -Title "Cyan Below 10%" -BackgroundColor "#42d4f4" -FontColor "#080e1c" -Endpoint {
                (($(get-content -Path "$DataPath" | ConvertFrom-json).Toner | Where-Object {$_.Cyan -lt 10}) | Measure-Object).Count
            }
        }
        New-UDColumn -Size 3 {
            New-UDCounter -AutoRefresh -RefreshInterval 5 -Title "Magenta Below 10%" -BackgroundColor "#ce3ef2" -FontColor "#080e1c" -Endpoint {
                (($(get-content -Path "$DataPath" | ConvertFrom-json).Toner | Where-Object {$_.Magenta -lt 10}) | Measure-Object).Count
            }
        }
        New-UDColumn -Size 3 {
            New-UDCounter -AutoRefresh -RefreshInterval 5 -Title "Yellow Below 10%" -BackgroundColor "#f1d03e" -FontColor "#080e1c" -Endpoint {
                (($(get-content -Path "$DataPath" | ConvertFrom-json).Toner | Where-Object {$_.Yellow -lt 10}) | Measure-Object).Count
            }
        }
    }
    New-UDRow {
        New-UDColumn -Size 3 {
            New-UDGrid -Title "Lowest Black Toner" -Headers @("Name", "Percent Left") -Properties @("Name", "Toner.Black") -AutoRefresh -RefreshInterval 5 -BackgroundColor "#1d1e21" -FontColor "#eaeaea" -DefaultSortColumn 1 -Endpoint {
                (get-content -path $datapath |ConvertFrom-Json) | Sort-Object {$_.Toner.Black} | Select-Object -First 5 | Out-UDGridData
            }
        }
        New-UDColumn -Size 3 {
            New-UDGrid -Title "Lowest Cyan Toner" -Headers @("Name", "Percent Left") -Properties @("Name", "Toner.Cyan") -AutoRefresh -RefreshInterval 5 -BackgroundColor "#42d4f4" -FontColor "#080e1c" -DefaultSortColumn 1 -Endpoint {
                (get-content -path $datapath |ConvertFrom-Json) | Sort-Object {$_.Toner.Cyan} | Select-Object -First 5 | Out-UDGridData
            }
        }
        New-UDColumn -Size 3 {
            New-UDGrid -Title "Lowest Magenta Toner" -Headers @("Name", "Percent Left") -Properties @("Name", "Toner.Magenta") -AutoRefresh -RefreshInterval 5 -BackgroundColor "#ce3ef2" -FontColor "#080e1c" -DefaultSortColumn 1 -Endpoint {
                (get-content -path $datapath |ConvertFrom-Json) | Sort-Object {$_.Toner.Magenta} | Select-Object -First 5 | Out-UDGridData
            }
        }
        New-UDColumn -Size 3 {
            New-UDGrid -Title "Lowest Yellow Toner" -Headers @("Name", "Percent Left") -Properties @("Name", "Toner.Yellow") -AutoRefresh -RefreshInterval 5 -BackgroundColor "#f1d03e" -FontColor "#080e1c" -DefaultSortColumn 1 -Endpoint {
                (get-content -path $datapath |ConvertFrom-Json) | Sort-Object {$_.Toner.Yellow} | Select-Object -First 5 | Out-UDGridData
            }
        }
    }

    New-UDRow {
        $MinMaxAxis = New-UDLinearChartAxis -Minimum 0 -Maximum 100
        $Options = New-UDBarChartOptions -yAxes $MinMaxAxis
        foreach ($Printer in $Printers) {
            $Links = @(New-UDLink -Text $($Printer.Address)  -Url "Http://$($Printer.Address)/" -Icon globe -OpenInNewWindow; New-UDLink -Text $($Printer.Type) -Url "#")
            New-UDColumn -Size 3 {
                New-UDChart -Title $Printer.Name @colors -type Bar -AutoRefresh -RefreshInterval 5  -Links $links -Endpoint {
                    $($(Get-Content "$DataPath" | ConvertFrom-Json) | Where-Object {$_.Name -like $Printer.Name}).Toner | Out-UDChartData -LabelProperty "Name" -Dataset @(
                        New-UDBarChartDataset -DataProperty "Black" -Label "Black" -BackgroundColor "#080e1c" -HoverBackgroundColor "#080e1c" -
                        New-UDBarChartDataset -DataProperty "Cyan" -Label "Cyan" -BackgroundColor "#42d4f4" -HoverBackgroundColor "#42d4f4"
                        New-UDBarChartDataset -DataProperty "Magenta" -Label "Magenta" -BackgroundColor "#ce3ef2" -HoverBackgroundColor "#ce3ef2"
                        New-UDBarChartDataset -DataProperty "Yellow" -Label "Yellow" -BackgroundColor "#f1d03e" -HoverBackgroundColor "#f1d03e"
                    )
                } -Options $Options
            }
        }
    }
}

Start-UDDashboard -port $i -Dashboard $Dashboard
