import yaml


def get_deployment_action(deployment_path, action):
    """Get the overwrites for deployment."""
    with open(deployment_path) as f:
        deployment_vars = yaml.load(f)

    return {
        'action_': action,
        'deployment_dir': '~/.deployments',
        'deployment_choice_': deployment_vars['deployment_name'] + '.yaml'
    }
