mkpyenv:
	#!/bin/bash
	python3 -m venv .python_env
	source .python_env/bin/activate
	pip install -r python_requirements.txt

pull-sub:
	git pull && git submodule update --init --recursive
