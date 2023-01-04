OPTIONS := --alignment \
	--decimal-grouping=3 \
	--max-line-length=128 \
	--par-threshold=1 \
	--call-threshold=1 \
	--no-compact \
	--separate-is \
	--end-id \
	--separate-return

pretty:
	@gnatpp -Pgeneric_ecs.gpr -U ${OPTIONS}
	@gnatpp -Ptests/tests.gpr -U ${OPTIONS}
	@gnatpp -Pdemo/demo.gpr -U ${OPTIONS}
