param(
  [Parameter(Mandatory)][ValidateSet('kali','win')][string]$Vm,
  [string]$Type,          # texte a taper (puis Entree)
  [switch]$NoEnter,
  [switch]$CtrlC,
  [int]$Wait = 2,         # secondes avant la capture
  [string]$Shot           # nom de capture (sans extension) dans captures\
)
$vb = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$name = @{ kali = 'kali-linux-2026.2-virtualbox-amd64'; win = 'VM-Ethical-Hacking-Win10' }[$Vm]
$dir = Join-Path (Split-Path $PSScriptRoot) 'captures'
New-Item -ItemType Directory -Force $dir | Out-Null

# Clavier de Windows = QWERTY britannique : on corrige les touches qui different du clavier US
function Send-Text([string]$t) {
  if ($Vm -ne 'win') { & $vb controlvm $name keyboardputstring $t | Out-Null; return }
  $buf = ''
  foreach ($c in $t.ToCharArray()) {
    $sc = $null
    switch ($c) {
      '\' { $sc = '56 d6' }
      '|' { $sc = '2a 56 d6 aa' }
      '#' { $sc = '2b ab' }
      '~' { $sc = '2a 2b ab aa' }
      '"' { $buf += '@' }
      '@' { $sc = '2a 28 a8 aa' }
      default { $buf += $c }
    }
    if (-not $sc) { continue }
    if ($buf) { & $vb controlvm $name keyboardputstring $buf | Out-Null; $buf = '' }
    & $vb controlvm $name keyboardputscancode @($sc -split ' ') | Out-Null
  }
  if ($buf) { & $vb controlvm $name keyboardputstring $buf | Out-Null }
}

if ($CtrlC) { & $vb controlvm $name keyboardputscancode 1d 2e ae 9d | Out-Null; Start-Sleep 1 }
if ($Type) {
  Send-Text $Type
  if (-not $NoEnter) { & $vb controlvm $name keyboardputscancode 1c 9c | Out-Null }
}
if ($Shot) {
  Start-Sleep $Wait
  $f = Join-Path $dir "$Shot.png"
  & $vb controlvm $name screenshotpng $f | Out-Null
  $f
}
