pdf:
	pandoc sbtb-2020-type-safe-fpga.md \
		-o SBTB-2020-Type-Safe-FPGA.pdf \
		-t beamer \
		-f markdown+implicit_figures \
		--slide-level=2 \
		--pdf-engine=xelatex
watch:
	watchexec -e md -i fig -- make pdf
