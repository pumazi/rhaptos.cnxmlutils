<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns="http://cnx.rice.edu/cnxml"
  
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" 
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"

  version="1.0">

<!-- Returns the color of a given style -->
<xsl:key name="color" match="//style:style/style:text-properties/@fo:color" use="../../@style:name"/>

<xsl:output encoding="ASCII"/>

<xsl:template match="*[text() and '#ff0000' = key('color', @text:style-name)]">
  <xsl:choose>
    <xsl:when test="count(node()) = 1 and 1 = count(text()) and string-length(normalize-space(text())) = 0">
      <xsl:message>DEBUG: Silently ignoring red text with nothing in it</xsl:message>
    </xsl:when>
    <xsl:when test="*[not(self::text:s or self::text:soft-page-break or self::text:tab)]">
      <xsl:message>ERROR: RED text is reserved for XML snippets. This text has other things inside it like <xsl:for-each select="*"><xsl:value-of select="name()"/><xsl:text> </xsl:text></xsl:for-each></xsl:message>
    </xsl:when>
    <xsl:when test="not(starts-with(normalize-space(text()), '&lt;'))">
      <xsl:message>WARNING: RED text is reserved for XML snippets. Text: [<xsl:value-of select="substring(normalize-space(text()),1,40)"/>]</xsl:message>
    </xsl:when>
  </xsl:choose>

  <xsl:comment>CNX: Start RED escaped text from import</xsl:comment>
  <!-- Convert "pretty" apostrophes and quotes to simple ones -->
  <xsl:value-of select="translate(., &quot;&#8221;&#8217;&quot;, &quot;&apos;&apos;&quot;)" disable-output-escaping="yes"/>
  <xsl:comment>CNX: End RED escaped text from import</xsl:comment>
</xsl:template>



<!-- Unwrap elements that only contain red text (like a para, or a span around the red text span) -->
<xsl:template match="*[count(*) &gt;= 1 and count(*) = count(*['#ff0000' = key('color', @text:style-name)]) and normalize-space(text()) = '']">
  <xsl:message>DEBUG: Wrapper element around element with just red XML text: <xsl:value-of select="name()"/></xsl:message>
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>