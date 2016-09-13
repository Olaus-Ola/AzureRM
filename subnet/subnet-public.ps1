Param
(
    [Parameter(Mandatory=$true)]
    [String] 
    $ResourceGroupName,    
    [Parameter(Mandatory=$true)]
    [String] 
    $Location,  
    [Parameter(Mandatory=$true)]
    [String] 
    $VnetName,    
    [Parameter(Mandatory=$true)]
    [Int] 
    $SubnetIndex,   
    [Parameter(Mandatory=$true)]
    [String] 
    $LoadBalancerName,    
    
    [Parameter(Mandatory=$true)]
    [String] 
    $AvailabilitySetName,
    
    [Parameter(Mandatory=$true)]
    [String] 
    $AddressPrefix

)

$vnet = Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName


$pip = New-AzureRmPublicIpAddress -Name "$LoadBalancerName-pip" -ResourceGroupName $ResourceGroupName `
                                  -Location $Location -AllocationMethod Static `
                                  -DomainNameLabel "$LoadBalancerName-public".ToLower()

$frontEndIp = New-AzureRmLoadBalancerFrontendIpConfig -Name "$LoadBalancerName-frontend" `
                                                      -PublicIpAddress $pip

$backEndPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "$LoadBalancerName-backend"

$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name "$LoadBalancerName-probe" `
                                                  -Protocol Http -Port 80 -RequestPath "/" `
                                                  -IntervalInSeconds 10 -ProbeCount 3

$lbRule = New-AzureRmLoadBalancerRuleConfig -Name "HTTP" -FrontendIpConfiguration $frontEndIp `
                                            -BackendAddressPool $backEndPool -Probe $healthProbe `
                                            -Protocol Tcp -FrontendPort 80 -BackendPort 80


#-InboundNatRule $inboundNATRule1,$inboundNatRule2

#Create Load Balancer
New-AzureRmLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LoadBalancerName -Location $Location -FrontendIpConfiguration $frontEndIp  -LoadBalancingRule $lbrule -BackendAddressPool $backEndPool -Probe $healthProbe

#Create AvailabilitySet
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Location $Location -Name $AvailabilitySetName
