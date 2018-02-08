CN_2015_20180206_105537.xml:
	curl -s -z CN_2015_20180206_105537.xml -o CN_2015_20180206_105537.xml 'http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_CLS_DLD&StrNom=CN_2015&StrFormat=XML&StrLanguageCode=EN'

%.rdf: %.xml
	xsltproc --novalid -o $@  tordf.xsl $<

%.ttl: %.rdf
	rapper -i rdfxml -o turtle $< > $@
