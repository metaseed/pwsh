# https://powershellmagazine.com/2012/10/11/connecting-to-hyper-v-virtual-machines-with-powershell/
 import-module Hyper-V
function Connect-VM {
  [CmdletBinding(DefaultParameterSetName = 'name')]
  
  param(
    [Parameter(ParameterSetName = 'name')]
    [Alias('cn')]
    [System.String[]]$ComputerName = $env:COMPUTERNAME,
  
    [Parameter(Position = 0,
      Mandatory, ValueFromPipelineByPropertyName,
      ValueFromPipeline, ParameterSetName = 'name')]
    [Alias('n')]
    [System.String]$Name,
  
    [Parameter(Position = 0,
      Mandatory, ValueFromPipelineByPropertyName,
      ValueFromPipeline, ParameterSetName = 'id')]
    [Alias('VMId', 'Guid')]
    [System.Guid]$Id,
  
    [Parameter(Position = 0, Mandatory,
      ValueFromPipeline, ParameterSetName = 'inputObj')]
    [Microsoft.HyperV.PowerShell.VirtualMachine]$inputObj,

    [Alias('s')]
    [switch]$Start
  )
  
  begin {
    # get-vm need admin
    Assert-Admin
    Write-Verbose "Initializing InstanceCount: 0"
    $InstanceCount = 0
  }
  
  process {
    try {
      $pmsn = $PSCmdlet.ParameterSetName
      foreach ($computer in $ComputerName) {
        Write-Verbose "ParameterSetName is '$($pmsn)'"
  
        if ($pmsn -eq 'name') {
          if ($Name -as [guid]) {
            Write-Verbose "Incoming value can cast to guid"
            $vm = Get-VM -ComputerName $computer -Id $Name -ErrorAction SilentlyContinue
          }
          else {
            $vm = Get-VM -ComputerName $computer -Name $Name -ErrorAction SilentlyContinue
          }
        }
        elseif ($pmsn -eq 'id') {
          $vm = Get-VM -ComputerName $computer -Id $Id -ErrorAction SilentlyContinue
        }
        else {
          $vm = $inputObj
        }
  
        if ($vm) {
          Write-Verbose "Executing 'vmconnect.exe $computer $($vm.Name) -G $($vm.Id) -C $InstanceCount'"
          vmconnect.exe $computer $vm.Name -G $vm.Id -C $InstanceCount

          if ($Start) {
            if ($vm.State -eq 'off' -or $vm.State -eq 'saved') {
              Write-Verbose "Start switch was specified and VM state is '$($vm.State)'. Starting VM '$($vm.Name)'"
              Start-VM -VM $vm
            }
            else {
              Write-Verbose "Starting VM '$($vm.Name)'. Skipping, VM is not not in 'off' state."
            }
          }
    
        }
        else {
          Write-Information "Cannot find vm: '$Name'"
        }
  
        $InstanceCount += 1
        Write-Verbose "InstanceCount = $InstanceCount"
      }
    }
    catch {
      Write-Error $_
    }
  }
  
}
# Connect-VM work -StartVM