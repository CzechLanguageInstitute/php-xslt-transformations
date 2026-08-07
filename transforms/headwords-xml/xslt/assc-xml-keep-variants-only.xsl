<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 xmlns:f="#function"
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
 
 <xsl:template match="uts" mode="#all">
  <xsl:copy-of select="." />
 </xsl:template>
 
 <xsl:template match="variants"  mode="#all">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:apply-templates mode="#current" />
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="variant" mode="#all">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:apply-templates mode="variant" use-when="false()" />
   <xsl:copy-of select="f:copy-or-add(type, 'type')" />
   <xsl:copy-of select="f:copy-or-add(sort-order, 'sort-order')" />
   <xsl:copy-of select="f:copy-or-add(lemma-variant, 'lemma-variant')" />
   <xsl:copy-of select="f:copy-or-add(lemma-type, 'lemma-type')" />
   <xsl:copy-of select="f:copy-or-add(homonymie, 'homonymie')" />
   <xsl:copy-of select="f:copy-or-add(parts-of-speech, 'parts-of-speech')" />
   <!-- pokud najdeš někde "neskl.", považuj to jen za "neskl." a za nic jiného; viz např. 26777: adverbiale -->
   <xsl:copy-of select="f:copy-or-add(morph-chars[morph-char/choices/choice[@id = ('15')]]/morph-char[choices/choice[@id = ('15')]], 'morph-chars')" />
   <xsl:copy-of select="f:copy-or-add(gram-info[choice/@id=('1', '2', '12', '100')], 'gram-info')" />
  </xsl:copy>
 </xsl:template>
 
 <xsl:template name="skeleton">
    
 </xsl:template>
 
 <xsl:function name="f:copy-or-add">
  <xsl:param name="element" as="element()?" />
  <xsl:param name="element-name" as="xs:string" />
  
  <xsl:choose>
   <xsl:when test="exists($element) and name($element) != $element-name">
    <xsl:element name="{$element-name}">
     <xsl:copy-of select="$element" />
    </xsl:element>
   </xsl:when>
   <xsl:when test="exists($element)">
    <xsl:copy-of select="$element" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:element name="{$element-name}" />
   </xsl:otherwise>
  </xsl:choose>
  
 </xsl:function>
 
 <!-- morph-chars/morph-char/choices/choice[@id = ('15')] = meskl. -->
 <!-- gram-info/choice[@id=('1', '2', '12', '100')] = zprav. množné, množné, pomnožné, jen množné -->
 <xsl:template match="lemma-variant | lemma-type | type | homonymie | parts-of-speech | comment-before | sort-order |
   gram-info[choice/@id=('1', '2', '12', '100')] " mode="variant">
  <xsl:copy-of select="." />
 </xsl:template>
 
 <!-- pokud najdeš někde "neskl.", považuj to jen za "neskl." a za nic jiného; viz např. 26777: adverbiale  -->
 <xsl:template match="morph-chars[morph-char/choices/choice[@id = ('15')]]" mode="variant">
  <xsl:copy-of select="f:copy-or-add(morph-chars[morph-char/choices/choice[@id = ('15')]]/morph-char[choices/choice[@id = ('15')]], 'morph-chars')" />
 </xsl:template>
 
 <xsl:template match="links[cdo-link/link-rel-type/@id='3']" mode="#all">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:apply-templates select="link-main-hid | cdo-link[link-rel-type/@id='3']" mode="link" />
  </xsl:copy>
 </xsl:template>
 
 <xsl:template match="cdo-link[main-places/main-place/place-id[. = '0']]" priority="2" mode="#all" />
 
 <xsl:template match="cdo-link" mode="link">
  <xsl:copy>
   <xsl:copy-of select="@*" />
   <xsl:apply-templates mode="#current" />
   
  </xsl:copy>
 </xsl:template>
 <xsl:template match="link-main-hid | link-slave-hid | link-rel-type | link-slave-str" mode="link">
  <xsl:copy-of select="." />
 </xsl:template>
 
</xsl:stylesheet>