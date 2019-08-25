
# Outputs

/*
 | --
 | -- This user data script must be executed by the instances belonging
 | -- to this cluster straight after initialization.
 | --
*/
output out_user_data_script {

    value = data.template_file.ecs_init.rendered
}
