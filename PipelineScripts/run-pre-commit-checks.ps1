param(
    [Parameter(Mandatory = $true)][string]$ModulesIsln,
    [switch]$Reset
)

if ($Reset) {
    if ($Env:INTENT_PRE_COMMIT_CHECK_PHASE) {
        Remove-Item Env:INTENT_PRE_COMMIT_CHECK_PHASE
    }

    Write-Host "Reset performed, all phases will be run on the next execution"
    exit
}

$currentPhase = 0;
$modulesFolder = [System.IO.Path]::GetDirectoryName($ModulesIsln)

if ([int]$Env:INTENT_PRE_COMMIT_CHECK_PHASE -gt 0) {
    Write-Host "Resuming from last successfully completed phase, use the -Reset parameter to remove memory of successfully completed phases."
}

if ([int]$Env:INTENT_PRE_COMMIT_CHECK_PHASE -ge ++$currentPhase) {
    Write-Host "Skipping `"ensure no outstanding changes to modules`" phase as was successfully completed previously."
}
else {
    ./PipelineScripts/ensure-no-outstanding-sf-changes.ps1 -IslnPath "$ModulesIsln"
    if ($LASTEXITCODE -ne 0) {
        exit
    }

    $Env:INTENT_PRE_COMMIT_CHECK_PHASE = $currentPhase
}

if ([int]$Env:INTENT_PRE_COMMIT_CHECK_PHASE -ge ++$currentPhase) {
    Write-Host "Skipping `"build all modules`" phase as was successfully completed previously."
}
else {
    ./PipelineScripts/build-all.ps1 -Folder "$modulesFolder" -RestoreFirstWithForceEvaluate
    if ($LASTEXITCODE -ne 0) {
        exit
    }

    $Env:INTENT_PRE_COMMIT_CHECK_PHASE = $currentPhase
}

Write-Host "✅ All checks completed successfully, commit, push and the CI build should hopefully succeed 🤞"
Remove-Item Env:INTENT_PRE_COMMIT_CHECK_PHASE
exit 0
