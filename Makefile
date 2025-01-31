VERSION=$(shell python3 -c "from configparser import ConfigParser; p = ConfigParser(); p.read('setup.cfg'); print(p['metadata']['version'])")
# VERSION=$(shell python3 -c 'import setuptools; print(setuptools.config.read_configuration("setup.cfg")["metadata"]["version"])')

default:
	@echo "\"make publish\"?"

# https://packaging.python.org/tutorials/packaging-projects#id72
upload: clean
	# Make sure we're on the main branch
	@if [ "$(shell git rev-parse --abbrev-ref HEAD)" != "main" ]; then exit 1; fi
	# https://stackoverflow.com/a/58756491/353337
	python3 -m build --sdist --wheel .
	twine upload dist/*

tag:
	@if [ "$(shell git rev-parse --abbrev-ref HEAD)" != "main" ]; then exit 1; fi
	curl -H "Authorization: token `cat $(HOME)/.github-access-token`" -d '{"tag_name": "v$(VERSION)"}' https://api.github.com/repos/nschloe/dmsh/releases

publish: upload tag

clean:
	@find . | grep -E "(__pycache__|\.pyc|\.pyo$\)" | xargs rm -rf
	@rm -rf src/*.egg-info/ build/ dist/ MANIFEST .pytest_cache/ .tox/

format:
	isort .
	black .
	blacken-docs README.md

lint:
	black --check .
	flake8 .
