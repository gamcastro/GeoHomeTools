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