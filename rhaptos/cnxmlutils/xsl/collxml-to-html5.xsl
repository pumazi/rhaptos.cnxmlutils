<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"
  
  xmlns:data="http://dev.w3.org/html5/spec/#custom"
  >

<xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

<xsl:include href="cnxml-to-html5.xsl"/>


<xsl:template match="col:*/@*">
	<xsl:copy/>
</xsl:template>

<xsl:template match="col:collection">
	<xsl:variable name="url">
		<xsl:value-of select="col:metadata/md:content-url/text()"/>
	</xsl:variable>
	<xsl:variable name="id">
		<xsl:value-of select="col:metadata/md:content-id/text()"/>
	</xsl:variable>
	<body class="book" data-url="{col:metadata/md:content-url/text()}" data-id="{col:metadata/md:content-id/text()}" data-repository="{col:metadata/md:repository/text()}">
		<xsl:apply-templates select="@*|node()"/>
	</body>
</xsl:template>


<!--adding units as subcollection-->

<xsl:template match="col:collection/col:content/col:subcollection[col:content/col:subcollection]">
  <section class="part">
    <xsl:apply-templates select="node()"/> <!-- this wil match cnx:title and col:subcollection -->
  </section>
</xsl:template>
  
  
  

<!-- end of test TOC -->


<!-- Modules before the first subcollection are preface frontmatter -->
<xsl:template match="col:collection/col:content[col:subcollection and col:module]/col:module[not(preceding-sibling::col:subcollection)]" priority="100">
	<section class="preface">
		<xsl:apply-templates select="@*|node()"/>
		<xsl:call-template name="cnx.xinclude.module"/>
	</section>
</xsl:template>

<!-- Modules after the last subcollection are appendices -->
<xsl:template match="col:collection/col:content[col:subcollection and col:module]/col:module[not(following-sibling::col:subcollection)]" priority="100">
  <section class="appendix">
		<xsl:apply-templates select="@*|node()"/>
		<xsl:call-template name="cnx.xinclude.module"/>
  </section>
</xsl:template>


<!-- Free-floating Modules in a col:collection should be treated as Chapters -->
<xsl:template match="col:collection/col:content/col:subcollection/col:module"> 
  <section class="chapter">
		<xsl:apply-templates select="@*|node()"/>
		<xsl:call-template name="cnx.xinclude.module"/>
	</section>
</xsl:template>

<xsl:template match="col:collection/col:content/col:subcollection[not(col:content/col:subcollection)]">
	<section class="chapter">
		<xsl:apply-templates select="@*|node()"/>
	</section>
</xsl:template>  

<xsl:template match="col:collection/col:content/col:subcollection/col:content/col:subcollection" priority="10">
  <section class="chapter">
    <xsl:apply-templates select="@*|node()"/>
  </section>
</xsl:template>

<xsl:template match="col:collection/col:content[not(col:subcollection)]/col:module">
  <section class="chapter">
    <xsl:apply-templates select="@*|node()"/>
		<xsl:call-template name="cnx.xinclude.module"/>
  </section>
</xsl:template>


<!-- Subcollections in a chapter should be treated as a section -->
<xsl:template match="col:subcollection/col:content/col:subcollection">
	<section><xsl:apply-templates select="@*|node()"/></section>
</xsl:template>

<xsl:template match="col:content">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="col:module">
  <section>
    <xsl:apply-templates select="@*|node()"/>
    <xsl:call-template name="cnx.xinclude.module"/>
  </section>
</xsl:template>


<xsl:template match="@id|@xml:id|comment()|processing-instruction()">
  <xsl:copy/>
</xsl:template>

<xsl:template name="cnx.xinclude.module">
  <a class="xinclude" href="{@repository}/{@document}/{@version}">
    <xsl:choose>
      <xsl:when test="md:title">
        <xsl:attribute name="class">
          <xsl:text>override</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="md:title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[xinclude]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </a>
</xsl:template>


</xsl:stylesheet>
