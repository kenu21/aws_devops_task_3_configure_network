$tfPlanPath = "tfplan.json"

if (Test-Path $tfPlanPath) { 
    Write-Output "`u{2705} Checking if terrafom plan exists - OK. "
} else { 
    throw "`u{1F635} Unable to find terraform plan file. Please make sure that you saved terraform execution plan to the file and try again. "
}

$plan = (Get-Content -Path $tfPlanPath | ConvertFrom-Json) 

$subnet = $plan.resource_changes | Where-Object {$_.type -eq "aws_subnet"}
if ($subnet -and ($subnet.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if VPC subnet is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to find VPC subnet. Please make sure that you added a subnet (and only one subnet) to the task module and try again. "
}
if ($subnet.change.after.tags.Name -eq "grafana") {
    Write-Output "`u{2705} Checking if subnet has a name - OK. "
} else { 
    throw "`u{1F635} Unable to validate subnet name. Please make sure that you added a 'Name' tag with value 'grafana' for the subnet and try again. "
}

$igw = $plan.resource_changes | Where-Object {$_.type -eq "aws_internet_gateway"}
if ($igw -and ($igw.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if Internet Gateway is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to find Internet Gateway resource. Please make sure that you added an Internet Gateway resource (and only one Internet Gateway resource) to the task module and try again. "
}
if ($igw.change.after.tags.Name -eq "mate-aws-grafana-lab") { 
    Write-Output "`u{2705} Checking if Internet Gateway has a name - OK. "
} else { 
    throw "`u{1F635} Unable to validate Internet Gateway name. Please make sure that you added a 'Name' tag with value 'mate-aws-grafana-lab' for the Internet Gateway and try again. "
}
# if ($igw.change.after.vpc_id -eq $subnet.change.after.vpc_id) { 
#     Write-Output "`u{2705} Checking if Internet Gateway is associated with the VPC - OK. "
# } else { 
#     throw "`u{1F635} Unable to validate Internet Gateway VPC association. Please make sure that the Internet Gateway is associated with the same VPC you deployed new subnet to and try again. "
# }

$routeTable = $plan.resource_changes | Where-Object {$_.type -eq "aws_route_table"}
if ($routeTable -and ($routeTable.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if route table is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to find route table resource. Please make sure that you added a route table resource (and only one route table resource) to the task module and try again. "
}
if ($routeTable.change.after.tags.Name -eq "mate-aws-grafana-lab") { 
    Write-Output "`u{2705} Checking if route table has a name - OK. "
} else { 
    throw "`u{1F635} Unable to validate route table name. Please make sure that you added a 'Name' tag with value 'mate-aws-grafana-lab' for the route table and try again. "
}
# if ($routeTable.change.after.vpc_id -eq $subnet.change.after.vpc_id) { 
#     Write-Output "`u{2705} Checking if route table is associated with the VPC - OK. "
# } else { 
#     throw "`u{1F635} Unable to validate route table VPC association. Please make sure that the route table is associated with the same VPC you deployed new subnet to and try again. "
# }
$igwRoute = $routeTable.change.after.route | Where-Object {$_.cidr_block -eq "0.0.0.0/0"}
if ($igwRoute -and ($igwRoute.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if Internet gateway route is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to find route, which forwards all traffic ('0.0.0.0/0') to the Internet Gateway resource. Please make sure that you added the route to the route in the table resource and try again. "
}

$routeTableAssociation = $plan.resource_changes | Where-Object {$_.type -eq "aws_route_table_association"}
if ($routeTableAssociation -and ($routeTableAssociation.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if route table subnet association is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to find route table association resource. Please make sure that you added a route table to subnet association resource (and only one such resource) to the task module and try again. "
}

$securityGroup = $plan.resource_changes | Where-Object {$_.type -eq "aws_security_group"}
if ($securityGroup -and ($securityGroup.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if security group is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to find security group resource. Please make sure that you added a security group resource (and only one such resource) to the task module and try again. "
}
if ($securityGroup.change.after.tags.Name -eq "mate-aws-grafana-lab") { 
    Write-Output "`u{2705} Checking if security group has a name - OK. "
} else { 
    throw "`u{1F635} Unable to validate security group name. Please make sure that you added a 'Name' tag with value 'mate-aws-grafana-lab' for the security group and try again. "
}
# if ($securityGroup.change.after.vpc_id -eq $subnet.change.after.vpc_id) { 
#     Write-Output "`u{2705} Checking if security group is associated with the VPC - OK. "
# } else { 
#     throw "`u{1F635} Unable to validate security group to VPC association. Please make sure that the security group is associated with the same VPC you deployed new subnet to and try again. "
# }

$httpIngressRule = $plan.resource_changes | Where-Object {$_.type -eq "aws_vpc_security_group_ingress_rule"} | Where-Object {$_.change.after.to_port -eq "3000" }
if ($httpIngressRule -and ($httpIngressRule.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if the grafana security group rule is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to find grafana security group rule resource, which allows tcp port 3000. Please make sure that you added it to the task module and try again. "
}
if ($httpIngressRule.change.after.cidr_ipv4 -eq "0.0.0.0/0") { 
    Write-Output "`u{2705} Checking the grafana security group rule cidr block - OK. "
} else { 
    throw "`u{1F635} Unable to validate grafana security group cidr block. Please make sure that the rule allows connections to grafana from any IPs ('0.0.0.0/0') try again. "
}

$httpsEgressRule = $plan.resource_changes | Where-Object {$_.type -eq "aws_vpc_security_group_egress_rule"} 
if ($httpsEgressRule -and ($httpsEgressRule.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if the outbound security group rule is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to the outbound security group rule resource. Please make sure that you uncommented it and try again. "
}

$sshIngressRule = $plan.resource_changes | Where-Object {$_.type -eq "aws_vpc_security_group_ingress_rule"} | Where-Object {$_.change.after.to_port -eq "22" }
if ($sshIngressRule -and ($sshIngressRule.Count -eq 1 )) { 
    Write-Output "`u{2705} Checking if ssh security group rule is present in the plan - OK. "
} else { 
    throw "`u{1F635} Unable to find ssh security group rule resource, which allows tcp port 22. Please make sure that you added it to the task module and try again. "
}
if ($sshIngressRule.change.after.cidr_ipv4 -ne "0.0.0.0/0") { 
    Write-Output "`u{2705} Checking the ssh security group rule cidr block - OK. "
} else { 
    throw "`u{1F635} Unable to validate ssh security group cidr block. Please make sure that this rule allows connections for this protocol for only one IP addredd (yours) try again. "
}

Write-Output ""
Write-Output "`u{1F973} Congratulations! All tests passed!"
