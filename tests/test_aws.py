from tackle.main import tackle
from tackle.exceptions import HookCallException
import os
from . import get_deployment_action


def test_api_aws_min(change_base_dir, fixture_dir, tmp_move_deployments):
    fixture = os.path.join(fixture_dir, 'api-aws-min.yaml')
    create = tackle(overwrite_inputs=fixture, no_input=True)
    assert create['create_']['deployment_name'] == "polkadot-aws-prod-2"
    tackle(overwrite_inputs=get_deployment_action(fixture, 'plan'), no_input=True)
    # Module assumes existing network. Can't deploy.


def test_api_aws_network(change_base_dir, fixture_dir, tmp_move_deployments):
    fixture = os.path.join(fixture_dir, 'api-aws-network.yaml')
    create = tackle(overwrite_inputs=fixture, no_input=True)
    assert create['create_']['deployment_name'] == "polkadot-aws-prod-3"
    plan = tackle(overwrite_inputs=get_deployment_action(fixture, 'plan'), no_input=True)

    import yaml
    with open('scratch.yaml', 'w') as f:
        yaml.dump(f, plan)

    try:
        tackle(overwrite_inputs=get_deployment_action(fixture, 'apply'), no_input=True)
        tackle(overwrite_inputs=get_deployment_action(fixture, 'destroy'), no_input=True)
    except Exception:
        tackle(overwrite_inputs=get_deployment_action(fixture, 'destroy'), no_input=True)
        raise Exception("Did not apply properly.")


def test_api_aws_k8s(change_base_dir, fixture_dir, tmp_move_deployments):
    fixture = os.path.join(fixture_dir, 'api-aws-k8s.yaml')
    create = tackle(overwrite_inputs=fixture, no_input=True)
    assert create['create_']['deployment_name'] == "polkadot-aws-prod-4"
    plan = tackle(overwrite_inputs=get_deployment_action(fixture, 'plan'), no_input=True)
    assert plan
    try:
        tackle(overwrite_inputs=get_deployment_action(fixture, 'apply'), no_input=True)
        tackle(overwrite_inputs=get_deployment_action(fixture, 'destroy'), no_input=True)
    except Exception:
        tackle(overwrite_inputs=get_deployment_action(fixture, 'destroy'), no_input=True)
        raise Exception("Did not apply properly.")


def test_validator_aws_min(change_base_dir, fixture_dir, tmp_move_deployments):
    fixture = os.path.join(fixture_dir, 'validator-aws-min.yaml')
    create = tackle(overwrite_inputs=fixture, no_input=True)
    assert create['create_']['deployment_name'] == "polkadot-aws-prod-validator-1"
    plan = tackle(overwrite_inputs=get_deployment_action(fixture, 'plan'), no_input=True)
    assert plan


# def test_validator_aws_network(change_base_dir, fixture_dir, tmp_move_deployments):
#     fixture = os.path.join(fixture_dir, 'validator-aws-network.yaml')
#     create = tackle(overwrite_inputs=fixture, no_input=True)
#     assert create['create_']['deployment_name'] == "polkadot-aws-prod-validator-2"
#     plan = tackle(overwrite_inputs=get_deployment_action(fixture, 'plan'), no_input=True)
#     assert plan
#
#
# def test_validator_aws_telemetry(change_base_dir, fixture_dir, tmp_move_deployments):
#     fixture = os.path.join(fixture_dir, 'validator-aws-telemetry.yaml')
#     create = tackle(overwrite_inputs=fixture, no_input=True)
#     assert create['create_']['deployment_name'] == "polkadot-aws-prod-validator-3"
#     plan = tackle(overwrite_inputs=get_deployment_action(fixture, 'plan'), no_input=True)
#     assert plan

# def test_aws_network2(change_base_dir, fixture_dir):
#     plan = tackle(overwrite_inputs=os.path.join(fixture_dir, 'aws-min-plan.yaml'), no_input=True)
#     print("plan")
#     assert plan
