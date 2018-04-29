function prompt
{
    Write-Host "$(pwd)" -ForegroundColor Yellow
    return '> '
}

function Set-DevEnv
{
    pushd 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC'
    cmd /c "vcvarsall.bat&set" |
    foreach {
      if ($_ -match "=") {
        $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
      }
    }
    popd
}

Import-Module PSColor