locals {
    project_name = "IaC-Lab-2503-Julia"

    web_ingress_rules = [{
        port = 80
        description = "Port 80"
    },
    {
        port = 443
        description = "Port 443"
    }]

     web_egress_rules = [{
        port = 0
        description = "Port 0"
    },
    {
        port = 0
        description = "Port 0"
    }]

    db_ingress_rules = [{
        port = 3306
        description = "Port 3306"
    },
    {
        port = 0
        description = "Port 0"
    }]

     db_egress_rules = [{
        port = 0
        description = "Port 0"
    },
    {
        port = 0
        description = "Port 0"
    }]

}