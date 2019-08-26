
/*
 | --
 | -- The ecs task definition is at the heart of containerized infrastructure in the
 | -- AWS cloud. This resource can support multiple tasks and expects to be provided
 | -- with the JSON container workload definitions, the role profile arn for ECS tasks,
 | -- volume mappings (host and docker managed) and a map of mandatory tags.
 | --
*/
resource aws_ecs_task_definition workload {

    count  = length( var.in_workload_names )
    family = "${ var.in_ecosystem }-${ var.in_workload_names[ count.index ] }-workload-${ var.in_timestamp }"

    task_role_arn = var.in_ecs_task_role_arn
    execution_role_arn = var.in_ecs_task_role_arn
    network_mode = "host"
    container_definitions = element( var.in_container_definitions, count.index )

    dynamic volume {
        for_each = var.in_host_managed_volumes
        content {
            name      = volume.key
            host_path = volume.value
        }
    }

    dynamic volume {
        for_each = var.in_docker_managed_volumes
        content {
            name = volume.value
            docker_volume_configuration {
                scope = "shared"
                autoprovision = true
            }
        }
    }

    tags = merge(
        {
            Name = "${ var.in_ecosystem }-${ var.in_workload_names[ count.index ] }-workload-${ var.in_timestamp }",
            Desc = "This ${ var.in_ecosystem } ${ var.in_workload_names[ count.index ] } task definition ${ var.in_description }"
        },
        var.in_mandatory_tags
    )
}


/*
 | --
 | -- The raw ECS cluster resource is declared here. This no frills resource needs to
 | -- know nothing more than its name and a set of mandatory tags.
 | --
*/
resource aws_ecs_cluster cluster {

    name = "${ var.in_ecosystem }-cluster-${ var.in_timestamp }"
    tags = merge( local.ecs_cluster_tags, var.in_mandatory_tags )
}


/*
 | --
 | -- The collection of containerized services to run on the ECS cluster in tandem
 | -- with the application load balancer (and its http and https listeners) is defined
 | -- here.
 | --
 | -- The ID of the above cluster is provided as well as the ARN of each one of the
 | -- task definitions defined above. The ARNs for each of the load balancer's target
 | -- groups must be provided. These services depend on the load balancer listeners
 | -- being fully provisioned.
 | --
*/
resource aws_ecs_service this {

    count = length( var.in_workload_names )
    name = "${ var.in_ecosystem }-${ var.in_workload_names[ count.index ] }-service-${ var.in_timestamp }"

    cluster = aws_ecs_cluster.cluster.id
    task_definition = element( aws_ecs_task_definition.workload.*.arn, count.index )
    iam_role = aws_iam_role.ecs-service-role.name
    scheduling_strategy = "DAEMON"
    health_check_grace_period_seconds = 300

    load_balancer {
        target_group_arn = element( var.in_target_group_ids, count.index )
        container_name = var.in_workload_names[ count.index ]
        container_port = var.in_workload_ports[ count.index ]
    }

    depends_on = [ var.in_http_listener, var.in_https_listener ]

    tags = merge(
        {
            Name = "${ var.in_ecosystem }-ecs-${ var.in_workload_names[ count.index ] }-service-${ var.in_timestamp }"
            Desc = "This ${ var.in_ecosystem } ECS ${ var.in_workload_names[ count.index ] } service ${ var.in_description }"
        },
        var.in_mandatory_tags
    )
}


/*
 | --
 | -- ECS init is a user data (like) script that fires up the ECS cluster. The
 | -- scriptt requires the name of the cluster and this parameter is passed in
 | -- using Terraform's string interpolation feature.
 | --
*/
data template_file ecs_init {

    template = file( "${path.module}/ecs-user-data-script.sh" )
    vars = {
        ecs_cluster_name = "${ var.in_ecosystem }-cluster-${ var.in_timestamp }"
    }
}


/*
 | --
 | -- The service role that is needed by the ECS container agent. The container agent
 | -- needs to access the images and also pass on some permissions for the containers
 | -- to have access to some AWS resources.
 | --
*/
resource aws_iam_role ecs-service-role {

    name               = "ecs-service-role"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.ecs-service-policy.json
}


/*
 | --
 | -- This attachment pulls together the policy document and associates it
 | -- (attaches it) to the role.
 | --
*/
resource aws_iam_role_policy_attachment ecs-service-role-attachment {
    role       = aws_iam_role.ecs-service-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}


/*
 | --
 | -- This policy document provides the JSON that defines the ECS service
 | -- role that the ECS agent inherits.
 | --
*/
data aws_iam_policy_document ecs-service-policy {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}


/*
 | --
 | -- These tag definitions are attached onto the central
 | -- ECS container cluster along with the mandatory tags.
 | --
*/
locals {

    ecs_cluster_tags = {
        Name = "${ var.in_ecosystem }-cluster-${ var.in_timestamp }"
        Desc = "This ${ var.in_ecosystem } ECS cluster ${ var.in_description }"
    }
}
