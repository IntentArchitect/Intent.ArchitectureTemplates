param(
    [switch]$Reset
)

$modulesIsln = "Modules/Intent.ArchitectureTemplates.isln"

if ($Reset) {
    ./PipelineScripts/run-pre-commit-checks.ps1 -ModulesIsln $modulesIsln -Reset
    exit 0
}

./PipelineScripts/run-pre-commit-checks.ps1 -ModulesIsln $modulesIsln
exit 0
