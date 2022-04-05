function Remove-GeoDownloadedVideos{
<#
.SYNOPSIS
Ferramenta para deletar arquivos de vídeos baixados

.DESCRIPTION
Ferramenta para limpar uma dada pasta (ou $home\downloads por padrão) , dos arquivos de vídeo desta pasta

.PARAMETER PATH
O caminho da pasta onde retirar os arquivos de vídeo

.EXAMPLE
Remove-GeoDownloadedVideo
Retira com confirmacao, todos os arquivos de videos da pasta padrão $home\download

#>
    [Cmdletbinding()]
    param(
        [string]$Path="$home\Downloads\*"
    )
    BEGIN{}
    PROCESS{
        Remove-Item -Path $Path -Include *.mp4,*.avi,*.mkv -Confirm -Force
    }
    END{}
}

function Remove-GeoEmptyFolder{
    [Cmdletbinding()]
    param(
        [string]$Path = "\."
    )
    BEGIN {
  
    }
    PROCESS{
        Write-Verbose 'Verificando se o caminho dado é um diretório.'
        $obj = Test-Path $Path -PathType Container
        if ($obj){
            Write-Verbose 'Realizando a contagem de objetos dentro do diretório informado'
            $contador = Get-ChildItem -Path $Path -Recurse | Measure-Object
            $contador = $contador.Count
        }
        if ($contador -eq 0){
            Write-Verbose "Removendo o diretório informado"
            Remove-Item $Path
        }
    }
    END{

    }

}
function Resize-Console {
    <#
        .SYNOPSIS
            Resize the PowerShell console programmatically.
        .DESCRIPTION
            This function lets you resize the PowerShell console window by setting
            custom width and height properties, as well as maximize and restore the
            console window.
        .EXAMPLE
            Resize-Console 200 50
        .EXAMPLE
            Resize-Console -Maximize
        .EXAMPLE
            Resize-Console -Restore
        .EXAMPLE
            if (Get-WindowState -eq 'Normal') {Resize-Console -Maximize}
        .NOTES
            Author: Øyvind Kallstad
            Date: 11.10.2015
            Version: 1.0
        .LINK
            https://communary.wordpress.com/
    #>
    [CmdletBinding(DefaultParameterSetName = 'CustomSize')]
    param (
        # Set the window width.
        [Parameter(ParameterSetName = 'CustomSize', Position = 0)]
        [ValidateRange(1,[int]::MaxValue)]
        [int] $Width = $host.UI.RawUI.WindowSize.Width,

        # Set the window height.
        [Parameter(ParameterSetName = 'CustomSize', Position = 1)]
        [ValidateRange(1,[int]::MaxValue)]
        [int] $Height = $host.UI.RawUI.WindowSize.Height,

        # Maximize the window.
        [Parameter(ParameterSetName = 'Maximize')]
        [switch] $Maximize,

        # Restore the window (if maximized).
        [Parameter(ParameterSetName = 'Restore')]
        [switch] $Restore
    ) $Win32ShowWindowAsync = Add-Type -memberDefinition @'
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
'@ -name 'Win32ShowWindowAsync' -namespace Win32Functions -passThru
    if(($PSCmdlet.ParameterSetName -eq 'Maximize') -or ($PSCmdlet.ParameterSetName -eq 'Restore')) {

        # get main window handle of the current process
        $MainWindowHandle = (Get-Process -id $pid).MainWindowHandle

        if ($Maximize) {
            [Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync($MainWindowHandle, 3) | Out-Null
        }

        if ($Restore) {
            [Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync($MainWindowHandle, 9) | Out-Null
        }
    }

    else {
        if ($host.Name -eq 'ConsoleHost') {
            # buffer size can't be smaller than window size
            if ($Width -gt $host.UI.RawUI.BufferSize.Width) {
                $host.UI.RawUI.BufferSize = New-Object -TypeName System.Management.Automation.Host.Size -ArgumentList ($Width, $host.UI.RawUI.BufferSize.Height)
            }

            # if width is too large, set to max allowed size
            if ($Width -gt $host.UI.RawUI.MaxPhysicalWindowSize.Width) {
                $Width = $host.UI.RawUI.MaxPhysicalWindowSize.Width
            }

            # if height is too large, set to max allowed size
            if ($Height -gt $host.UI.RawUI.MaxPhysicalWindowSize.Height) {
                $Height = $host.UI.RawUI.MaxPhysicalWindowSize.Height
            }

            # set window size
            $host.UI.RawUI.WindowSize = New-Object -TypeName System.Management.Automation.Host.Size -ArgumentList ($Width, $Height)
        }
        
        else {
            Write-Warning 'Setting the console window size is only supported when running in the console host.'
        }
    }
}

function Get-ConsoleSize {
    Write-Output ($host.UI.RawUI.WindowSize)
}

function Get-WindowState {
    if ([Win32Functions.Win32IsZoomed]::IsZoomed(((Get-Process -id $pid).MainWindowHandle))) {
        Write-Output 'Maximized'
    }
    else {
        Write-Output 'Normal'
    }
}

function Set-WindowPosition{
 param(
     [int]$X,
     [int]$Y,
     [int]$Width,
     [int]$Height

 )
    Add-Type -Name Window -Namespace Console -MemberDefinition @'
[DllImport("Kernel32.dll")] 
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int W, int H); 
'@
$consoleHWND = [Console.Window]::GetConsoleWindow()
Start-Sleep -Seconds 1
[Console.Window]::MoveWindow($consoleHWND,$X,$Y,$Width,$Height)
}

function Start-GeoChrome{
    [CmdletBinding()]
    param(
        [string]$Url
    )
    BEGIN {
        $chromePath = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
    }
    PROCESS{
        if (-Not $PSBoundParameters.ContainsKey('URL')){
            Start-Process -FilePath $chromePath
        } else {
            Start-Process -FilePath $chromePath $Url
        }
    }
    END {

    }
}

function New-GeoAlarme{
    [CmdletBinding()]
    param(
        [int]$Minutes
    )
    BEGIN{
        $alarme = $false
        $agora = Get-Date
    }
    PROCESS{
        while(-not ($alarme)){
            if ($agora.AddMinutes($Minutes) -lt (Get-Date)){
                $alarme = $true
                [console]::Beep(2000,1000)
            }
            Write-Progress -Activity "Alarme" -Status "Indo"
            Start-Sleep -Seconds 5
        }
    }
    END {}
}

function Get-GEOFilesOrdered{
    [CmdletBinding()]
    param(
        [string]$Path = "\.",
        [int]$Last = 10,
        [string]$FileType = 'pdf'

    )
    BEGIN{
       
    }
    PROCESS{
        $params = @{'Path' = $Path
        'Attributes' = 'Archive'
        'Filter' = "*.$FileType"           
    }
        $result = Get-ChildItem @params|
        Sort-Object -Property LastWriteTime -Descending |
        Select-Object -First $Last |
        Select-Object Name,LastWriteTime
            

        foreach ($arquivo in $result){
            $props = @{'Nome' = $arquivo.Name
                    'DataHoraCriação' = $arquivo.LastWriteTime
            }
            $obj = New-Object -TypeName psobject -Property $props
            Write-Output $obj
        }        
       
    }
    END{}
}

