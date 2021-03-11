from tackle.main import tackle
import os


def test_init(tmp_move_deployments, change_base_dir, fixture_dir):
    """Test to see if the deployments directory initializes properly."""
    output = tackle(overwrite_inputs=os.path.join(fixture_dir, 'init.yaml'), no_input=True)
    assert output['deployment_list_'] == []


# Can't run in CI - prompts for password
# def test_key_generate(tmp_move_deployments, change_base_dir, fixture_dir):
#     output = tackle(overwrite_inputs=os.path.join(fixture_dir, 'key.yaml'), no_input=True)
#     assert output
