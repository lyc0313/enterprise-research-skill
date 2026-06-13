<#
.SYNOPSIS
  企业调研 Skill v2.0 — 一键安装脚本 (Windows PowerShell)
.DESCRIPTION
  自动检测依赖、安装 AnySearch + Scrapling、配置技能环境
#>

$ErrorActionPreference = "Stop"
$SkillDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $SkillDir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  企业调研 Skill v2.0 一键安装" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---- Step 1: 检测 Python ----
Write-Host "[1/5] 检测 Python 环境..." -ForegroundColor Yellow
$pythonCmd = $null
foreach ($cmd in @("python", "python3")) {
    try {
        $ver = & $cmd --version 2>&1
        if ($LASTEXITCODE -eq 0 -and $ver -match "(\d+)\.(\d+)") {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            if ($major -ge 3 -and $minor -ge 6) {
                $pythonCmd = $cmd
                Write-Host "  ✓ 找到 Python: $ver" -ForegroundColor Green
                break
            }
        }
    } catch {}
}
if (-not $pythonCmd) {
    Write-Host "  ✗ 需要 Python 3.6+，请先安装: https://www.python.org/downloads/" -ForegroundColor Red
    exit 1
}

# ---- Step 2: 安装 Python 依赖 ----
Write-Host "[2/5] 安装 Python 依赖..." -ForegroundColor Yellow
& $pythonCmd -m pip install requests --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ requests 库已就绪" -ForegroundColor Green
} else {
    Write-Host "  ⚠ 安装 requests 失败，部分功能可能受限" -ForegroundColor Yellow
}

# ---- Step 3: 安装 Scrapling ----
Write-Host "[3/5] 安装 Scrapling（反爬采集引擎）..." -ForegroundColor Yellow
& $pythonCmd -m pip install scrapling --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Scrapling 已安装" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Scrapling 安装失败，可手动安装: pip install scrapling" -ForegroundColor Yellow
}

# ---- Step 4: 安装 AnySearch Skill ----
Write-Host "[4/5] 安装 AnySearch 搜索引擎..." -ForegroundColor Yellow
$anysearchDir = Join-Path $RepoRoot "anysearch"
if (-not (Test-Path $anysearchDir)) {
    Write-Host "  → 下载 AnySearch v2.1.0..." -ForegroundColor Gray
    $zipUrl = "https://github.com/anysearch-ai/anysearch-skill/archive/refs/heads/main.zip"
    $zipPath = Join-Path $env:TEMP "anysearch-skill.zip"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
        Move-Item (Join-Path $env:TEMP "anysearch-skill-main") $anysearchDir -Force
        Remove-Item $zipPath -Force
        Write-Host "  ✓ AnySearch 已安装" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ 下载失败: $_" -ForegroundColor Red
        Write-Host "  → 请手动下载: $zipUrl" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✓ AnySearch 已存在" -ForegroundColor Green
}

# ---- Step 5: 配置 runtime.conf ----
Write-Host "[5/5] 配置运行时环境..." -ForegroundColor Yellow
# AnySearch runtime.conf
$asConf = Join-Path $anysearchDir "runtime.conf"
if (-not (Test-Path $asConf)) {
    $asConfContent = @"
Runtime: Python
Command: $pythonCmd $(Join-Path $anysearchDir "scripts\anysearch_cli.py")
"@
    Set-Content -Path $asConf -Value $asConfContent
    Write-Host "  ✓ AnySearch runtime.conf 已创建" -ForegroundColor Green
} else {
    Write-Host "  ✓ runtime.conf 已存在" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "使用方法：" -ForegroundColor White
Write-Host "  调研 {公司全称}          — 完整调研流程" -ForegroundColor Gray
Write-Host "  {公司全称} 快速          — 快速模式" -ForegroundColor Gray
Write-Host "  {公司全称} 带财报        — 深挖模式（启用金融垂直搜索）" -ForegroundColor Gray
Write-Host ""
Write-Host "文件位置：" -ForegroundColor White
Write-Host "  技能本体: $SkillDir" -ForegroundColor Gray
Write-Host "  AnySearch: $anysearchDir" -ForegroundColor Gray
Write-Host ""
