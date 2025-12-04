.PHONY: test test-smoke test-unit test-integration

test:
	PYTHONPATH=./nucleo-api pytest -q

test-smoke:
	PYTHONPATH=./nucleo-api pytest -q -m smoke

test-unit:
	PYTHONPATH=./nucleo-api pytest -q -m unit

test-integration:
	PYTHONPATH=./nucleo-api pytest -q -m integration
