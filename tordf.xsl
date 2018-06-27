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
      <rdf:RDF xml:base="https://trade.ec.europa.eu/def/{translate(@id, 'CN', 'cn')}">
        <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#Section">
          <rdfs:comment>Section code</rdfs:comment>
          <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
          <owl:withRestrictions rdf:parseType="Collection">
            <rdf:Description><xsd:pattern>[MDCLXVI]+</xsd:pattern></rdf:Description>
          </owl:withRestrictions>
        </rdfs:Datatype>
        <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#HS2">
          <rdfs:comment>Chapter in the Harmonised System</rdfs:comment>
          <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
          <owl:withRestrictions rdf:parseType="Collection">
            <rdf:Description><xsd:pattern>[0-9]{2}</xsd:pattern></rdf:Description>
          </owl:withRestrictions>
        </rdfs:Datatype>
        <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#HS4">
          <rdfs:comment>Harmonised System heading</rdfs:comment>
          <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
          <owl:withRestrictions rdf:parseType="Collection">
            <rdf:Description><xsd:pattern>[0-9]{4}</xsd:pattern></rdf:Description>
          </owl:withRestrictions>
        </rdfs:Datatype>
        <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#HS6">
          <rdfs:comment>Harmonised System subheading</rdfs:comment>
          <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
          <owl:withRestrictions rdf:parseType="Collection">
            <rdf:Description><xsd:pattern>[0-9]{4} [0-9]{2}</xsd:pattern></rdf:Description>
          </owl:withRestrictions>
        </rdfs:Datatype>
        <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#CN8">
          <rdfs:comment>CN subheading (8 digits)</rdfs:comment>
          <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
          <owl:withRestrictions rdf:parseType="Collection">
            <rdf:Description><xsd:pattern>[0-9]{4} [0-9]{2} [0-9]{2}</xsd:pattern></rdf:Description>
          </owl:withRestrictions>
        </rdfs:Datatype>

        <skos:ConceptScheme rdf:about="">
          <rdfs:label><xsl:value-of select="Label/LabelText"/></rdfs:label>
          <rdfs:comment><xsl:value-of select="Property[@name='Comment']/PropertyQualifier/PropertyText"/></rdfs:comment>
          <!-- <xkos:numberOfLevels><xsl:value-of select="max(//node()[not(node())]/count(ancestor-or-self::node()))"/></xkos:numberOfLevels> -->
        </skos:ConceptScheme>
        <xsl:apply-templates select="Item"/>
      </rdf:RDF>
    </xsl:template>

    <xsl:template match="Item[@idLevel='1']"> <!-- sections -->
      <skos:Concept rdf:ID="section_{Label[1]/LabelText/text()}">
        <skos:inScheme rdf:resource=""/>
        <rdfs:label xml:lang="en"><xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/></rdfs:label>
        <skos:notation rdf:datatype="https://trade.ec.europa.eu/def/cn#Section"><xsl:value-of select="Label[1]/LabelText/text()"/></skos:notation>
      </skos:Concept>
    </xsl:template>

    <xsl:template match="Item[@idLevel='2']"> <!-- chapters -->
      <skos:Concept rdf:ID="hs2_{Label[1]/LabelText/text()}">
        <skos:inScheme rdf:resource=""/>
        <xsl:choose>
          <xsl:when test="count(Property[@name='ExplanatoryNote']/PropertyQualifier) = 3">
            <rdfs:label xml:lang="en"><xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/></rdfs:label>
          </xsl:when>
          <xsl:otherwise>
            <rdfs:label xml:lang="en"><xsl:value-of select="Label/LabelText"/></rdfs:label>
          </xsl:otherwise>
        </xsl:choose>
        <xkos:specializes rdf:resource="#section_{preceding-sibling::Item[@idLevel='1'][1]/Label[1]/LabelText/text()}"/>
        <skos:notation rdf:datatype="https://trade.ec.europa.eu/def/cn#HS2"><xsl:value-of select="Label[1]/LabelText/text()"/></skos:notation>
      </skos:Concept>
    </xsl:template>

    <xsl:template match="Item">
      <xsl:variable name="codeLabel" select="Label[@qualifier='Usual']/LabelText[@language='ALL']/text()"/>
      <xsl:variable name="code" select="translate($codeLabel, ' ', '')"/>
      <xsl:choose>
        <xsl:when test="(string-length($code) = 8) and (translate($code, '0123456789', '') = '')">
          <skos:Concept rdf:ID="cn8_{$code}">
            <skos:inScheme rdf:resource=""/>
            <xsl:choose>
              <xsl:when test="count(Property[@name='ExplanatoryNote']/PropertyQualifier) = 3">
                <rdfs:label xml:lang="en"><xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/></rdfs:label>
              </xsl:when>
              <xsl:otherwise>
                <rdfs:label xml:lang="en"><xsl:value-of select="Label/LabelText"/></rdfs:label>
              </xsl:otherwise>
            </xsl:choose>
            <skos:notation rdf:datatype="https://trade.ec.europa.eu/def/cn#CN8"><xsl:value-of select="$codeLabel"/></skos:notation>
            <xsl:choose>
              <xsl:when test="'00' = substring($code, 7)">
                <skos:specializes rdf:resource="#hs4_{substring($code, 1, 4)}"/>
              </xsl:when>
              <xsl:otherwise>
                <skos:specializes rdf:resource="#hs6_{substring($code, 1, 6)}"/>
              </xsl:otherwise>
            </xsl:choose>
          </skos:Concept>
        </xsl:when>
        <xsl:when test="(string-length($code) = 6) and (translate($code, '0123456789', '') = '')">
          <skos:Concept rdf:ID="hs6_{$code}">
            <skos:inScheme rdf:resource=""/>
            <xsl:choose>
              <xsl:when test="count(Property[@name='ExplanatoryNote']/PropertyQualifier) = 3">
                <rdfs:label xml:lang="en"><xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/></rdfs:label>
              </xsl:when>
              <xsl:otherwise>
                <rdfs:label xml:lang="en"><xsl:value-of select="Label/LabelText"/></rdfs:label>
              </xsl:otherwise>
            </xsl:choose>
            <skos:notation rdf:datatype="https://trade.ec.europa.eu/def/cn#HS6"><xsl:value-of select="$codeLabel"/></skos:notation>
            <skos:specializes rdf:resource="#hs4_{substring($code, 1, 4)}"/>
          </skos:Concept>
        </xsl:when>
        <xsl:when test="(string-length($code) = 4) and (translate($code, '0123456789', '') = '')">
          <skos:Concept rdf:ID="hs4_{$code}">
            <skos:inScheme rdf:resource=""/>
            <xsl:choose>
              <xsl:when test="count(Property[@name='ExplanatoryNote']/PropertyQualifier) = 3">
                <rdfs:label xml:lang="en"><xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/></rdfs:label>
              </xsl:when>
              <xsl:otherwise>
                <rdfs:label xml:lang="en"><xsl:value-of select="Label/LabelText"/></rdfs:label>
              </xsl:otherwise>
            </xsl:choose>
            <skos:notation rdf:datatype="https://trade.ec.europa.eu/def/cn#HS6"><xsl:value-of select="$codeLabel"/></skos:notation>
            <skos:specializes rdf:resource="#hs2_{substring($code, 1, 2)}"/>
          </skos:Concept>
        </xsl:when>
      </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
