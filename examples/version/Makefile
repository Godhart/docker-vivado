IMAGE = vivado

default:
	docker run --rm --pid=host -v $(PWD):/home/vivado/workspace "$(IMAGE)" bash --login /home/vivado/workspace/version.sh
