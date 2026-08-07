<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs math xd"
                version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> Jul 14, 2026</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> Boris</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:param name="entry-elements-count"
              as="xs:integer"
              select="14"/>
   <xsl:mode on-no-match="shallow-copy"/>
   <xsl:strip-space elements="*"/>
   <xsl:output indent="yes"/>
   <xsl:template match="entry[count(*) ne $entry-elements-count]"
                 priority="2"/>
   <xsl:template match="entry[variant[not(node())]]"
                 priority="3"/>
   <xsl:template match="entry[pos[. = '-'] and gender[. = '-'] and aspect[. = '-'] ]"/>
</xsl:stylesheet>