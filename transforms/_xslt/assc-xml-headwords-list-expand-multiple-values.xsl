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
   <xsl:mode on-no-match="shallow-copy"/>
   <xsl:output method="xml"
               indent="yes"/>
   <xsl:template match="entry[*[contains(., ',')]]">
      <xsl:variable name="root"
                    select="."/>
      <xsl:variable name="grammar"
                    select="*[contains(., ',')]"/>
      <xsl:for-each select="$grammar">
         <xsl:variable name="values"
                       select="tokenize(., '[,\s]')[.]"/>
         <xsl:for-each select="$values">
            <xsl:variable name="value"
                          select="."/>
            <xsl:element name="{name($root)}">
               <xsl:copy-of select="$root/@*"/>
               <xsl:for-each select="$root/*">
                  <xsl:choose>
                     <xsl:when test=". = $grammar">
                        <xsl:element name="{name($grammar)}">
                           <xsl:value-of select="$value"/>
                        </xsl:element>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:copy-of select="."/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>