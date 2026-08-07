<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:assc="https://www.daliboris.cz/ns/xslt/assc">
   <xd:doc scope="stylesheet">
      <xd:desc>
         <xd:p>
            <xd:b>Created on:</xd:b> 2026-04-25</xd:p>
         <xd:p>
            <xd:b>Author:</xd:b> Boris</xd:p>
         <xd:p/>
      </xd:desc>
   </xd:doc>
   <xsl:import href="common/_assc-functions.xsl"/>
   <xsl:param name="converters"
              select="doc('common/conversion-data.xml')"/>
   <xsl:mode on-no-match="shallow-copy"/>
   <xsl:key name="grammar"
            match="grammar"
            use="@text"/>
   <xsl:output method="xml"
               indent="yes"/>
   <xsl:template match="uts"/>
   <xsl:template match="state"/>
   <xsl:template match="variant">
      <entry>
         <!-- TODO: cdo-link[1] /kvůli 42532: demonstrující 2  -->
         <parent_id>
            <xsl:copy select="ancestor::lemma/links/cdo-link[1]/link-main-hid/text()"/>
         </parent_id>
         <entry_id>
            <xsl:value-of select="ancestor::lemma/@id"/>
         </entry_id>
         <xsl:apply-templates/>
         <!-- TODO: pokud varianta obsahuje jenom tvar, dohledat další parametry u předchozího?
    vit id 396: barevní
   -->
         <changed>
            <xsl:value-of select="ancestor::lemma/uts"/>
         </changed>
         <state>
            <xsl:value-of select="ancestor::lemma/state"/>
         </state>
      </entry>
   </xsl:template>
   <xsl:template match="cdo-link[link-slave-hid]">
      <entry>
         <parent_id>
            <xsl:value-of select="ancestor::lemma/@id"/>
         </parent_id>
         <entry_id>
            <xsl:value-of select="link-slave-hid"/>
         </entry_id>
         <variant>
            <xsl:value-of select="link-slave-str"/>
         </variant>
         <homonymy/>
         <lemma_type/>
         <pos/>
         <gender/>
         <aspect/>
         <uninflected/>
         <plurality/>
         <changed>
            <xsl:value-of select="ancestor::lemma/uts"/>
         </changed>
         <state>
            <xsl:value-of select="ancestor::lemma/state"/>
         </state>
      </entry>
   </xsl:template>
   <xsl:template match="cdo-link[link-main-hid]"/>
   <xsl:template match="lemma">
      <entries>
         <xsl:apply-templates/>
      </entries>
   </xsl:template>
   <xsl:template match="variants | links">
      <xsl:apply-templates/>
   </xsl:template>
   <!-- TODO: opravdu generovat *bláha? -->
   <xsl:template match="comment-before"/>
   <xsl:template match="lemma-variant">
      <variant>
         <xsl:if test="following-sibling::comment-before[. = '*']">
            <xsl:text>*</xsl:text>
         </xsl:if>
         <xsl:apply-templates/>
      </variant>
      <xsl:if test="not(parent::*[parts-of-speech])">
         <pos/>
         <gender/>
         <aspect/>
      </xsl:if>
      <xsl:if test="not(parent::*[gram-info])">
         <plurality/>
      </xsl:if>
      <xsl:if test="not(parent::*[morph-chars])">
         <uninflected/>
      </xsl:if>
   </xsl:template>
   <xsl:template match="lemma-type">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="homonymie">
      <homonymy>
         <xsl:apply-templates/>
      </homonymy>
   </xsl:template>
   <xsl:template match="lemma-type[not(*)][parent::variant[type = '0']]"
                 priority="2">
      <xsl:apply-templates select="../preceding-sibling::variant[type = '1'][1]/lemma-type"/>
   </xsl:template>
   <xsl:template match="lemma-type[not(*)]">
      <xsl:copy-of select="."/>
   </xsl:template>
   <xsl:template match="lemma-type/choice">
      <lemma_type>
         <xsl:apply-templates/>
      </lemma_type>
   </xsl:template>
   <xsl:template match="parts-of-speech"
                 use-when="false()">
      <xsl:variable name="items"
                    select="part-of-speech/choices/choice"/>
      <xsl:for-each select="('pos', 'gender', 'aspect')">
         <xsl:variable name="type"
                       select="."/>
         <xsl:variable name="values"
                       select="assc:get-converted-values($items, $type, $converters/data)"
                       as="xs:string*"/>
         <xsl:call-template name="convert-element">
            <xsl:with-param name="values"
                            select="$values"/>
            <xsl:with-param name="element-name"
                            select="$type"/>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="parts-of-speech">
      <xsl:variable name="items">
         <xsl:choose>
            <xsl:when test="self::parts-of-speech[not(*)][parent::variant[type = '0']]">
               <xsl:copy-of select="../preceding-sibling::variant[type = '1'][1]/parts-of-speech/part-of-speech/choices/choice"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="part-of-speech/choices/choice"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!--  <xsl:variable name="items" select="part-of-speech/choices/choice"/>-->
      <xsl:for-each select="('pos', 'gender', 'aspect')">
         <xsl:variable name="type"
                       select="."/>
         <xsl:variable name="grammar"
                       select="key('grammar', $items, $converters/data)"/>
         <xsl:element name="{$type}">
            <xsl:value-of select="$grammar/@*[name() = $type]"/>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="gram-info">
      <plurality>
         <xsl:value-of select="choice"/>
      </plurality>
   </xsl:template>
   <xsl:template match="morph-chars">
      <uninflected>
         <xsl:value-of select="morph-char/choices/choice"/>
      </uninflected>
   </xsl:template>
   <xsl:template name="convert-element">
      <xsl:param name="values"
                 as="xs:string*"/>
      <xsl:param name="element-name"
                 as="xs:string"/>
      <xsl:element name="{$element-name}">
         <xsl:if test="exists($values)">
            <xsl:value-of select="string-join($values)"/>
         </xsl:if>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>