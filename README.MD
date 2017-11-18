# Printer Dashboard

![Screenshot](/img/screenshot.png)

This printer dashboard is built using the [UniversalDashboard](http://www.poshud.com/Home) Module. There are several ways to deploy this script. Check the UD Documentation on deployment options.

There are two parts to this script. The `Get-PrinterData.PS1` script, which uses SNMP to talk to each printer from the print server and get toner data. That data is then output as a JSON file. As well as `Printer-Dashboard.PS1` which takes the data exported and displays it as a dashboard. You will want to configure the `Get-PrinterData.PS1` file to run on a schedule using Task Scheduler or some other scheduling method.

The SNMP endpoints should be standard across most printers. However, your millage may vary. So test it in your environment, and feel free to comment / pull request for the **Verified Working Printers** list to be updated.

**Verified Working Printers**
* HP M553 Color Printers

# Requirements

* **UniversalDashboard Licence** - UniversalDashboard requires a licence in order to run your dashboard. On first run, you will be promted to enter a licence, or an email so a trial licence can be provided to you. More information on the licencing can be found on the [UniversalDashboard Website](https://poshtools.com/buy-powershell-pro-tools/universal-dashboard/)
* Windows 8.1 / Windows Server 2012 R2
* PowerShell v5+

# Config

The `Config.psd1` file stores variables that allow you to easily configure where your data is stored/received from and what print server you are pulling data from. There are four properties in the config file:
* PrintServer
    * DNS name of your print server.
* DataLocation
    * Parent Directory where your JSON file will be stored.
* FileName
    * File name of your JSON file (.json will be appended to this name when `Get-PrinterData.ps1` is run).
* DashboardName
    * The Name to be displayed on your dashboard.
