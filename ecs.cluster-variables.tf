
################ ############################################# ########
################ Module [[[ECS Cluster]]] Input Variables List ########
################ ############################################# ########


### #################### ###
### in_ecs_task_role_arn ###
### #################### ###

variable in_ecs_task_role_arn {
    description = "The ARN of the role wrapping the access privileges to AWS resources."
}


### ##############b######### ###
### in_container_definitions ###
### ##############b######### ###

variable in_container_definitions {
    description = "A list of the ubiquitous JSON formatted container workload definitions."
    type = list
}

### ################### ###
### in_target_group_ids ###
### ################### ###

variable in_target_group_ids {
    description = "A collection of target group identifiers that bond the load balancer to services on the ECS cluster."
    type = list
}

### ################ ###
### in_http_listener ###
### ################ ###

variable in_http_listener {
    description = "The load balancer listener for application http traffic."
}


### ################# ###
### in_https_listener ###
### ################# ###

variable in_https_listener {
    description = "The load balancer listener for application https (tls) traffic."
}


### ################# ###
### in_workload_names ###
### ################# ###

variable in_workload_names {
    description = "The list of container workload names."
    type = list
}


### ################# ###
### in_workload_ports ###
### ################# ###

variable in_workload_ports {
    description = "The list of container workload ports."
    type = list
}


### #################################### ###
### [[variable]] in_host_managed_volumes ###
### #################################### ###

variable in_host_managed_volumes {

    description = "A map of the name and path on he host for drive mapping via host managed volumes."
    type        = map
    default     = { }
}


### ###################################### ###
### [[variable]] in_docker_managed_volumes ###
### ###################################### ###

variable in_docker_managed_volumes {

    description = "The list of names for the drive mapping of docker managed volumes."
    type        = list
    default     = [ ]
}


### ############################## ###
### [[variable]] in_mandated_tags ###
### ############################## ###

variable in_mandated_tags {

    description = "Optional tags unless your organization mandates that a set of given tags must be set."
    type        = map
    default     = { }
}


### ############ ###
### in_ecosystem ###
### ############ ###

variable in_ecosystem {
    description = "The name of the ecosystem (environment superclass) being created or changed."
    default = "ecosystem"
    type = string
}


### ############ ###
### in_timestamp ###
### ############ ###

variable in_timestamp {
    description = "The numerical timestamp denoting the time this eco instance was instantiated."
    type = string
}


### ############## ###
### in_description ###
### ############## ###

variable in_description {
    description = "The when and where description of this ecosystem creation."
    type = string
}

