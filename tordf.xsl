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
          <rdf:Description>
            <xsd:pattern>[MDCLXVI]+</xsd:pattern>
          </rdf:Description>
        </owl:withRestrictions>
      </rdfs:Datatype>
      <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#HS2">
        <rdfs:comment>Chapter in the Harmonised System</rdfs:comment>
        <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
        <owl:withRestrictions rdf:parseType="Collection">
          <rdf:Description>
            <xsd:pattern>[0-9]{2}</xsd:pattern>
          </rdf:Description>
        </owl:withRestrictions>
      </rdfs:Datatype>
      <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#HS4">
        <rdfs:comment>Harmonised System heading</rdfs:comment>
        <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
        <owl:withRestrictions rdf:parseType="Collection">
          <rdf:Description>
            <xsd:pattern>[0-9]{4}</xsd:pattern>
          </rdf:Description>
        </owl:withRestrictions>
      </rdfs:Datatype>
      <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#HS6">
        <rdfs:comment>Harmonised System subheading</rdfs:comment>
        <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
        <owl:withRestrictions rdf:parseType="Collection">
          <rdf:Description>
            <xsd:pattern>[0-9]{4} [0-9]{2}</xsd:pattern>
          </rdf:Description>
        </owl:withRestrictions>
      </rdfs:Datatype>
      <rdfs:Datatype rdf:about="https://trade.ec.europa.eu/def/cn#CN8">
        <rdfs:comment>CN subheading (8 digits)</rdfs:comment>
        <owl:onDatatype rdf:resource="http://www.w3.org/2001/XMLSchema#String"/>
        <owl:withRestrictions rdf:parseType="Collection">
          <rdf:Description>
            <xsd:pattern>[0-9]{4} [0-9]{2} [0-9]{2}</xsd:pattern>
          </rdf:Description>
        </owl:withRestrictions>
      </rdfs:Datatype>

      <skos:ConceptScheme rdf:about="">
        <rdfs:label>
          <xsl:value-of select="Label/LabelText"/>
        </rdfs:label>
        <rdfs:comment>
          <xsl:value-of select="Property[@name='Comment']/PropertyQualifier/PropertyText"/>
        </rdfs:comment>
        <xsl:apply-templates select="Item[@idLevel='1']" mode="hasTopConcept"/>
      </skos:ConceptScheme>
      <xsl:apply-templates select="Item"/>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="Item" mode="hasTopConcept">
    <xsl:variable name="codeLabel" select="Label[@qualifier='Usual']/LabelText[@language='ALL']/text()"/>
    <xsl:variable name="code" select="translate($codeLabel, ' ', '')"/>
    <skos:hasTopConcept rdf:resource="#section_{$code}"/>
  </xsl:template>

  <xsl:template match="Item">
    <xsl:variable name="codeLabel" select="Label[@qualifier='Usual']/LabelText[@language='ALL']/text()"/>
    <xsl:variable name="code" select="translate($codeLabel, ' ', '')"/>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="count(Property[@name='ExplanatoryNote']/PropertyQualifier) = 3">
          <rdfs:label xml:lang="en">
            <xsl:value-of select="Property[@name='ExplanatoryNote']/PropertyQualifier[1]/PropertyText"/>
          </rdfs:label>
        </xsl:when>
        <xsl:otherwise>
          <rdfs:label xml:lang="en">
            <xsl:value-of select="Label/LabelText"/>
          </rdfs:label>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@idLevel = '1'">
        <xsl:call-template name="concept">
          <xsl:with-param name="ID" select="concat('section_', $code)"/>
          <xsl:with-param name="label" select="$label"/>
          <xsl:with-param name="notation" select="$codeLabel"/>
          <xsl:with-param name="notationType">Section</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@idLevel = '2'">
        <xsl:call-template name="concept">
          <xsl:with-param name="ID" select="concat('hs2_', $code)"/>
          <xsl:with-param name="label" select="$label"/>
          <xsl:with-param name="notation" select="$codeLabel"/>
          <xsl:with-param name="notationType">HS2</xsl:with-param>
          <xsl:with-param name="parent" select="concat('#section_', preceding-sibling::Item[@idLevel='1'][1]/Label[1]/LabelText/text())"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="(string-length($code) = 4) and (translate($code, '0123456789', '') = '')">
        <xsl:call-template name="concept">
          <xsl:with-param name="ID" select="concat('hs4_', $code)"/>
          <xsl:with-param name="label" select="$label"/>
          <xsl:with-param name="notation" select="$codeLabel"/>
          <xsl:with-param name="notationType">HS4</xsl:with-param>
          <xsl:with-param name="parent" select="concat('#hs2_', substring($code, 1, 2))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="(string-length($code) = 6) and (translate($code, '0123456789', '') = '')">
        <xsl:call-template name="concept">
          <xsl:with-param name="ID" select="concat('hs6_', $code)"/>
          <xsl:with-param name="label" select="$label"/>
          <xsl:with-param name="notation" select="$codeLabel"/>
          <xsl:with-param name="notationType">HS6</xsl:with-param>
          <xsl:with-param name="parent"><xsl:choose>
            <xsl:when test="'00' = substring($code, 5)"><xsl:value-of select="concat('#hs2_', substring($code, 1, 2))"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="concat('#hs4_', substring($code, 1, 4))"/></xsl:otherwise>
          </xsl:choose></xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="(string-length($code) = 8) and (translate($code, '0123456789', '') = '')">
        <xsl:call-template name="concept">
          <xsl:with-param name="ID" select="concat('cn8_', $code)"/>
          <xsl:with-param name="label" select="$label"/>
          <xsl:with-param name="notation" select="$codeLabel"/>
          <xsl:with-param name="notationType">HS6</xsl:with-param>
          <xsl:with-param name="parent"><xsl:choose>
            <xsl:when test="'0000' = substring($code, 5)"><xsl:value-of select="concat('#hs2_', substring($code, 1, 2))"/></xsl:when>
            <xsl:when test="'00' = substring($code, 7)"><xsl:value-of select="concat('#hs4_', substring($code, 1, 4))"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="concat('#hs6_', substring($code, 1, 6))"/></xsl:otherwise>
          </xsl:choose></xsl:with-param>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="concept">
    <xsl:param name="ID" />
    <xsl:param name="label" />
    <xsl:param name="parent" />
    <xsl:param name="notation" />
    <xsl:param name="notationType" />
    <skos:Concept rdf:ID="{$ID}">
      <rdfs:label xml:lang="en"><xsl:value-of select="$label"/></rdfs:label>
      <skos:inScheme rdf:resource=""/>
      <skos:notation rdf:datatype="https://trade.ec.europa.eu/def/cn#{$notationType}"><xsl:value-of select="$notation"/></skos:notation>
      <xsl:choose>
        <xsl:when test="$parent != ''">
          <skos:broader rdf:resource="{$parent}"/>
        </xsl:when>
        <xsl:otherwise>
          <skos:topConceptOf rdf:resource=""/>
        </xsl:otherwise>
      </xsl:choose>
    </skos:Concept>
  </xsl:template>

</xsl:stylesheet>
