
$Config = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName config.psd1
$FileName = $Config.FileName + ".json"
$DataPath = Join-Path -Path $Config.DataLocation -ChildPath $FileName

function ReturnZeroIfNegitive ($Data) {
    if ($data -lt 0) {
        return 0
    } else {
        return $data
    }

}

$SNMP = new-object -ComObject olePrn.OleSNMP

# You can put a | Where-Object type filter here to restrict which printers get displayed in the dashboard
$All_Printers = get-printer -ComputerName $Config.PrintServer

# Use an arrayList instead of an array. You can use .Add() and .Remove() methods on it.
# Standard arrays rebuild the ENTIRE array each time you add, performance nightmare when dealing with many objects
 $Printers = New-Object System.Collections.ArrayList

foreach ($Printer in $All_Printers) {
    $Address = $Printer.PortName
    $Name = $Printer.Name
    if (!(Test-Connection $address -Quiet -Count 1)) {$onlineState = $False}

    if (Test-Connection $address -Quiet -Count 1) {
        $onlineState = $True

        $SNMP.Open($Address, "public", 2, 3000)

        $printertype = $snmp.Get(".1.3.6.1.2.1.25.3.2.1.3.1")

        $black_tonervolume = $snmp.get("43.11.1.1.8.1.1")
        $black_currentvolume = $snmp.get("43.11.1.1.9.1.1")
        [int]$black_percentremaining = ($black_currentvolume / $black_tonervolume) * 100

        $cyan_tonervolume = $snmp.get("43.11.1.1.8.1.2")
        $cyan_currentvolume = $snmp.get("43.11.1.1.9.1.2")
        [int]$cyan_percentremaining = ($cyan_currentvolume / $cyan_tonervolume) * 100

        $magenta_tonervolume = $snmp.get("43.11.1.1.8.1.3")
        $magenta_currentvolume = $snmp.get("43.11.1.1.9.1.3")
        [int]$magenta_percentremaining = ($magenta_currentvolume / $magenta_tonervolume) * 100

        $yellow_tonervolume = $snmp.get("43.11.1.1.8.1.4")
        $yellow_currentvolume = $snmp.get("43.11.1.1.9.1.4")
        [int]$yellow_percentremaining = ($yellow_currentvolume / $yellow_tonervolume) * 100
    }


    $PrinterData = [PSCustomObject] @{
        "Name"        = $Name
        "Type"        = $printertype
        "Address"     = $Address
        "OnlineState" = $onlineState
        "Toner"       = @{
            "Name"    = "Toner Levels"
            "Max"     = 100
            "Min"     = 0
            "Black"   = ReturnZeroIfNegitive -Data $black_percentremaining
            "Yellow"  = ReturnZeroIfNegitive -Data $Yellow_percentremaining
            "Cyan"    = ReturnZeroIfNegitive -Data $Cyan_percentremaining
            "Magenta" = ReturnZeroIfNegitive -Data $Magenta_percentremaining

        }
    }

    $Printers.Add($PrinterData)

    $SNMP.Close()
}

ConvertTo-Json -InputObject $Printers -Depth 4 | Out-File -FilePath $DataPath

