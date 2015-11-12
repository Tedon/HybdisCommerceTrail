<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="template" tagdir="/WEB-INF/tags/desktop/template" %>
<%@ taglib prefix="cms" uri="http://hybris.com/tld/cmstags" %>
<%@ taglib prefix="breadcrumb" tagdir="/WEB-INF/tags/desktop/nav/breadcrumb" %>

<template:page pageTitle="${pageTitle}">
    <breadcrumb:breadcrumb breadcrumbs="${breadcrumbs}" />
    <cms:pageSlot var="feature" position="Section1">
        <div class="span-24 section1 advert">
        text111
            <cms:component component="${feature}"/>
        </div>
    </cms:pageSlot>
    <div class="span-20 section2 advert">
        <cms:pageSlot var="feature" position="Section2">
        text222
            <cms:component component="${feature}"/>
        </cms:pageSlot>
    </div>
    <div class="span-4 section3 advert">
        <cms:pageSlot var="feature" position="Section3">
        text333
            <cms:component component="${feature}"/>
        </cms:pageSlot>
    </div>
    <div class="span-4 linksection advert last">
        <cms:pageSlot var="feature" position="LinkSection">
        text444
            <cms:component component="${feature}"/>
        </cms:pageSlot>
    </div>
</template:page>
