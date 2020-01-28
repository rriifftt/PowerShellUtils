Param(
    [Parameter(Mandatory=$True)]
    [ValidateSet("Start-Session", "PortFowarding")]
    [String]$Mode="Start-Session",
    [Parameter(Mandatory=$True)]
    [String]$Name,
    [Parameter()]
    [String]$DistPort,
    [Parameter()]
    [String]$LocalPort,
    [Parameter()]
    [String]$Profile="default"
)

if ((Get-Command aws -ea SilentlyContinue | Out-Null) -eq $False) {
    Write-Host "ERROR. AWSCLI is not Installed."
    exit 1
}

function Start-PortForwaringSession
{
    aws ssm start-session `
        --document-name AWS-StartPortForwardingSession `
        --parameters "portNumber=$DistPort,localPortNumber=$LocalPort" `
        --target $InstanceId `
        --profile $Profile
}

function Start-Session
{
    aws ssm start-session `
        --target $InstanceId `
        --profile $Profile
}

$InstanceId = aws ec2 describe-instances `
    --filter "Name=tag-value,Values=$Name" `
    --query "Reservations[].Instances[].InstanceId" `
    --output text `
    --profile $Profile

Switch ($Mode)
{
    "Start-Session" { Start-Session }
    "PortFowarding" { Start-PortForwaringSession }
}
