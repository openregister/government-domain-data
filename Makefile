all: govuk_domains edent_domains data

mkdirs:
	mkdir -p {cache,lists,data}

govuk_domains: mkdirs
	curl -qs 'https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/557592/List_of_gov.uk_domains_as_of_1_Oct_2016.csv' \
	| iconv -f ISO-8859-1 -t UTF-8 \
	> cache/govuk_domains.csv && \
	bin/process_govuk_csv.py > lists/govuk_domains.csv


edent_domains: mkdirs
	curl -qs 'https://shkspr.mobi/blog/wp-content/uploads/2015/11/Gov-UK-Domains.zip' > cache/Edent-Gov-UK-Domains.zip \
	&& unzip -o -d lists cache/Edent-Gov-UK-Domains.zip govuk.csv \
	&& mv lists/govuk.csv lists/edent-govuk.csv


data: mkdirs govuk_domains edent_domains
	python bin/build_data.py

clean:
	rm -rf cache
