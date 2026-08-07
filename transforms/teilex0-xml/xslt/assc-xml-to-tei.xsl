<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:math="http://www.w3.org/2005/xpath-functions/math"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 xmlns:tei="http://www.tei-c.org/ns/1.0"
 xmlns="http://www.tei-c.org/ns/1.0"
 xmlns:assc="https://www.daliboris.cz/ns/xslt/assc"
 exclude-result-prefixes="#all" version="3.0"
 xmlns:fn="http://www.example.com/fn">

 <xd:doc scope="stylesheet">
  <xd:desc>
   <xd:p><xd:b>Created on:</xd:b> Apr 20, 2026</xd:p>
   <xd:p><xd:b>Author:</xd:b> Boris</xd:p>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
 
 <xsl:import href="../../common/_string-variables.xsl"  use-when="false()"/>
 <xsl:import href="../common/_string-variables.xsl" use-when="false()"/>
 <xsl:param name="dictionaty-abbr" select="'ASSC'" />
 
 <xsl:mode on-no-match="shallow-skip" name="change"/>
 
 <xsl:variable name="values" select="map {'lemma' :
   map { 'variant' :
    map {'type' : map {'1' : 'lemma', '0' : 'inflected' } }} }"/>
 
 <xsl:strip-space elements="*"/>
 <xsl:output method="xml" indent="yes"/>
 <xsl:mode on-no-match="shallow-copy"/>
 <xsl:mode on-no-match="shallow-skip" name="attributes"/>
 <xsl:mode on-no-match="shallow-copy" name="attestation-delimiters"/>

 <xsl:template match="/">
  <TEI xmlns="http://www.tei-c.org/ns/1.0" type="lex-0">
   <xsl:call-template name="teiHeader"/>
   <text>
    <body>
     <div>
      <xsl:apply-templates/>
     </div>
    </body>
   </text>
  </TEI>
 </xsl:template>
 
 <xsl:template name="teiHeader">
  <xsl:copy-of select="doc('./common/assc.teiHeader.xml')/tei:TEI/tei:teiHeader" />
 </xsl:template>
 
 <xsl:template match="lemma">
  <xsl:variable name="entry-id" select="assc:get-entry-id(.)"/>
  <xsl:variable name="main-entry-id" select="substring-before($entry-id, '.hom-')"/>
  <xsl:choose>
   <xsl:when test="exists(variants/variant/homonymie)">
    <entry type="mainEntry" xml:lang="cs" xml:id="{$main-entry-id}">
     <entry type="homonymicEntry" xml:lang="cs" xml:id="{$entry-id}">
      <xsl:apply-templates />
     </entry>
    </entry>
   </xsl:when>
   <xsl:otherwise>
    <entry type="mainEntry" xml:lang="cs" xml:id="{$entry-id}">
     <xsl:apply-templates select="uts" mode="change" />
     <xsl:apply-templates />
    </entry>    
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 
 <xsl:template match="uts" mode="change">
  <xsl:attribute name="change">
   <xsl:value-of select="'#' || assc:get-change-id(.)"/>
  </xsl:attribute>
 </xsl:template>

 <!-- <uts>2020-09-17T12:18:19</uts> -->
 <xsl:template match="uts" />
 
 <xsl:template match="variants">
  <xsl:apply-templates />
 </xsl:template>
 
 <xsl:template match="variant">
  <form>
   <xsl:apply-templates select="type, lemma-type" mode="attributes" />
   <xsl:apply-templates select="* except(type, lemma-type)" />
  </form>
 </xsl:template>
 
 <xsl:template match="variant/type" mode="attributes">
  <xsl:attribute name="type" select="$values?lemma?variant?type?(.)" />
 </xsl:template>
 
 <xsl:template match="variant/lemma-type/choice" mode="attributes">
  <xsl:attribute name="valueDatcat" select="concat('#lemma-type.',@id)" />
 </xsl:template>
 
 <xsl:template match="sort-order" />
 
 <xsl:template match="lemma-variant">
  <orth><xsl:apply-templates /></orth>
 </xsl:template>
 
 <xsl:template match="variant/homonymie">
  <lbl type="homonymyNumber"><xsl:apply-templates /></lbl>
 </xsl:template>
 
 <xsl:template match="variant/comment-after">
  <lbl type="phrase"><xsl:apply-templates /></lbl>
 </xsl:template>
 
 <xsl:template match="variant/comment-before">
  <lbl type="usage"><xsl:apply-templates /></lbl>
 </xsl:template>
 
 <xsl:template match="pronunciations | pronunciations/expression">
  <xsl:apply-templates />
 </xsl:template>
 
 <xsl:template match="pronunciations/expression/text">
  <pron notation="ipa"><xsl:apply-templates /></pron>
 </xsl:template>
 
 <xsl:template match="expression/comment[not(node())]" />
 
 <xsl:template match="expression/comment[node()]">
  <note><xsl:apply-templates /></note>
 </xsl:template>
 
 <xsl:template match="parts-of-speech[part-of-speech[not(node())]]" />
 
 <xsl:template match="parts-of-speech">
  <gramGrp>
   <xsl:apply-templates />
  </gramGrp>
 </xsl:template>
 
 <xsl:template match="part-of-speech | part-of-speech/choices">
  <xsl:apply-templates />
 </xsl:template>
 <xsl:template match="part-of-speech/choices/choice">
  <gram type="pos">
   <xsl:apply-templates select="." mode="attributes" />
   <xsl:apply-templates />
  </gram>
 </xsl:template>
 
 <xsl:template match="part-of-speech/choices/choice" mode="attributes">
  <xsl:attribute name="valueDatcat" select="concat('#part-of-speech.',@id)" />
 </xsl:template>
 

 <xsl:template match="homonymie[not(node())]" />
 
 <xsl:template match="audio[published = '0']" />
 <xsl:template match="audio[published = '1']">
  <ref type="pronounciation">
   <xsl:apply-templates />
  </ref>
 </xsl:template>
 <xsl:template match="audio/filename">
  <xsl:attribute name="target" select="." />
  <xsl:attribute name="mimeType" select="'audio/' || substring-after(., '.')" />
 </xsl:template>
 <xsl:template match="audio/published" />
 
 
 <xsl:template match="morph-chars">
 <xsl:apply-templates />
 </xsl:template>
 
 <xsl:template match="morph-char">
  <form type="inflected">
   <xsl:apply-templates />
  </form>
 </xsl:template>
 
 <xsl:template match="morph-char/choices">
  <gramGrp>
   <xsl:apply-templates />
  </gramGrp>
 </xsl:template>
 
 <!-- TODO: rozdělit na jednotlivé kategorie -->
 <xsl:template match="morph-char/choices/choice">
  <gram type="case">
   <xsl:attribute name="valueDatcat" select="concat('case.',@id)" />
   <xsl:apply-templates />
  </gram>
 </xsl:template>

 <xsl:template match="morph-char/suffixes | morph-char/suffixes/expression">
  <xsl:apply-templates />
 </xsl:template>

 <xsl:template match="morph-char/suffixes/expression/text">
  <orth extent="suffix">
   <xsl:apply-templates /> 
  </orth>
 </xsl:template>
 
 <xsl:template match="styl-qualifier">
  <xsl:apply-templates />
 </xsl:template>
 <xsl:template match="styl-qualifier/choice">
  <usg type="socioCultural">
   <xsl:attribute name="valueDatcat" select="concat('style.',@id)" />
   <xsl:apply-templates />
  </usg>
 </xsl:template>

 <xsl:template match="variant/gram-info">
  <xsl:apply-templates />
 </xsl:template>
 <xsl:template match="variant/gram-info/choice">
  <lbl type="grammar"><xsl:apply-templates /></lbl>
 </xsl:template>

 <xsl:template match="variant/origin">
  <!--<etym><xsl:apply-templates /></etym>-->
  <cit type="etymon"><xsl:apply-templates /></cit>
 </xsl:template>
 
 <xsl:template match="variant/origin/choice[not(matches(., '(ze?)\s(.*)'))]">
  <seg><xsl:apply-templates /></seg>
 </xsl:template>
 
 <xsl:template match="variant/origin/choice[matches(., '(ze?)\s(.*)')]">
  <lbl><xsl:value-of select="substring-before(., ' ')"/></lbl>
  <lang><xsl:value-of select="substring-after(., ' ')"/></lang>
 </xsl:template>


 <!-- TODO: přesunout k následujícímu <xref> -->
 <xsl:template match="lemma/origin">
  <xsl:apply-templates />
 </xsl:template>
 <xsl:template match="lemma/origin/choice">
  <lbl type="origin"><xsl:apply-templates /></lbl>
 </xsl:template>

 
 <xsl:template match="meanings">
  <xsl:apply-templates />
 </xsl:template>

 <xsl:template match="meaning">
  <xsl:variable name="entry-id" select="assc:get-entry-id(ancestor::lemma)"/>
  <xsl:variable name="number" select="sort-order"/>
  <sense xml:id="{$entry-id}.sense-{$number}">
   <xsl:apply-templates />
  </sense>
 </xsl:template>
 <xsl:template match="meaning/sort-order">
  <num><xsl:apply-templates /></num>
 </xsl:template>
 
 <!-- TODO: jak se to liší od field-of-use? -->
 <xsl:template match="them-area">
  <xsl:apply-templates />
 </xsl:template>
 
 <xsl:template match="them-area/choice">
  <usg type="domain">
   <xsl:attribute name="valueDatcat" select="concat('#them-area.',@id)" />
   <xsl:apply-templates />
  </usg>
 </xsl:template>
 
 <xsl:template match="field-of-use">
   <xsl:apply-templates />
 </xsl:template>
 
 <xsl:template match="field-of-use/choice">
  <usg type="domain">
   <xsl:attribute name="valueDatcat" select="concat('#field-of-use.',@id)" />
   <xsl:apply-templates />
  </usg>
 </xsl:template>
 
 <xsl:template match="meaning-text" />
 
 <xsl:template match="meaning-text-html[not(contains(., '&lt;'))]">
  <xsl:variable name="cdata" select="assc:fix-cdata-for-xml(.)"/>
  <xsl:variable name="xml" select="parse-xml($cdata)"/>
  <def><xsl:apply-templates select="$xml" /></def>  
 </xsl:template>
 
 <xsl:template match="meaning-text-html">
  <xsl:variable name="cdata" select="assc:fix-cdata-for-xml(.)"/>
  <xsl:variable name="xml" select="parse-xml($cdata)"/>
  <xsl:apply-templates select="$xml" mode="meaning"  /> 
 </xsl:template>
 
 <xsl:template match="p" mode="meaning">
  <def><xsl:apply-templates mode="#current" /></def>
 </xsl:template>
 
  <xsl:template match="p/text()[contains(., ';')]" mode="meaning">
   <xsl:value-of select="replace(., '; ', ' • ')"/>
  </xsl:template>
 
 <xsl:template match="span[@id]" mode="meaning">
  <xsl:variable name="type" select="if(matches(., '\d')) then 'sense' else 'lemma'"/>
  <!-- TODO xr/type -->
  <xr type="related"><ref  type="{$type}" target="{@id}"><xsl:apply-templates /></ref></xr>
 </xsl:template>
 
 <xsl:template match="links">
  <xsl:apply-templates />
 </xsl:template>
 
 <xsl:template match="cdo-link[link-slave-str[not(node())]]" />
 
 <xsl:template match="cdo-link[link-slave-str[node()]]">
  <!-- TODO: @type -->
  <xr type="related">
   <xsl:if test="link-rel-type/@id != ('2')">
    <xsl:apply-templates select="(link-types/link-type|main-places/main-place)[1]" mode="label" /> 
   </xsl:if>
   <xsl:variable name="target" select="slave-places/slave-place/place-id"/>
   <xsl:variable name="target-lemma" select="assc:get-lemma-for-id(link-slave-str)"/>
   <!-- TODO: @type -->
   <ref type="entry" target="#assc.{$target-lemma}.id-{$target}"><xsl:apply-templates /></ref>
  </xr>
 </xsl:template>
 
 <xsl:template match="cdo-link/note">
  <note><xsl:apply-templates /></note>
 </xsl:template>
 
 <!-- TODO -->
 <xsl:template match="link-types" />
 <xsl:template match="link-display-txt" />
 <xsl:template match="link-types" mode="label">
  <xsl:apply-templates />
 </xsl:template>
 <xsl:template match="link-types/link-type/type" mode="label">
  <lbl><xsl:apply-templates /></lbl>
 </xsl:template>
 
 <!-- TODO -->
 <xsl:template match="main-places">
  <xsl:apply-templates />
 </xsl:template>
 <xsl:template match="main-places/main-place" />
 <xsl:template match="main-places/slave-place" />
 <xsl:template match="place-id" mode="#all" />
 <xsl:template match="link-slave-hid" />
 <xsl:template match="slave-places" />
 <xsl:template match="link-rel-type" />
 
 <xsl:template match="link-slave-str">
  <xsl:apply-templates />
 </xsl:template>
 
 
 
 <xsl:template match="main-places/main-place/place" mode="label">
  <lbl><xsl:apply-templates /><xsl:text>.</xsl:text></lbl>
 </xsl:template>
 
 <xsl:template match="exemplifications | exemplification">
  <xsl:apply-templates />
 </xsl:template>
 
 <xsl:template match="exemplification-text" />
 <xsl:template match="exemplification-text-html[string-length(.) eq 0]" />
 
 <xsl:template match="exemplification-text-html[string-length(.) gt 1]">
  <xsl:variable name="text" select="assc:fix-cdata-for-xml(.)"/>
  <xsl:variable name="xml" select="parse-xml($text)"/>
  <xsl:variable name="xml">
   <xsl:apply-templates select="$xml" mode="attestation-delimiters" />
  </xsl:variable>
  <xsl:apply-templates select="$xml/*" mode="attestation"  />
 </xsl:template>
 
 <xsl:template match="div//*[text()[normalize-space(.) = ';']]" priority="5" mode="attestation-delimiters">
  <delim><xsl:value-of select="."></xsl:value-of> </delim>
 </xsl:template>
 
 <xsl:template match="div//*[text()[contains(., ';')]]" priority="2"  mode="attestation-delimiters">
  <xsl:variable name="root" select="."/>
  
  <xsl:analyze-string select="." regex=";">
   <xsl:matching-substring>
    <delim>;</delim>
   </xsl:matching-substring>
   <xsl:non-matching-substring>
    <xsl:element name="{$root/name()}">
     <xsl:copy-of select="$root/@*" />
     <xsl:copy-of select="." /> 
    </xsl:element>
   </xsl:non-matching-substring>
  </xsl:analyze-string>
 </xsl:template>
 
 <xsl:template match="div//br" priority="2"  mode="attestation-delimiters">
  <delim>;</delim>
 </xsl:template>
 
 <xsl:template match="div//*" mode="attestation-delimiters">
  <xsl:apply-templates />
 </xsl:template>
 
 
 <xsl:template match="p[not(contains(., ';'))]" mode="attestation">
  <cit type="example">
   <quote><xsl:apply-templates /></quote>
  </cit>
 </xsl:template>

 <xsl:template match="p/em[not(contains(., ';'))]">
  <hi rend="em"><xsl:apply-templates  mode="#current"/></hi>
 </xsl:template>

 <xsl:template match="p/em[not(contains(., ';'))]" mode="attestation" >
  <hi rend="em"><xsl:apply-templates  mode="#current"/></hi>
 </xsl:template>
 
 <xsl:template match="em/text()[contains(., ';')] | /i/text()[contains(., ';')] | em/span/text()[contains(., ';')]" mode="attestation" priority="2">
  <xsl:variable name="items" as="xs:string*" select="tokenize(., ';')"/>
  <xsl:for-each select="$items">
   <cit type="example">
    <quote><hi rend="em"><xsl:value-of select="normalize-space(.)"/></hi></quote>
   </cit>
  </xsl:for-each>
 </xsl:template>
 
 <xsl:template match="ext-remarks">
  <xsl:apply-templates />
 </xsl:template>

 <xsl:template match="ext-remark">
  <xsl:variable name="type" select="type"/>
  <note type="{$type}"><xsl:apply-templates /></note>
 </xsl:template>
 
 <xsl:template match="ext-remark/remark" />
 <xsl:template match="ext-remark/type" />
 
 <xsl:template match="ext-remark/remark-html[string-length(.) gt 1]">
  <xsl:variable name="html" select="parse-xml(.)"/>
  <xsl:apply-templates select="$html/*" mode="note" />
 </xsl:template>
 
 <xsl:template match="p" mode="note">
  <xsl:apply-templates mode="#current" />
 </xsl:template>
 
 <!-- TODO: span/@? -->
 <xsl:template match="p/span" mode="note" priority="3">
  <hi rend="small"><xsl:apply-templates mode="#current" /></hi>
 </xsl:template>
 
 <xsl:template match="p/span/em" mode="note" priority="3">
  <quote rend="em"><xsl:apply-templates /></quote>
 </xsl:template>
 
 <xsl:template match="span[. = '']" mode="#all" priority="3" />
 
 <xsl:template match="span" mode="#all">
  <hi rend="smaller"><xsl:apply-templates /></hi>
 </xsl:template>
 
<!-- <xsl:template match="em" mode="#all">
  <hi rend="em"><xsl:apply-templates /></hi>
 </xsl:template>-->
 
 <xsl:template match="sup" mode="#all">
  <hi rend="sup"><xsl:apply-templates /></hi>
 </xsl:template>
 
 
 <xsl:template match="br" mode="#all" />


 <xsl:function name="assc:get-entry-id">
  <xsl:param name="root" as="element(lemma)" />
  <xsl:variable name="lemma" select="assc:get-lemma-for-id($root/variants/variant[1]/lemma-variant[1])"/>
  <xsl:variable name="hom" select="if(exists($root/variants/variant/homonymie)) then 'hom-' || $root/variants/variant/homonymie else ()"/>
  <xsl:value-of select="string-join(($dictionaty-abbr, $lemma, $hom, 'id-' || $root/@id), '.')"/>
 </xsl:function>

 <xsl:function name="assc:get-lemma-for-id">
  <xsl:param name="text" as="xs:string"/>
  <xsl:value-of select="translate($text, ' []./', '-') => replace('-+', '-')"/>
 </xsl:function>

 <xsl:function name="assc:fix-cdata-for-xml">
  <xsl:param name="text" as="xs:string"/>
  <xsl:variable name="result" select="replace($text, '&lt;br&gt;', '&lt;br /&gt;')"/>
<!--  <xsl:variable name="multiple-p" select="string-length(replace($result, '(&lt;p&gt;)', '$0')) gt string-length('&lt;p&gt;')"/>-->
<!--  <xsl:variable name="result" select="if($multiple-p) then '&lt;div&gt;' || $result || '&lt;/div&gt;' else $result"/>-->
  <xsl:variable name="result" select="'&lt;div&gt;' || $result || '&lt;/div&gt;'"/>
  <xsl:value-of select="$result"/>
 </xsl:function>
 
 <xsl:function name="assc:get-change-id">
  <xsl:param name="date-time" as="xs:string" />
  <xsl:sequence select="concat('change.', translate($date-time, ':', '-'))"/>
 </xsl:function>

</xsl:stylesheet>