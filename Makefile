WORKDIR = /home/tim/github/timtaylor/demo3
PATHWAYS = data/raw/2021-12-07-pathways.csv
NHSONLINE = data/raw/2021-12-07-nhs-111-online.csv
LOOKUPS = data/lookups/ccg_to_region.csv

build: Dockerfile
	podman build --file=./Dockerfile --tag=demopw

data/clean/2021-12-07.csv: scripts/clean-data.R $(PATHWAYS) $(NHSONLINE) $(LOOKUPS)
	@echo -e "\n--- Cleaning data ---\n"
	podman run --rm -v $(WORKDIR):/home/demopw:z demopw Rscript $^ $@

reports/demo1.html: reports/demo1.Rmd clean-data build
	@echo -e "\n--- Compiling report ---\n"
	podman run --rm -v $(WORKDIR):/home/demopw:z demopw R -s -e "rmarkdown::render('reports/demo1.Rmd', output_dir='reports')"

paper/paper.pdf: paper/paper.Rmd clean-data
	@echo -e "\n--- Compiling paper ---\n"
	podman run --rm -v $(WORKDIR):/home/demopw:z demopw R -s -e "rmarkdown::render('paper/paper.Rmd', output_dir='paper')"
	xdg-open $@

clean-data: data/clean/2021-12-07.csv

report: reports/demo1.html
	xdg-open $^

paper: paper/paper.pdf
	xdg-open $^


