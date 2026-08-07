<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:math="http://www.w3.org/2005/xpath-functions/math"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 exclude-result-prefixes="xs math xd"
 version="3.0">
 <xd:doc scope="stylesheet">
  <xd:desc>
   <xd:p><xd:b>Created on:</xd:b> Jul 14, 2026</xd:p>
   <xd:p><xd:b>Author:</xd:b> Boris</xd:p>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
 
 <xsl:param name="entry-elements-count" as="xs:integer" select="13" />
 <xsl:mode on-no-match="shallow-copy"/>
 
 <xsl:template match="entry[count(*) ne $entry-elements-count]" />
 
 <xsl:template match="entry[variant[not(node())]]" />
 
 <xsl:template match="entry[pos[. = '-'] and gender[. = '-'] and aspect[. = '-'] ]" />
 
</xsl:stylesheet>