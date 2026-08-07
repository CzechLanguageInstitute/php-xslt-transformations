<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:math="http://www.w3.org/2005/xpath-functions/math"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 exclude-result-prefixes="#all"
 version="3.0">
 <xd:doc scope="stylesheet">
  <xd:desc>
   <xd:p><xd:b>Created on:</xd:b> Jul 14, 2026</xd:p>
   <xd:p><xd:b>Author:</xd:b> Boris</xd:p>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
 
 <xsl:param name="new-line" as="xs:string" select="'&#xd;&#xa;'" />
 <xsl:param name="separator" as="xs:string" select="'&#x9;'" />
 <xsl:output method="text" />
 <xsl:mode on-no-match="shallow-skip"/>
 <xsl:strip-space elements="*"/>
 
 <xsl:template match="entries | /dictionary[not(entries)]">
  <xsl:apply-templates select="*[1]" mode="head" />
  <xsl:apply-templates select="*" />
 </xsl:template>
 
 <xsl:template match="entry" mode="#all">
  <xsl:apply-templates mode="#current" /><xsl:value-of select="$new-line"/>
 </xsl:template>
 
 <xsl:template match="entry/*" mode="head">
  <xsl:value-of select="name(.)"/><xsl:if test="position() != last()"><xsl:value-of select="$separator"/></xsl:if>
 </xsl:template>
 
 <xsl:template match="entry/*">
  <xsl:value-of select="."/><xsl:if test="position() != last()"><xsl:value-of select="$separator"/></xsl:if>
 </xsl:template>
 
</xsl:stylesheet>