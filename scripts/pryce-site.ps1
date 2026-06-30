param(
    [Parameter(Position = 0)]
    [ValidateSet('check','preview')]
    [string]$Command = 'check'
)

$ErrorActionPreference = 'Stop'
$RepoPath = 'C:\Users\pmandel.ATTAIN\GitHub\63smorrell'
$GitExe = 'C:\Program Files\Git\cmd\git.exe'
$IndexPath = Join-Path $RepoPath 'public\index.html'
$PreviewRoot = Join-Path $RepoPath 'public'

Set-Location -Path $RepoPath

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    & $GitExe @Args
}

function Require-File([string]$Path, [string]$Label) {
    if (-not (Test-Path -Path $Path -PathType Leaf)) { throw "$Label not found: $Path" }
}

function Require-Folder([string]$Path, [string]$Label) {
    if (-not (Test-Path -Path $Path -PathType Container)) { throw "$Label not found: $Path" }
}

function Start-PreviewServer {
    Write-Host 'http://localhost:8080/'
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add('http://localhost:8080/')
    $listener.Start()
    try {
        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $requestPath = [System.Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
            if ([string]::IsNullOrWhiteSpace($requestPath)) { $requestPath = 'index.html' }
            $filePath = Join-Path $PreviewRoot $requestPath
            if ((Test-Path $filePath) -and -not (Get-Item $filePath).PSIsContainer) {
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $ext = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
                $mime = switch ($ext) {
                    '.html' { 'text/html; charset=utf-8' }
                    '.css' { 'text/css; charset=utf-8' }
                    '.js' { 'application/javascript; charset=utf-8' }
                    '.jpg' { 'image/jpeg' }
                    '.jpeg' { 'image/jpeg' }
                    '.png' { 'image/png' }
                    '.json' { 'application/json; charset=utf-8' }
                    default { 'application/octet-stream' }
                }
                $context.Response.StatusCode = 200
                $context.Response.ContentType = $mime
                $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $msg = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
                $context.Response.StatusCode = 404
                $context.Response.OutputStream.Write($msg, 0, $msg.Length)
            }
            $context.Response.Close()
        }
    } finally {
        $listener.Stop()
        $listener.Close()
    }
}

function Run-Check {
    Write-Host 'Running check...'
    Require-Folder (Join-Path $RepoPath '.git') '.git'
    Require-File (Join-Path $RepoPath 'wrangler.jsonc') 'wrangler.jsonc'
    Require-File $IndexPath 'public/index.html'
    Require-File (Join-Path $RepoPath 'src\worker.js') 'src/worker.js'
    Require-Folder (Join-Path $RepoPath 'public\assets') 'public/assets'

    $branch = (Invoke-Git branch --show-current).Trim()
    $commit = (Invoke-Git rev-parse --short HEAD).Trim()
    Write-Host "Branch: $branch"
    Write-Host "Commit: $commit"
    Write-Host 'Git status:'
    Invoke-Git status --short

    $content = Get-Content -Path $IndexPath -Raw
    if (($content -notmatch 'formsubmit') -and ($content -notmatch 'formsubmit\.co')) { throw 'Missing FormSubmit marker.' }
    if ($content -notmatch 'prycemandel%40gmail\.com|prycemandel@gmail\.com') { throw 'Missing contact recipient marker.' }
    if ($content -notmatch 'assets/photo-0[1-6]\.jpg') { throw 'Missing expected image references.' }

    $trackedImages = @(Invoke-Git ls-files -- 'public/assets' | Where-Object { $_ -match '\.(jpg|jpeg|png|webp)$' })
    if ($trackedImages.Count -lt 1) { throw 'No tracked images found in public/assets.' }
    Write-Host "Tracked property images: $($trackedImages.Count)"
    Write-Host 'Check complete.'
}

switch ($Command) {
    'check' { Run-Check }
    'preview' { Run-Check; Start-PreviewServer }
}
