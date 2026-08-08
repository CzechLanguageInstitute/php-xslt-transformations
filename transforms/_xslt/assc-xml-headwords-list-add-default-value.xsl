<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
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
   <xsl:mode on-no-match="shallow-copy"/>
   <xsl:strip-space elements="*"/>
   <xsl:output indent="yes"/>
   <xsl:template match="pos[not(node())] | gender[not(node())] | aspect[not(node())]">
      <xsl:copy>
         <xsl:value-of select="'-'"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="homonymy[not(node())]">
      <xsl:copy>
         <xsl:value-of select="'0'"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>