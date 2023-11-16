Function test1
{
[CmdletBinding(SupportsShouldProcess=$True)]
    Param ([Parameter(Mandatory,ValueFromPipeline)]$p)
    begin{write-host 'begin 1'}
    process{write-host 'process 1'+ $_+$p; return $_}
    end{ write-host 'end 1'}
}

Function test2
{
[CmdletBinding(SupportsShouldProcess=$True)]
    Param ([Parameter(Mandatory,ValueFromPipeline)]$p)
    begin{write-host 'begin 2'}
    process{write-host 'process 2'+$_+$p; return $_}
    end{ write-host 'end 2'}
}
 @(1,3,4)|test1|test2