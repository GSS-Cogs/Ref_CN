all: CN_2012.ttl CN_2013.ttl CN_2014.ttl CN_2015.ttl CN_2016.ttl

CN_%.xml:
	curl --compressed --silent --time-cond $@ --output $@ "http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_CLS_DLD&StrNom=$(basename $@)&StrFormat=XML&StrLanguageCode=EN"

CN_%.rdf: CN_%.xml
	xsltproc --novalid -o $@  tordf.xsl $<

CN_%.ttl: CN_%.rdf
	rapper -i rdfxml -o turtle $< > $@
