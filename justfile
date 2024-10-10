mkpyenv:
	#!/bin/bash
	python3 -m venv .pyvenv
	source .pyvenv/bin/activate
	pip install -r python_requirements.txt

pull-sub:
	git pull && git submodule update --init --recursive

build-venv:
	python -m venv .pyenv	
	source .pyenv/bin/activate
	pip install --upgrade pip
	pip install jinja2
