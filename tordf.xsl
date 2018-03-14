<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xkos="http://rdf-vocabulary.ddialliance.org/xkos#"
                xmlns:ec="https://trade.ec.europa.eu/def/cn#"
>
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/Claset/Classification">
      <rdf:RDF xml:base="https://trade.ec.europa.eu/def/cn">
        <rdfs:Datatype rdf:ID="Section">
          <rdfs:comment>Section code</rdfs:comment>
          <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
          <owl:withRestrictions rdf:parseType="Collection">
            <rdf:Description><xsd:pattern>[MDCLXVI]+</xsd:pattern></rdf:Description>
          </owl:withRestrictions>
        </rdfs:Datatype>
        <rdfs:Datatype rdf:ID="Chapter">
          <rdfs:comment>Chapter code</rdfs:comment>
          <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
          <owl:withRestrictions rdf:parseType="Collection">
            <rdf:Description><xsd:pattern>[0-9]{2}</xsd:pattern></rdf:Description>
          </owl:withRestrictions>
        </rdfs:Datatype>

        <skos:ConceptScheme rdf:ID="{@id}">
          <rdfs:label><xsl:value-of select="Label/LabelText"/></rdfs:label>
          <rdfs:comment><xsl:value-of select="Property[@name='Comment']/PropertyQualifier/PropertyText"/></rdfs:comment>
          <!-- <xkos:numberOfLevels><xsl:value-of select="max(//node()[not(node())]/count(ancestor-or-self::node()))"/></xkos:numberOfLevels> -->
        </skos:ConceptScheme>
        <xsl:apply-templates select="Item"/>
      </rdf:RDF>
    </xsl:template>

    <xsl:template match="Item[@idLevel='1']"> <!-- sections -->
      <skos:Concept rdf:ID="section_{Label[1]/LabelText/text()}">
        <skos:inScheme rdf:resource="#{/Claset/Classification/@id}"/>
        <rdfs:label xml:lang="en"><xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/></rdfs:label>
        <skos:notation rdf:datatype="https://trade.ec.europa.eu/def/cn#Section"><xsl:value-of select="Label[1]/LabelText/text()"/></skos:notation>
      </skos:Concept>
    </xsl:template>

    <xsl:template match="Item[@idLevel='2']"> <!-- chapters -->
      <skos:Concept rdf:ID="chapter_{Label[1]/LabelText/text()}">
        <skos:inScheme rdf:resource="#{/Claset/Classification/@id}"/>
        <xsl:choose>
          <xsl:when test="count(Property[@name='ExplanatoryNote']/PropertyQualifier) = 3">
            <rdfs:label xml:lang="en"><xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/></rdfs:label>
          </xsl:when>
          <xsl:otherwise>
            <rdfs:label xml:lang="en"><xsl:value-of select="Label/LabelText"/></rdfs:label>
          </xsl:otherwise>
        </xsl:choose>
        <xkos:specializes rdf:resource="#section_{preceding-sibling::Item[@idLevel='1'][1]/Label[1]/LabelText/text()}"/>
        <skos:notation rdf:datatype="https://trade.ec.europa.eu/def/cn#Chapter"><xsl:value-of select="Label[1]/LabelText/text()"/></skos:notation>
      </skos:Concept>
    </xsl:template>

    <xsl:template match="Item">
      <xsl:variable name="code" select="translate(Label[@qualifier='Usual']/LabelText[@language='ALL']/text(), ' ', '')"/>
      <xsl:choose>
        <xsl:when test="(string-length($code) = 8) and (translate($code, '0123456789', '') = '')">
          <skos:Concept rdf:ID="cn8_{$code}">
            <xsl:choose>
              <xsl:when test="count(Property[@name='ExplanatoryNote']/PropertyQualifier) = 3">
                <rdfs:label xml:lang="en"><xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/></rdfs:label>
              </xsl:when>
              <xsl:otherwise>
                <rdfs:label xml:lang="en"><xsl:value-of select="Label/LabelText"/></rdfs:label>
              </xsl:otherwise>
            </xsl:choose>
          </skos:Concept>
        </xsl:when>
      </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
