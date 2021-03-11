import pytest
import shutil
import os

@pytest.fixture(scope='function')
def change_base_dir():
    """Change dir to the base of the repo."""
    os.chdir(os.path.join(os.path.abspath(os.path.dirname(__file__)), ".."))

@pytest.fixture()
def fixture_paths():
    """Change to the fixtures dir in the current directory of the test."""
    dir = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'fixtures')
    return [os.path.join(dir, i) for i in os.listdir(dir)]

@pytest.fixture()
def fixture_dir():
    dir = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'fixtures')
    return dir


@pytest.fixture()
def tmp_move_deployments():
    """Fixture to temporarily move deployments folder before test and replace it after."""
    deps_dir = os.path.join(os.path.expanduser('~'), '.deployments')
    tmp_deps_dir = os.path.join(os.path.expanduser('~'), '.deployments' + '.tmp')
    if os.path.isdir(deps_dir):
        os.rename(deps_dir, tmp_deps_dir)
    yield
    if os.path.isdir(deps_dir):
        shutil.rmtree(deps_dir)
    if os.path.isdir(tmp_deps_dir):
        os.rename(tmp_deps_dir, deps_dir)
