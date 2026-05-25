<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 exclude-result-prefixes="#all"
 version="3.0">

 <xd:doc scope="stylesheet">
  <xd:desc>
   <xd:p><xd:b>Created on:</xd:b> 2026-04-24</xd:p>
   <xd:p><xd:b>Author:</xd:b> Boris</xd:p>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
 
 <xsl:output method="xml" indent="yes" />
 <xsl:mode on-no-match="shallow-skip"/>
 <xsl:mode on-no-match="shallow-skip" name="variant"/>
 <xsl:mode on-no-match="shallow-skip" name="link"/>
 
 <xsl:template match="lemmas">
  <dictionary>
   <xsl:apply-templates />
  </dictionary>
 </xsl:template>
 
 <xsl:template match="lemma">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:apply-templates />
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="variants | variant" mode="#all">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:apply-templates mode="variant" />
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="lemma-variant | lemma-type | homonymie | parts-of-speech | comment-before" mode="variant">
  <xsl:copy-of select="." />
 </xsl:template>
 
 <xsl:template match="links[cdo-link/link-rel-type/@id='3']" mode="#all">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:apply-templates select="cdo-link[link-rel-type/@id='3']" mode="link" />
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="cdo-link" mode="link">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:apply-templates mode="#current" />
   
  </xsl:copy>
 </xsl:template>
 <xsl:template match="link-slave-hid | link-rel-type | link-slave-str" mode="link">
  <xsl:copy-of select="." />
 </xsl:template>
 
</xsl:stylesheet>