<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="template" tagdir="/WEB-INF/tags/desktop/template" %>
<%@ taglib prefix="cms" uri="/cms2lib/cmstags/cmstags.tld" %>
<%@ taglib prefix="breadcrumb" tagdir="/WEB-INF/tags/desktop/nav/breadcrumb" %>
 
<template:page pageTitle="${pageTitle}">
    <breadcrumb:breadcrumb breadcrumbs="${breadcrumbs}" />
    <cms:slot var="feature" contentSlot="${slots.Section1}">
        <div class="span-24 section1 advert">
            <cms:component component="${feature}"/>
        </div>
    </cms:slot>
    <div class="span-20 section2 advert">
        <cms:slot var="feature" contentSlot="${slots.Section2}">
            <cms:component component="${feature}"/>
            </cms:slot>
    </div>
    <div class="span-4 section3 advert">
        <cms:slot var="feature" contentSlot="${slots.Section3}">
            <cms:component component="${feature}"/>
        </cms:slot>
    </div>
    <div class="span-4 linkSection advert last">
        <cms:slot var="feature" contentSlot="${slots.LinkSection}">
            <cms:component component="${feature}"/>
        </cms:slot>
    </div>
</template:page>
