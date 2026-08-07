<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:map="http://www.w3.org/2005/xpath-functions/map" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
 xmlns:assc="https://www.daliboris.cz/ns/xslt/assc"
 exclude-result-prefixes="#all"
 version="3.0">
 
 <xsl:function name="assc:get-converted-values" as="xs:string*">
  <xsl:param name="text" as="item()*" />
  <xsl:param name="type" as="xs:string" />
  <xsl:param name="data" as="element(data)" />
  
  <xsl:variable name="type-fix" select="$type || '-fix'"/>
  <xsl:variable name="fix-exists" select="exists($data/items[@type=$type-fix])"/>
  
  <xsl:variable name="tokens" select="string-join($text, ' ')  => tokenize() => distinct-values()" />
  <xsl:variable name="items" select="$data/items[@type=$type]/item" />
  <xsl:variable name="keywords" select="$items[@key = $tokens]" />
  <xsl:variable name="keywords-fixed" select="if($fix-exists) 
   then assc:get-converted-values(string-join($keywords/@value), $type-fix, $data) 
   else $keywords" />
  
  <xsl:copy-of select="if($fix-exists and exists($keywords-fixed)) 
   then
   $keywords-fixed
    else $keywords/@value
   " />
  
 </xsl:function>
</xsl:stylesheet>