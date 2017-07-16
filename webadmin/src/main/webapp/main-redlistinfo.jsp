<%@ page pageEncoding="UTF-8" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page session="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<c:set var="language" value="${not empty param.language ? param.language : not empty language ? language : pageContext.response.locale}" scope="request" />
<fmt:setLocale value="${language}" />
<fmt:setBundle basename="pt.floraon.redlistdata.fieldValues" />
<!DOCTYPE html>
<html>
<head>
	<title>${taxon.getName()} - <fmt:message key="DataSheet.title"/></title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<link href='//fonts.googleapis.com/css?family=Lato:300' rel='stylesheet' type='text/css'>
	<link rel="stylesheet" type="text/css" href="/floraon/base.css?nocache=${uuid}"/>
	<link rel="stylesheet" type="text/css" href="/floraon/redlist.css?nocache=${uuid}"/>
	<script type="text/javascript" src="/floraon/sorttable.js"></script>
	<script type="text/javascript" src="/floraon/basefunctions.js?nocache=${uuid}"></script>
	<script type="text/javascript" src="/floraon/ajaxforms.js?nocache=${uuid}"></script>
	<script type="text/javascript" src="/floraon/suggestions.js?nocache=${uuid}"></script>
	<script type="text/javascript" src="/floraon/redlistadmin.js?nocache=${uuid}"></script>
	<c:if test="${what=='main'}">
	<style>
	    <c:forEach var="tmp" items="${allTags}">
	    #speciesindex.onlytag_${tmp.getKey()} tbody tr:not(.tag_${tmp.getKey()}) {display: none;}
	    </c:forEach>
	</style>
	</c:if>
</head>
<body>
<input type="hidden" name="territory" value="${territory}"/>
<a class="returntomain" href="/floraon/"><img src="/floraon/images/cap-cor.png" alt="logo"/></a>
<div id="title"><a href="/floraon/"><fmt:message key="DataSheet.title"/></a></div>
<div id="main-holder">
    <c:if test="${what != 'taxonrecords'}">
    <div id="left-bar" class="buttonmenu">
        <ul>
            <li><a href="?w=main"><fmt:message key="Separator.1"/></a></li>
            <c:if test="${user.canMANAGE_REDLIST_USERS()}">
                <li><a href="?w=users"><fmt:message key="Separator.2"/></a></li>
                <li><a href="api/downloaddata?territory=${territory}"><fmt:message key="Separator.3"/></a></li>
                <li><a href="?w=jobs"><fmt:message key="Separator.6"/></a></li>
            </c:if>
            <c:if test="${user.canCREATE_REDLIST_DATASETS()}">
                <li><a href="api/updatenativestatus?territory=${territory}"><fmt:message key="Separator.4"/> ${territory}</a></li>
            </c:if>
            <c:if test="${user.isAdministrator()}">
                <li><a href="?w=batch"><fmt:message key="Separator.5"/></a></li>
            </c:if>
            <c:if test="${user.getUserPolygons() != null && !user.getUserPolygons().equals(\"\")}">
                <li><a href="?w=downloadtargetrecords"><fmt:message key="Separator.7"/></a></li>
            </c:if>
            <c:if test="${!user.isGuest()}">
                <li><a href="?w=report">Relatório</a></li>
            </c:if>
        </ul>
    </div>
    </c:if>
    <div id="main">
    <c:choose>
    <c:when test="${what=='addterritory'}">
        <c:if test="${user.canCREATE_REDLIST_DATASETS()}">
        <h1>Create new red list dataset</h1>
        <h2>Select a territory to create a dataset.</h2>
        <ul>
        <c:forEach var="terr" items="${territories}">
            <li><a href="redlist/api/newdataset?territory=${terr.getShortName()}">${terr.getName()}</a></li>
        </c:forEach>
        </ul>
        </c:if>
    </c:when>
    <c:when test="${what=='batch'}">
        <h1><fmt:message key="Separator.5"/></h1>
        <p><fmt:message key="Update.1"/></p>
        <form class="poster" data-path="/floraon/redlist/api/updatefromcsv" data-refresh="false" method="post" enctype="multipart/form-data">
            <input type="hidden" name="territory" value="${territory}"/>
            <input type="file" name="updateTable" />
            <input type="submit" class="textbutton" value="<fmt:message key='Update.2'/>"/>
        </form>
    </c:when>
    <c:when test="${what=='jobs'}">
        <iframe style="visibility: hidden; width:0; height:0" name="trash"></iframe>
        <c:if test="${user.canMANAGE_REDLIST_USERS()}">
            <h1><fmt:message key="Separator.6"/></h1>
            <h2><fmt:message key="Downloads.1"/></h2>
            <!--<form action="api/downloadtable" target="trash">-->
            <form class="poster bigbutton" data-path="/floraon/redlist/api/downloadtable" data-refresh="true">
                <h3>Tabela de taxa da Lista Alvo e Lista B com EOO, AOO, etc.</h3>
                <input type="hidden" name="territory" value="${territory}"/>
                <div class="multiplechooser left">
                <c:forEach var="tmp" items="${allTags}">
                    <input type="checkbox" name="tags" value="${tmp}" id="tags_${tmp}"/>
                    <label for="tags_${tmp}" class="wordtag togglebutton"> ${tmp}</label>
                </c:forEach>
                </div>
                <input type="submit" value="Descarregar" class="textbutton"/>
            </form>
            <p><fmt:message key="Downloads.3"/></p>
            <c:if test="${jobs.size() > 0}">
                <h2><fmt:message key="Downloads.2"/></h2>
                <table>
                    <tr>
                        <th>Download type</th>
                        <th>Date started</th>
                        <th>Ready</th>
                        <th>Status</th>
                        <th>Download</th>
                    </tr>
                    <c:forEach var="job" items="${jobs}">
                    <tr>
                        <td>${job.getDescription()}</td>
                        <td>${job.getDateSubmitted()}</td>
                        <td><t:yesno test="${job.isReady()}"/></td>
                        <td>${job.getState()}</td>
                        <td>
                            <c:if test="${job.isFileDownload() && job.isReady()}">
                            <a href="/floraon/job/${job.getID()}">Download file</a>
                            </c:if>
                        </td>
                    </tr>
                    </c:forEach>
                </table>
            </c:if>
        </c:if>
    </c:when>
    <c:when test="${what=='main'}">
        <h1>Taxon index</h1>
        <c:if test="${user.canMANAGE_REDLIST_USERS()}">
        <div><t:ajaxloadhtml url="api/statistics-table?territory=${territory}" width="100px" height="100px" text="carregando estatísticas"/></div>
        </c:if>
        <c:if test="${user.canCREATE_REDLIST_DATASETS()}">
        <div class="filterpanel">
            <h3><fmt:message key="TaxonIndex.admin.1"/></h3>
            <form class="poster" data-path="/floraon/redlist/api/addnewtaxent" data-refresh="true" id="addtaxon2redlist">
                <div class="withsuggestions">
                    <input type="text" class="nochangeevent" placeholder="<fmt:message key="DataSheet.msg.typeletters"/>" autocomplete="off" id="addtaxonbox"/>
                    <div id="addtaxsuggestions"></div>
                </div>
                <input type="hidden" name="territory" value="${territory}"/>
                <input type="submit" value="<fmt:message key="TaxonIndex.admin.2"/>" class="textbutton"/>
            </form>
            <p></p>
        </div>
        </c:if>
        <c:if test="${user.canEDIT_ANY_FIELD()}">
        <div class="filterpanel inactive">
            <h3><fmt:message key="TaxonIndex.selecting.1"/></h3>
            <p id="selectedmsg"></p>
            <div class="button" id="selectall"><fmt:message key="TaxonIndex.selecting.4"/></div>
            <div class="button" id="toggleselectedtaxa"><fmt:message key="TaxonIndex.selecting.2"/></div>
            <div class="button" id="selecttaxa"><fmt:message key="TaxonIndex.selecting.3"/></div>
            <div class="button" id="addtag"><fmt:message key="TaxonIndex.selecting.5"/></div>
        </div>
        <form data-path="/floraon/redlist/api/addtag" id="addtagform">
            <input type="hidden" name="territory" value="${territory}"/>
        </form>
        </c:if>
        <div id="filters" class="filterpanel inactive">
            <h3><fmt:message key="TaxonIndex.filters.1"/></h3>
            <c:if test="${!user.isGuest()}">
            <div class="filter wordtag togglebutton" id="onlyresponsible"><div class="light"></div><div><fmt:message key="TaxonIndex.filters.3"/></div></div>
            </c:if>
            <div class="filter" id="onlynative"><div class="light"></div><div><fmt:message key="TaxonIndex.filters.4"/></div></div>
            <div class="filter" id="onlyassessed"><div class="light"></div><div><fmt:message key="TaxonIndex.filters.6"/></div></div>
            <div class="filter" id="onlyvalidationerror"><div class="light"></div><div><fmt:message key="TaxonIndex.filters.8"/></div></div>
            <div class="filter" id="onlypublished"><div class="light"></div><div><fmt:message key="TaxonIndex.filters.5"/></div></div>
            <c:if test="${user.canEDIT_ANY_FIELD()}">
            <div class="filter" id="onlyselected"><div class="light"></div><div><fmt:message key="TaxonIndex.filters.7"/></div></div>
            </c:if>
            <c:forEach var="tmp" items="${allTags}">
            <div class="filter tag" id="onlytag_${tmp.getKey()}"><div class="light"></div><div>${tmp.getValue()}</div></div>
            </c:forEach>
        </div>

        <form method="post" action="/floraon/redlist/${territory}">
            <input type="hidden" name="w" value="taxon"/>
            <c:if test="${user.canEDIT_ANY_FIELD()}">
            <div class="floatingtoolbar">
                <input type="submit" value="" id="editselectedtaxa" class="hidden"/>
            </div>
            </c:if>
            <table id="speciesindex" class="sortable smalltext">
                <thead>
                    <tr>
                    <c:if test="${user.canEDIT_ANY_FIELD()}">
                        <th class="sorttable_nosort"></th>
                    </c:if>
                        <th>Taxon</th><th>Native Status</th>
                    <c:if test="${user.canVIEW_FULL_SHEET()}">
                        <th>Responsible for texts</th>
                    </c:if>
                    <c:if test="${user.canMANAGE_REDLIST_USERS()}">
                        <th>Responsible for assessment</th>
                        <th>Responsible for revision</th>
                    </c:if>
                        <th>Assessment status</th>
                    <c:if test="${!user.canMANAGE_REDLIST_USERS()}">
                        <th>Assessor</th><th>Reviewer</th>
                    </c:if>
                        <th>Category</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="taxon" items="${specieslist}">
                    <c:set var="taxonclasses" value=""/>
                    <c:if test="${taxon.getTaxEnt().isSpecies()}">
                        <c:set var="taxonclasses" value="${taxonclasses} species"/>
                    </c:if>
                    <c:if test="${taxon.getResponsibleAuthors_Texts().contains(user.getID()) || taxon.getResponsibleAuthors_Assessment().contains(user.getID()) || taxon.getResponsibleAuthors_Revision().contains(user.getID())}">
                        <c:set var="taxonclasses" value="${taxonclasses} responsible"/>
                    </c:if>
                    <c:if test="${taxon.getInferredStatus() != null && taxon.getInferredStatus().getNativeStatus().isNative()}">
                        <c:set var="taxonclasses" value="${taxonclasses} native"/>
                    </c:if>
                    <c:if test="${taxon.getAssessment().getPublicationStatus().isPublished()}">
                        <c:set var="taxonclasses" value="${taxonclasses} published"/>
                    </c:if>
                    <c:if test="${taxon.getAssessment().getAssessmentStatus().isAssessed()}">
                        <c:set var="taxonclasses" value="${taxonclasses} assessed"/>
                    </c:if>
                    <c:if test="${taxon.validateCriteria().size() > 0}">
                        <c:set var="taxonclasses" value="${taxonclasses} validationerror"/>
                    </c:if>
                    <c:forEach var="tmp" items="${taxon._getHTMLEscapedTags()}">
                        <c:set var="taxonclasses" value="${taxonclasses} tag_${tmp}"/>
                    </c:forEach>

                        <tr class="${taxonclasses}">
                        <c:if test="${user.canEDIT_ANY_FIELD()}">
                            <td>
                                <input type="checkbox" name="id" value="${taxon.getTaxEnt().getID()}" class="selectionbox" id="selbox_${taxon.getTaxEnt()._getIDURLEncoded()}"/>
                                <label for="selbox_${taxon.getTaxEnt()._getIDURLEncoded()}"></label>
                            </td>
                        </c:if>
                        <td><a href="?w=taxon&id=${taxon.getTaxEnt()._getIDURLEncoded()}">${taxon.getTaxEnt().getFullName(true)}</a></td>
                        <td>
                        <c:if test="${taxon.getInferredStatus() != null}">
                            ${taxon.getInferredStatus().getStatusSummary()}
                        </c:if>
                        <c:if test="${taxon.getInferredStatus() == null}">
                            NONEXISTENT
                        </c:if>
                        </td>
                        <c:if test="${user.canVIEW_FULL_SHEET()}">
                        <td><c:forEach var="ra" items="${taxon.getResponsibleAuthors_Texts()}">${userMap.get(ra)}<br/></c:forEach></td>
                        </c:if>
                        <c:if test="${user.canMANAGE_REDLIST_USERS()}">
                        <td><c:forEach var="ra" items="${taxon.getResponsibleAuthors_Assessment()}">${userMap.get(ra)}<br/></c:forEach></td>
                        <td><c:forEach var="ra" items="${taxon.getResponsibleAuthors_Revision()}">${userMap.get(ra)}<br/></c:forEach></td>
                        </c:if>
                        <td>
                        <c:if test="${taxon.getAssessment().fetchSequentialAssessmentStatus() != null}">
                            <fmt:message key="${taxon.getAssessment().fetchSequentialAssessmentStatus()[0]}"/><br/>
                            <fmt:message key="${taxon.getAssessment().fetchSequentialAssessmentStatus()[1]}"/>
                        </c:if>
                        </td>

                        <c:if test="${!user.canMANAGE_REDLIST_USERS()}">
                        <td><c:forEach var="eval" items="${taxon.getAssessment().getEvaluator()}">
                            ${userMap.get(eval)}&nbsp;
                        </c:forEach></td>
                        <td><c:forEach var="eval" items="${taxon.getAssessment().getReviewer()}">
                            ${userMap.get(eval)}&nbsp;
                        </c:forEach></td>
                        </c:if>
                        <td>
                        <c:if test="${taxon.getAssessment().getCategory() != null}">
                            <div class="redlistcategory assess_${taxon.getAssessment().getAdjustedCategory().getEffectiveCategory().toString()}"><h1>
                                ${taxon.getAssessment().getAdjustedCategory().getShortTag()}
                                <c:if test="${taxon.getAssessment().getCategory().toString().equals('CR') && !taxon.getAssessment().getSubCategory().toString().equals('NO_TAG')}"><sup>${taxon.getAssessment().getSubCategory().toString()}</sup></c:if>
                            </h1></div>
                        </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </form>
    </c:when>
    <c:when test="${what=='taxon'}">
        <c:if test="${warning != null && warning.size() > 0}">
            <div class="warning">
                <p><fmt:message key="DataSheet.msg.warning"/></p>
                <ul>
                <c:forEach var="warn" items="${warning}">
                    <li><fmt:message key="${warn}"/></li>
                </c:forEach>
                </ul>
            </div>
        </c:if>
        <c:if test="${user.canVIEW_FULL_SHEET()}">
        <div class="navigator">
            <div class="button anchorbutton section2"><a href="#distribution">2. <fmt:message key="DataSheet.label.2" /></a></div>
            <div class="button anchorbutton section3"><a href="#population">3. <fmt:message key="DataSheet.label.3" /></a></div>
            <div class="button anchorbutton section4"><a href="#ecology">4. <fmt:message key="DataSheet.label.4" /></a></div>
            <div class="button anchorbutton section5"><a href="#uses">5. <fmt:message key="DataSheet.label.5" /></a></div>
            <div class="button anchorbutton section6"><a href="#threats">6. <fmt:message key="DataSheet.label.6" /></a></div>
            <div class="button anchorbutton section7"><a href="#conservation">7. <fmt:message key="DataSheet.label.7" /></a></div>
            <div class="button anchorbutton section9"><a href="#assessment">9. <fmt:message key="DataSheet.label.9" /></a></div>
        </div>
        </c:if>
        <c:if test="${multipletaxa}">
        <form class="poster" data-path="/floraon/redlist/api/updatedata" id="maindataform" data-callback="?w=main">
        </c:if>
        <c:if test="${!multipletaxa}">
        <form class="poster" data-path="/floraon/redlist/api/updatedata" id="maindataform" data-refresh="true">
        </c:if>
            <input type="hidden" name="territory" value="${territory}"/>
            <c:if test="${!multipletaxa}">
            <input type="hidden" name="databaseId" value="${rlde.getID()}"/>
            <input type="hidden" name="taxEntID" value="${rlde.getTaxEntID()}"/>
            </c:if>

            <table class="sheet">
                <tr class="textual"><td colspan="3" id="sheet-header" class="title">
                <c:if test="${multipletaxa}">
                    <h1><fmt:message key="DataSheet.msg.multipletaxa"/></h1>
                    <ul class="inlinelistitems">
                    <c:forEach var="taxon" items="${taxa}">
                        <li>
                            <input type="hidden" name="taxEntID" value="${taxon.getID()}"/>
                            <i>${taxon.getName()}</i>
                        </li>
                    </c:forEach>
                    </ul>
                </c:if>
                <c:if test="${!multipletaxa}">
                    <h1><i>${taxon.getName()}</i></h1>
                    <div class="redlistcategory assess_${rlde.getAssessment().getAdjustedCategory().getEffectiveCategory().toString()}">
                        <h1>
                            ${rlde.getAssessment().getAdjustedCategory().getShortTag()}
                            <c:if test="${rlde.getAssessment().getCategory().toString().equals('CR') && !rlde.getAssessment().getSubCategory().toString().equals('NO_TAG')}"><sup>${rlde.getAssessment().getSubCategory().toString()}</sup></c:if>
                        </h1>
                        <p>${rlde.getAssessment().getAdjustedCategory().getLabel()}</p>
                    </div>
                    <div id="header-buttons">
                        <div class="wordtag togglebutton"><a href="/floraon/checklist?w=taxdetails&id=${taxon._getIDURLEncoded()}">checklist</a></div>
                        <c:if test="${user.canVIEW_FULL_SHEET()}">
                            <div class="wordtag togglebutton" id="summary_toggle">summary</div>
                        </c:if>
                        <c:if test="${user.canVIEW_OCCURRENCES()}">
                            <div class="wordtag togglebutton"><a href="?w=taxonrecords&group=500&id=${taxon._getIDURLEncoded()}">view occurrences</a></div>
                        </c:if>
                        <c:if test="${user.canDOWNLOAD_OCCURRENCES()}">
                            <div class="wordtag togglebutton"><a href="?w=downloadtaxonrecords&id=${taxon._getIDURLEncoded()}">download KML</a></div>
                        </c:if>
                    </div>
                </c:if>
                </td></tr>
                <c:if test="${user.canVIEW_FULL_SHEET()}">
                    <tr class="section1"><td class="title" colspan="3"><fmt:message key="DataSheet.label.section"/> 1 - <fmt:message key="DataSheet.label.1" /></td></tr>
                    <tr class="section1">
                        <td class="title">1.1</td>
                        <td><fmt:message key="DataSheet.label.1.1" /></td><td><i>${taxon.getName()}</i>
                            <div class="floatingtoolbar">
                                <div tabindex="0" id="removeformatting" class="hidden"></div>
                            <c:if test="${user.canEDIT_ANY_FIELD()}">
                                <input type="submit" value="" id="mainformsubmitter" class="hidden"/>
                            </c:if>
                                <div id="toggle_help"></div>
                            </div>
                        </td>
                    </tr>
                    <tr class="section1"><td class="title">1.2</td><td><fmt:message key="DataSheet.label.1.2" /></td><td>${taxon.getAuthor()}</td></tr>
                    <tr class="section1"><td class="title">1.3</td><td><fmt:message key="DataSheet.label.1.3" /></td><td>
                        <table class="subtable">
                        <c:if test="${fn:length(synonyms) > 0}">
                            <tr><td><fmt:message key="DataSheet.label.1.3a"/></td><td>
                            <ul><c:forEach var="synonym" items="${synonyms}">
                                <li data-key="${synonym.getID()}">${synonym.getFullName(true)}</li>
                            </c:forEach></ul>
                            </td></tr>
                        </c:if>
                        <c:if test="${fn:length(includedTaxa) > 0}">
                            <tr><td><fmt:message key="DataSheet.label.1.3c"/></td><td>
                            <ul><c:forEach var="synonym" items="${includedTaxa}">
                                <li data-key="${synonym.getID()}">${synonym.getFullName(true)}</li>
                            </c:forEach></ul>
                            </td></tr>
                        </c:if>
                        <c:if test="${fn:length(formerlyIncluded) > 0}">
                        <tr><td><fmt:message key="DataSheet.label.1.3b"/></td><td>
                            <ul><c:forEach var="synonym" items="${formerlyIncluded}">
                                <li data-key="${synonym.getID()}">${synonym.getFullName(true)}</li>
                            </c:forEach></ul>
                            </td></tr>
                        </c:if>
                        </table>
                    </td></tr>
                    <tr class="section1 textual"><td class="title">1.4</td><td><fmt:message key="DataSheet.label.1.4" /></td><td>
                        <t:editabletext
                            privilege="${user.canEDIT_1_4()}"
                            value="${rlde.getTaxonomicProblemDescription()}"
                            name="taxonomicProblemDescription"/>
                    </td></tr>
                    <tr class="section1"><td class="title">1.5</td><td><fmt:message key="DataSheet.label.1.5" /></td><td>
                        <c:out value="${commonNames}"/>
                    </td></tr>
                    <tr class="section1"><td class="title">1.6</td><td><fmt:message key="DataSheet.label.1.6" /></td><td>
                    <c:if test="${user.canMANAGE_REDLIST_USERS()}">
                        <div class="multiplechooser left" id="tagchooser">
                            <input type="hidden" name="tags" value=""/>
                        <c:forEach var="tmp" items="${allTags}">
                            <c:if test="${tags.contains(tmp)}">
                                <input type="checkbox" name="tags" value="${tmp}" checked="checked" id="tags_${tmp}"/>
                                <label for="tags_${tmp}" class="wordtag togglebutton"> ${tmp}</label>
                            </c:if>
                            <c:if test="${!tags.contains(tmp)}">
                                <input type="checkbox" name="tags" value="${tmp}" id="tags_${tmp}"/>
                                <label for="tags_${tmp}" class="wordtag togglebutton"> ${tmp}</label>
                            </c:if>
                        </c:forEach>
                        </div>
                        <input type="text" class="nochangeevent" name="query" placeholder="<fmt:message key="DataSheet.msg.newtag" />" autocomplete="off" id="tagbox"/>
                        <input type="button" value="Create new..." class="button" id="newtag"/>
                    </c:if>
                    <c:if test="${!user.canEDIT_1_4()}">
                        <ul>
                        <c:forEach var="tmp" items="${tags}">
                            <li><c:out value="${tmp}"></c:out></li>
                        </c:forEach>
                        </ul>
                    </c:if>
                    </td></tr>
                    <tr class="section2"><td class="title" colspan="3"><a name="distribution"></a><fmt:message key="DataSheet.label.section"/> 2 - <fmt:message key="DataSheet.label.2" /></td></tr>
                </c:if>
                <tr class="section2 textual"><td class="title">2.1</td><td><fmt:message key="DataSheet.label.2.1" /></td><td>
                    <table>
                        <tr><td style="width:auto">
                            <t:editabletext
                                privilege="${user.canEDIT_SECTION2() || user.canEDIT_ALL_TEXTUAL()}"
                                value="${rlde.getGeographicalDistribution().getDescription()}"
                                name="geographicalDistribution_Description"/>
                        </td>
                        <c:if test="${historicalsvgmap != null}">
                            <td style="width:0; text-align:center;">${historicalsvgmap}</td>
                        </c:if>
                            <td style="width:0; text-align:center;">${svgmap}</td>
                        </tr>
                        <tr><td style="width:auto"></td>
                            <c:if test="${historicalsvgmap != null}"><td style="width:0; text-align:center;"><fmt:message key="DataSheet.label.2.1a"/></td></c:if>
                            <td style="width:0; text-align:center;"><fmt:message key="DataSheet.label.2.1b"/></td>
                        </tr>
                    </table>
                </td></tr>
                <c:if test="${user.canVIEW_FULL_SHEET()}">
                    <tr class="section2"><td class="title">2.2</td><td><fmt:message key="DataSheet.label.2.2" /></td><td>
                        <c:if test="${occurrences == null}">
                            No occurrence records
                        </c:if>
                        <c:if test="${occurrences != null}">
                        <table class="subtable">
                            <tr><td><b>EOO</b></td><td>
                                <input type="hidden" name="geographicalDistribution_EOO" value="${EOO}"/>
                                <b><fmt:formatNumber value="${EOO}" maxFractionDigits="0" groupingUsed="false"/> km<sup>2</sup></b> (${occurrences.size()} occurrences, ${nclusters} sites)
                            </td></tr>
                            <c:if test="${realEOO != null && realEOO != EOO}">
                            <tr><td>Real EOO</td><td>
                                <fmt:formatNumber value="${realEOO}" maxFractionDigits="0" groupingUsed="false"/> km<sup>2</sup>
                            </td></tr>
                            </c:if>
                            <tr><td>Historical EOO</td><td>
                                <input type="hidden" name="geographicalDistribution_historicalEOO" value="${hEOO}"/>
                                <fmt:formatNumber value="${hEOO}" maxFractionDigits="0" groupingUsed="false"/> km<sup>2</sup> (${historicalOccurrences.size()} occurrences)
                            </td></tr>
<!--
                            <tr><td>UTM square EOO</td><td>
                                <fmt:formatNumber value="${squareEOO}" maxFractionDigits="0" groupingUsed="false"/> km<sup>2</sup>
                            </td></tr>
-->
                        </table>
                        </c:if>
                    </td></tr>
                    <tr class="section2"><td class="title">2.3</td><td><fmt:message key="DataSheet.label.2.3" /></td><td>
                        <c:if test="${occurrences == null}">
                            No occurrence records
                        </c:if>
                        <c:if test="${occurrences != null}">
                            <table class="subtable">
                                <tr><td><b>AOO</b></td><td>
                                    <input type="hidden" name="geographicalDistribution_AOO" value="${AOO}"/>
                                    <b><fmt:formatNumber value="${AOO}" maxFractionDigits="4" groupingUsed="false"/></b> km<sup>2</sup> (${nquads} ${sizeofsquare}x${sizeofsquare} km squares)
                                </td></tr>
                                <tr><td>Historical AOO</td><td>
                                    <input type="hidden" name="geographicalDistribution_historicalAOO" value="${hAOO}"/>
                                    <fmt:formatNumber value="${hAOO}" maxFractionDigits="0" groupingUsed="false"/> km<sup>2</sup> (${hnquads} ${sizeofsquare}x${sizeofsquare} km squares)
                                </td></tr>
                            </table>
                        </c:if>
                    </td></tr>
                    <tr class="section2"><td class="title">2.4</td><td><fmt:message key="DataSheet.label.2.4" /></td><td>
                        <c:if test="${user.canEDIT_SECTION2()}">
                        <table class="triggergroup">
                            <tr><td>Category</td><td>
                                <select name="geographicalDistribution_DeclineDistribution" class="trigger">
                                    <c:forEach var="tmp" items="${geographicalDistribution_DeclineDistribution}">
                                        <c:if test="${rlde.getGeographicalDistribution().getDeclineDistribution().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}" /></option>
                                        </c:if>
                                        <c:if test="${!rlde.getGeographicalDistribution().getDeclineDistribution().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}" /></option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </td></tr>
                            <tr class="triggered ${rlde.getGeographicalDistribution().getDeclineDistribution().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getGeographicalDistribution().getDeclineDistributionJustification()}</div>
                                <input type="hidden" name="geographicalDistribution_DeclineDistributionJustification" value="${fn:escapeXml(rlde.getGeographicalDistribution().getDeclineDistributionJustification())}"/>
                            </td></tr>
                        </table>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION2()}">
                        <table>
                            <tr><td>Category</td><td><fmt:message key="${rlde.getGeographicalDistribution().getDeclineDistribution().getLabel()}" /></td></tr>
                            <tr><td>Justification</td><td>${rlde.getGeographicalDistribution().getDeclineDistributionJustification()}</td></tr>
                        </table>
                        </c:if>
                    </td></tr>
                    <tr class="section2"><td class="title">2.5</td><td><fmt:message key="DataSheet.label.2.5" /></td><td>
                        <c:if test="${user.canEDIT_SECTION2()}">
                            <input name="geographicalDistribution_ElevationRange" type="number" min="0" value="${rlde.getGeographicalDistribution().getElevationRange()[0] == null ? '' : rlde.getGeographicalDistribution().getElevationRange()[0]}"/>
                            <input name="geographicalDistribution_ElevationRange" type="number" min="0" value="${rlde.getGeographicalDistribution().getElevationRange()[1] == null ? '' : rlde.getGeographicalDistribution().getElevationRange()[1]}"/>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION2()}">
                            ${rlde.getGeographicalDistribution().getElevationRange()[0]} - ${rlde.getGeographicalDistribution().getElevationRange()[1]}
                        </c:if>
                    </td></tr>
                    <tr class="section2"><td class="title">2.6</td><td><fmt:message key="DataSheet.label.2.6" /></td><td>
                        <c:if test="${user.canEDIT_SECTION2()}">
                            <select name="geographicalDistribution_ExtremeFluctuations">
                                <c:forEach var="tmp" items="${geographicalDistribution_ExtremeFluctuations}">
                                    <c:if test="${rlde.getGeographicalDistribution().getExtremeFluctuations().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" selected="selected">${tmp.getLabel()}</option>
                                    </c:if>
                                    <c:if test="${!rlde.getGeographicalDistribution().getExtremeFluctuations().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}">${tmp.getLabel()}</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION2()}">
                            ${rlde.getGeographicalDistribution().getExtremeFluctuations().getLabel()}
                        </c:if>
                    </td></tr>

                    <tr class="section3"><td class="title" colspan="3"><a name="population"></a><fmt:message key="DataSheet.label.section"/> 3 - <fmt:message key="DataSheet.label.3" /></td></tr>
                </c:if>
                <tr class="section3 textual"><td class="title">3.1</td><td><fmt:message key="DataSheet.label.3.1" /></td><td>
                    <t:editabletext
                        privilege="${user.canEDIT_SECTION3() || user.canEDIT_ALL_TEXTUAL()}"
                        value="${rlde.getPopulation().getDescription()}"
                        name="population_Description"/>
                </td></tr>
                <c:if test="${user.canVIEW_FULL_SHEET()}">
                    <tr class="section3"><td class="title">3.2</td><td><fmt:message key="DataSheet.label.3.2" /></td><td>
                        <c:if test="${user.canEDIT_SECTION3()}">
                            <table>
                                <tr><td>Category</td><td>
                                    <select name="population_NrMatureIndividualsCategory">
                                        <c:forEach var="tmp" items="${population_NrMatureIndividualsCategory}">
                                            <c:if test="${rlde.getPopulation().getNrMatureIndividualsCategory().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}" selected="selected"><fmt:message key="${tmp.getLabel()}"/></option>
                                            </c:if>
                                            <c:if test="${!rlde.getPopulation().getNrMatureIndividualsCategory().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}"><fmt:message key="${tmp.getLabel()}"/></option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </td></tr>
                                <tr><td>Exact number</td><td><input type="text" name="population_NrMatureIndividualsExact" value="${rlde.getPopulation().getNrMatureIndividualsExact()}"/><span class="legend alwaysvisible"><fmt:message key="DataSheet.msg.interval"/></span></td></tr>
                            </table>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION3()}">
                            <table>
                                <tr><td>Category</td><td><fmt:message key="${rlde.getPopulation().getNrMatureIndividualsCategory().getLabel()}"/></td></tr>
                                <tr><td>Exact number</td><td>${rlde.getPopulation().getNrMatureIndividualsExact()}</td></tr>
                            </table>
                        </c:if>
                    </td></tr>
                    <tr class="section3"><td class="title">3.3</td><td><fmt:message key="DataSheet.label.3.3" /></td><td>
                        <c:if test="${user.canEDIT_SECTION3()}">
                        <table class="triggergroup">
                            <tr><td>Type</td><td>
                                <select name="population_TypeOfEstimate" class="trigger">
                                    <c:forEach var="tmp" items="${population_TypeOfEstimate}">
                                        <c:if test="${rlde.getPopulation().getTypeOfEstimate().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}" /></option>
                                        </c:if>
                                        <c:if test="${!rlde.getPopulation().getTypeOfEstimate().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}" /></option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </td></tr>
                            <tr class="triggered ${rlde.getPopulation().getTypeOfEstimate().isTrigger() ? '' : 'hidden'}"><td>Description</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getPopulation().getNrMatureIndividualsDescription()}</div>
                                <input type="hidden" name="population_NrMatureIndividualsDescription" value="${fn:escapeXml(rlde.getPopulation().getNrMatureIndividualsDescription())}"/>
                            </td></tr>
                        </table>

                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION3()}">
                        <table>
                            <tr><td>Type</td><td><fmt:message key="${rlde.getPopulation().getTypeOfEstimate().getLabel()}" /></td></tr>
                            <tr><td>Description</td><td>${rlde.getPopulation().getNrMatureIndividualsDescription()}</td></tr>
                        </table>
                        </c:if>
                    </td></tr>
                    <tr class="section3"><td class="title">3.4</td><td><fmt:message key="DataSheet.label.3.4" /></td><td>
                        <c:if test="${user.canEDIT_SECTION3()}">
                        <table class="triggergroup">
                            <tr><td>Category</td><td>
                                <select name="population_PopulationDecline" class="trigger">
                                    <c:forEach var="tmp" items="${population_PopulationDecline}">
                                        <c:if test="${rlde.getPopulation().getPopulationDecline().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}" /></option>
                                        </c:if>
                                        <c:if test="${!rlde.getPopulation().getPopulationDecline().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}" /></option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </td></tr>
                            <tr class="triggered ${rlde.getPopulation().getPopulationDecline().isTrigger() ? '' : 'hidden'}"><td>Percentage</td><td>
                                <input type="number" name="population_PopulationDeclinePercent" value="${rlde.getPopulation().getPopulationDeclinePercent()}" placeholder="percentage"/> %
                            </td></tr>
                            <tr class="triggered ${rlde.getPopulation().getPopulationDecline().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getPopulation().getPopulationDeclineJustification()}</div>
                                <input type="hidden" name="population_PopulationDeclineJustification" value="${fn:escapeXml(rlde.getPopulation().getPopulationDeclineJustification())}"/>
                            </td></tr>
                        </table>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION3()}">
                        <table>
                            <tr><td>Category</td><td><fmt:message key="${rlde.getPopulation().getPopulationDecline().getLabel()}" /></td></tr>
                            <tr><td>Percentage</td><td>${rlde.getPopulation().getPopulationDeclinePercent()}</td></tr>
                            <tr><td>Justification</td><td>${rlde.getPopulation().getPopulationDeclineJustification()}</td></tr>
                        </table>
                        </c:if>
                    </td></tr>
                    <tr class="section3"><td class="title">3.5</td><td><fmt:message key="DataSheet.label.3.5" /></td><td>
                        <c:if test="${user.canEDIT_SECTION3()}">
                        <table class="triggergroup">
                            <tr><td>Category</td><td>
                                <div class="checkboxes list" tabindex="0">
                                    <c:forEach var="tmp" items="${population_PopulationSizeReduction}">
                                        <c:if test="${rlde.getPopulation().getPopulationSizeReduction().toString().equals(tmp.toString())}">
                                            <input type="radio" class="trigger" name="population_PopulationSizeReduction" value="${tmp.toString()}" checked="checked" id="psr_${tmp}" data-trigger="${tmp.isTrigger() ? 1 : 0}"/>
                                            <label for="psr_${tmp}"> <fmt:message key="${tmp.getLabel()}" /></label>
                                        </c:if>
                                        <c:if test="${!rlde.getPopulation().getPopulationSizeReduction().toString().equals(tmp.toString())}">
                                            <input type="radio" class="trigger" name="population_PopulationSizeReduction" value="${tmp.toString()}" id="psr_${tmp}" data-trigger="${tmp.isTrigger() ? 1 : 0}"/>
                                            <label for="psr_${tmp}"> <fmt:message key="${tmp.getLabel()}" /></label>
                                        </c:if>
                                    </c:forEach>
                                    <label class="placeholder"><fmt:message key="DataSheet.msg.clickxpand"/></label>
                                </div>
                            </td></tr>
                            <tr class="triggered ${rlde.getPopulation().getPopulationSizeReduction().isTrigger() ? '' : 'hidden'}"><td>Percentage</td><td>
                                <input type="number" name="population_PopulationTrend" value="${rlde.getPopulation().getPopulationTrend()}" placeholder="percentage"/> %
                            </td></tr>
                            <tr class="triggered ${rlde.getPopulation().getPopulationSizeReduction().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getPopulation().getPopulationSizeReductionJustification()}</div>
                                <input type="hidden" name="population_PopulationSizeReductionJustification" value="${fn:escapeXml(rlde.getPopulation().getPopulationSizeReductionJustification())}"/>
                            </td></tr>
                        </table>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION3()}">
                        <table>
                            <tr><td>Percentage</td><td>${rlde.getPopulation().getPopulationTrend()} %</td></tr>
                            <tr><td>Category</td><td><fmt:message key="${rlde.getPopulation().getPopulationSizeReduction().getLabel()}" /></td></tr>
                            <tr><td>Justification</td><td>${rlde.getPopulation().getPopulationSizeReductionJustification()}</td></tr>
                        </table>
                        </c:if>
                    </td></tr>
                    <tr class="section3"><td class="title">3.6</td><td><fmt:message key="DataSheet.label.3.6" /></td><td>
                        <c:if test="${user.canEDIT_SECTION3()}">
                        <table class="triggergroup">
                            <tr><td>Category</td><td>
                                <select name="population_SeverelyFragmented" class="trigger">
                                    <c:forEach var="tmp" items="${population_SeverelyFragmented}">
                                        <c:if test="${rlde.getPopulation().getSeverelyFragmented().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                        </c:if>
                                        <c:if test="${!rlde.getPopulation().getSeverelyFragmented().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </td></tr>
                            <tr class="triggered ${rlde.getPopulation().getSeverelyFragmented().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getPopulation().getSeverelyFragmentedJustification()}</div>
                                <input type="hidden" name="population_SeverelyFragmentedJustification" value="${fn:escapeXml(rlde.getPopulation().getSeverelyFragmentedJustification())}"/>
                            </td></tr>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION3()}">
                        <table>
                            <tr><td>Category</td><td>${rlde.getPopulation().getSeverelyFragmented().getLabel()}</td></tr>
                            <tr><td>Justification</td><td>${rlde.getPopulation().getSeverelyFragmentedJustification()}</td></tr>
                        </c:if>
<!--                            <tr><td>Mean area of sites</td><td><fmt:formatNumber value="${meanLocationArea}" maxFractionDigits="1"/> hectares</td></tr> -->
                        </table>
                    </td></tr>
                    <tr class="section3"><td class="title">3.7</td><td><fmt:message key="DataSheet.label.3.7" /></td><td>
                    <c:if test="${user.canEDIT_SECTION3()}">
                        <table class="triggergroup">
                            <tr><td>Category</td><td>
                                <select name="population_ExtremeFluctuations" class="trigger">
                                    <c:forEach var="tmp" items="${population_ExtremeFluctuations}">
                                        <c:if test="${rlde.getPopulation().getExtremeFluctuations().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                        </c:if>
                                        <c:if test="${!rlde.getPopulation().getExtremeFluctuations().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </td></tr>
                            <tr class="triggered ${rlde.getPopulation().getExtremeFluctuations().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getPopulation().getExtremeFluctuationsJustification()}</div>
                                <input type="hidden" name="population_ExtremeFluctuationsJustification" value="${fn:escapeXml(rlde.getPopulation().getExtremeFluctuationsJustification())}"/>
                            </td></tr>
                        </table>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION3()}">
                        <table>
                            <tr><td>Category</td><td>${rlde.getPopulation().getExtremeFluctuations().getLabel()}</td></tr>
                            <tr><td>Justification</td><td>${rlde.getPopulation().getExtremeFluctuationsJustification()}</td></tr>
                        </table>
                    </c:if>
                    </td></tr>
                    <tr class="section3"><td class="title">3.8</td><td><fmt:message key="DataSheet.label.3.8" /></td><td>
                    <c:if test="${user.canEDIT_SECTION3()}">
                        <select name="population_NrMatureEachSubpop">
                            <c:forEach var="tmp" items="${population_NrMatureEachSubpop}">
                                <c:if test="${rlde.getPopulation().getNrMatureEachSubpop().toString().equals(tmp.toString())}">
                                    <option value="${tmp.toString()}" selected="selected">${tmp.getLabel()}</option>
                                </c:if>
                                <c:if test="${!rlde.getPopulation().getNrMatureEachSubpop().toString().equals(tmp.toString())}">
                                    <option value="${tmp.toString()}">${tmp.getLabel()}</option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION3()}">
                        ${rlde.getPopulation().getNrMatureEachSubpop().getLabel()}
                    </c:if>
                    </td></tr>
                    <tr class="section3"><td class="title">3.9</td><td><fmt:message key="DataSheet.label.3.9" /></td><td>
                    <c:if test="${user.canEDIT_SECTION3()}">
                        <select name="population_PercentMatureOneSubpop">
                            <c:forEach var="tmp" items="${population_PercentMatureOneSubpop}">
                                <c:if test="${rlde.getPopulation().getPercentMatureOneSubpop().toString().equals(tmp.toString())}">
                                    <option value="${tmp.toString()}" selected="selected"><fmt:message key="${tmp.getLabel()}" /></option>
                                </c:if>
                                <c:if test="${!rlde.getPopulation().getPercentMatureOneSubpop().toString().equals(tmp.toString())}">
                                    <option value="${tmp.toString()}"><fmt:message key="${tmp.getLabel()}" /></option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION3()}">
                        <fmt:message key="${rlde.getPopulation().getPercentMatureOneSubpop().getLabel()}" />
                    </c:if>
                    </td></tr>
                    <tr class="section4"><td class="title" colspan="3"><a name="ecology"></a><fmt:message key="DataSheet.label.section"/> 4 - <fmt:message key="DataSheet.label.4" /></td></tr>
                </c:if>     <!-- can view full sheet -->
                <tr class="section4 textual"><td class="title">4.1</td><td><fmt:message key="DataSheet.label.4.1" /></td><td>
                    <t:editabletext
                        privilege="${user.canEDIT_SECTION4() || user.canEDIT_ALL_TEXTUAL()}"
                        value="${ecology}"
                        name="ecology_Description"/>
                </td></tr>
                <c:if test="${user.canVIEW_FULL_SHEET()}">
                    <tr class="section4"><td class="title">4.2</td><td><fmt:message key="DataSheet.label.4.2" /></td><td>
                        <c:if test="${user.canEDIT_SECTION4() || user.canEDIT_4_2()}">
                            <c:forEach var="tmp" items="${ecology_HabitatTypes}">
                                <c:if test="${habitatTypes.contains(tmp)}">
                                    <label><input type="checkbox" name="ecology_HabitatTypes" value="${tmp.toString()}" checked="checked"/> ${tmp.getLabel()}</label>
                                </c:if>
                                <c:if test="${!habitatTypes.contains(tmp)}">
                                    <label><input type="checkbox" name="ecology_HabitatTypes" value="${tmp.toString()}"/> ${tmp.getLabel()}</label>
                                </c:if>
                            </c:forEach>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION4() && !user.canEDIT_4_2()}">
                            <c:forEach var="tmp" items="${habitatTypes}">
                                <div class="wordtag">${tmp}</div>
                            </c:forEach>
                        </c:if>
                    </td></tr>
                    <tr class="section4"><td class="title">4.3</td><td><fmt:message key="DataSheet.label.4.3" /></td><td>(automatico)</td></tr>
                    <tr class="section4"><td class="title">4.4</td><td><fmt:message key="DataSheet.label.4.4" /></td><td>
                    <c:if test="${user.canEDIT_SECTION4()}">
                        <table class="triggergroup">
                            <tr><td>Length (exact or interval)</td><td>
                                <input name="ecology_GenerationLength" type="text" class="trigger" value="${rlde.getEcology().getGenerationLength()}"/>
                            </td></tr>
                            <tr class="triggered ${(rlde.getEcology().getGenerationLength() != null && rlde.getEcology().getGenerationLength().length() > 0) ? '' : 'hidden'}"><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getEcology().getGenerationLengthJustification()}</div>
                                <input type="hidden" name="ecology_GenerationLengthJustification" value="${fn:escapeXml(rlde.getEcology().getGenerationLengthJustification())}"/>
                            </td></tr>
                        </table>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION4()}">
                        <table>
                            <tr><td>Length (exact or interval)</td><td>${rlde.getEcology().getGenerationLength()}</td></tr>
                            <tr><td>Justification</td><td>${rlde.getEcology().getGenerationLengthJustification()}</td></tr>
                        </table>
                    </c:if>
                    </td></tr>
                    <tr class="section4"><td class="title">4.5</td><td><fmt:message key="DataSheet.label.4.5" /></td><td>
                    <c:if test="${user.canEDIT_SECTION4()}">
                    <table class="triggergroup">
                        <tr><td>Category</td><td>
                            <select name="ecology_DeclineHabitatQuality" class="trigger">
                                <c:forEach var="tmp" items="${ecology_DeclineHabitatQuality}">
                                    <c:if test="${rlde.getEcology().getDeclineHabitatQuality().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}" /></option>
                                    </c:if>
                                    <c:if test="${!rlde.getEcology().getDeclineHabitatQuality().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}" /></option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </td></tr>
                        <tr class="triggered ${rlde.getEcology().getDeclineHabitatQuality().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                            <div contenteditable="true" class="contenteditable">${rlde.getEcology().getDeclineHabitatQualityJustification()}</div>
                            <input type="hidden" name="ecology_DeclineHabitatQualityJustification" value="${fn:escapeXml(rlde.getEcology().getDeclineHabitatQualityJustification())}"/>
                        </td></tr>
                    </table>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION4()}">
                    <table>
                        <tr><td>Category</td><td><fmt:message key="${rlde.getEcology().getDeclineHabitatQuality().getLabel()}" /></td></tr>
                        <tr><td>Justification</td><td>${rlde.getEcology().getDeclineHabitatQualityJustification()}</td></tr>
                    </table>
                    </c:if>
                    </td></tr>
                    <tr class="section5"><td class="title" colspan="3"><a name="uses"></a><fmt:message key="DataSheet.label.section"/> 5 - <fmt:message key="DataSheet.label.5" /></td></tr>
                </c:if>
                <tr class="section5 textual"><td class="title">5.1</td><td><fmt:message key="DataSheet.label.5.1" /></td><td>
                    <t:editabletext
                        privilege="${user.canEDIT_SECTION5() || user.canEDIT_ALL_TEXTUAL()}"
                        value="${rlde.getUsesAndTrade().getDescription()}"
                        name="usesAndTrade_Description"/>
                </td></tr>
                <c:if test="${user.canVIEW_FULL_SHEET()}">
                    <tr class="section5"><td class="title">5.2</td><td><fmt:message key="DataSheet.label.5.2" /></td><td>
                        <t:multiplechooser
                            privilege="${user.canEDIT_SECTION5()}"
                            values="${uses}"
                            allvalues="${usesAndTrade_Uses}"
                            name="usesAndTrade_Uses"
                            layout="list"
                            idprefix="uses" />
                    </td></tr>
                    <tr class="section5"><td class="title">5.3</td><td><fmt:message key="DataSheet.label.5.3" /></td><td>
                        <c:if test="${user.canEDIT_SECTION5()}">
                            <c:if test="${rlde.getUsesAndTrade().isTraded()}">
                                <label><input type="checkbox" name="usesAndTrade_Traded" checked="checked"/> is traded</label>
                            </c:if>
                            <c:if test="${!rlde.getUsesAndTrade().isTraded()}">
                                <label><input type="checkbox" name="usesAndTrade_Traded"/> is traded</label>
                            </c:if>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION5()}">
                            Is traded: ${rlde.getUsesAndTrade().isTraded() ? "Yes" : "No"}
                        </c:if>
                    </td></tr>
                    <tr class="section5"><td class="title">5.4</td><td><fmt:message key="DataSheet.label.5.4" /></td><td>
                        <c:if test="${user.canEDIT_SECTION5()}">
                            <select name="usesAndTrade_Overexploitation">
                                <c:forEach var="tmp" items="${usesAndTrade_Overexploitation}">
                                    <c:if test="${rlde.getUsesAndTrade().getOverexploitation().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" selected="selected">${tmp.getLabel()}</option>
                                    </c:if>
                                    <c:if test="${!rlde.getUsesAndTrade().getOverexploitation().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}">${tmp.getLabel()}</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </c:if>
                        <c:if test="${!user.canEDIT_SECTION5()}">
                            ${rlde.getUsesAndTrade().getOverexploitation().getLabel()}
                        </c:if>
                    </td></tr>
                    <tr class="section6"><td class="title" colspan="3"><a name="threats"></a><fmt:message key="DataSheet.label.section"/> 6 - <fmt:message key="DataSheet.label.6" /></td></tr>
                </c:if>
                <tr class="section6 textual"><td class="title">6.1</td><td><fmt:message key="DataSheet.label.6.1"/></td><td>
                    <t:editabletext
                        privilege="${user.canEDIT_SECTION6() || user.canEDIT_ALL_TEXTUAL()}"
                        value="${rlde.getThreats().getDescription()}"
                        name="threats_Description"/>
                </td></tr>
                <c:if test="${user.canVIEW_FULL_SHEET()}">
                    <tr class="section6"><td class="title">6.2</td><td><fmt:message key="DataSheet.label.6.2"/></td><td>
                    <t:multiplechooser
                        privilege="${user.canEDIT_SECTION6() || user.canEDIT_6_2()}"
                        values="${threats}"
                        allvalues="${threats_Threats}"
                        name="threats_Threats"
                        layout="list"
                        categorized="true"
                        idprefix="thr" />
                    </td></tr>
                    <tr class="section6"><td class="title">6.3</td><td><fmt:message key="DataSheet.label.6.3"/></td><td>
                    <c:if test="${user.canEDIT_SECTION6()}">
                        <table>
                            <tr><td>Number</td><td>
                                <input type="number" min="0" name="threats_NumberOfLocations" value="${rlde.getThreats().getNumberOfLocations()}"/><br/>
                            </td></tr>
                            <tr><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getThreats().getNumberOfLocationsJustification()}</div>
                                <input type="hidden" name="threats_NumberOfLocationsJustification" value="${fn:escapeXml(rlde.getThreats().getNumberOfLocationsJustification())}"/>
                            </td></tr>
                            <tr><td><fmt:message key="DataSheet.label.6.3b"/></td><td>${nclusters} <fmt:message key="DataSheet.label.6.3a"/></td></tr>
                        </table>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION6()}">
                        <table>
                            <tr><td>Number</td><td>${rlde.getThreats().getNumberOfLocations()}</td></tr>
                            <tr><td>Justification</td><td>${rlde.getThreats().getNumberOfLocationsJustification()}</td></tr>
                            <tr><td><fmt:message key="DataSheet.label.6.3b"/></td><td>${nclusters} <fmt:message key="DataSheet.label.6.3a"/></td></tr>
                        </table>
                    </c:if>
                    </td></tr>
                    <tr class="section6"><td class="title">6.4</td><td><fmt:message key="DataSheet.label.6.4" /></td><td>
                    <c:if test="${user.canEDIT_SECTION6()}">
                    <table class="triggergroup">
                        <tr><td>Category</td><td>
                            <select name="threats_DeclineNrLocations" class="trigger">
                                <c:forEach var="tmp" items="${threats_DeclineNrLocations}">
                                    <c:if test="${rlde.getThreats().getDeclineNrLocations().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}"/></option>
                                    </c:if>
                                    <c:if test="${!rlde.getThreats().getDeclineNrLocations().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}"><fmt:message key="${tmp.getLabel()}"/></option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </td></tr>
                        <tr class="triggered ${rlde.getThreats().getDeclineNrLocations().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                            <div contenteditable="true" class="contenteditable">${rlde.getThreats().getDeclineNrLocationsJustification()}</div>
                            <input type="hidden" name="threats_DeclineNrLocationsJustification" value="${fn:escapeXml(rlde.getThreats().getDeclineNrLocationsJustification())}"/>
                        </td></tr>
                    </table>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION6()}">
                    <table>
                        <tr><td>Category</td><td><fmt:message key="${rlde.getThreats().getDeclineNrLocations().getLabel()}"/></td></tr>
                        <tr><td>Justification</td><td>${rlde.getThreats().getDeclineNrLocationsJustification()}</td></tr>
                    </table>
                    </c:if>
                    </td></tr>
                    <tr class="section6"><td class="title">6.5</td><td><fmt:message key="DataSheet.label.6.5" /></td><td>
                    <c:if test="${user.canEDIT_SECTION6()}">
                    <table class="triggergroup">
                        <tr><td>Category</td><td>
                            <select name="threats_ExtremeFluctuationsNrLocations" class="trigger">
                                <c:forEach var="tmp" items="${threats_ExtremeFluctuationsNrLocations}">
                                    <c:if test="${rlde.getThreats().getExtremeFluctuationsNrLocations().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                    </c:if>
                                    <c:if test="${!rlde.getThreats().getExtremeFluctuationsNrLocations().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </td></tr>
                        <tr class="triggered ${rlde.getThreats().getExtremeFluctuationsNrLocations().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                            <div contenteditable="true" class="contenteditable">${rlde.getThreats().getExtremeFluctuationsNrLocationsJustification()}</div>
                            <input type="hidden" name="threats_ExtremeFluctuationsNrLocationsJustification" value="${fn:escapeXml(rlde.getThreats().getExtremeFluctuationsNrLocationsJustification())}"/>
                        </td></tr>
                    </table>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION6()}">
                    <table>
                        <tr><td>Category</td><td>${rlde.getThreats().getExtremeFluctuationsNrLocations().getLabel()}</td></tr>
                        <tr><td>Justification</td><td>${rlde.getThreats().getExtremeFluctuationsNrLocationsJustification()}</td></tr>
                    </table>
                    </c:if>
                    </td></tr>

                    <tr class="section7"><td class="title" colspan="3"><a name="conservation"></a><fmt:message key="DataSheet.label.section"/> 7 - <fmt:message key="DataSheet.label.7" /></td></tr>
                </c:if>
                <tr class="section7 textual"><td class="title">7.1</td><td><fmt:message key="DataSheet.label.7.1"/></td><td>
                    <t:editabletext
                        privilege="${user.canEDIT_SECTION7() || user.canEDIT_ALL_TEXTUAL()}"
                        value="${rlde.getConservation().getDescription()}"
                        name="conservation_Description"/>
                </td></tr>
                <c:if test="${user.canVIEW_FULL_SHEET()}">
                    <tr class="section7"><td class="title">7.2</td><td><fmt:message key="DataSheet.label.7.2"/></td><td>
                    <c:if test="${user.canEDIT_SECTION7()}">
                        <table class="triggergroup">
                            <tr><td>Category</td><td>
                                <select name="conservation_ConservationPlans" class="trigger">
                                    <c:forEach var="tmp" items="${conservation_ConservationPlans}">
                                        <c:if test="${rlde.getConservation().getConservationPlans().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                        </c:if>
                                        <c:if test="${!rlde.getConservation().getConservationPlans().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </td></tr>
                            <tr class="triggered ${rlde.getConservation().getConservationPlans().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getConservation().getConservationPlansJustification()}</div>
                                <input type="hidden" name="conservation_ConservationPlansJustification" value="${fn:escapeXml(rlde.getConservation().getConservationPlansJustification())}"/>
                            </td></tr>
                        </table>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION7()}">
                        <table>
                            <tr><td>Category</td><td>${rlde.getConservation().getConservationPlans().getLabel()}</td></tr>
                            <tr><td>Justification</td><td>${rlde.getConservation().getConservationPlansJustification()}</td></tr>
                        </table>
                    </c:if>
                    </td></tr>
                    <tr class="section7"><td class="title">7.3</td><td><fmt:message key="DataSheet.label.7.3"/></td><td>
                    <c:if test="${user.canEDIT_SECTION7() || user.canEDIT_7_3()}">
                        <table class="triggergroup">
                            <tr><td>Category</td><td>
                                <select name="conservation_ExSituConservation" class="trigger">
                                    <c:forEach var="tmp" items="${conservation_ExSituConservation}">
                                        <c:if test="${rlde.getConservation().getExSituConservation().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                        </c:if>
                                        <c:if test="${!rlde.getConservation().getExSituConservation().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" data-trigger="${tmp.isTrigger() ? 1 : 0}">${tmp.getLabel()}</option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </td></tr>
                            <tr class="triggered ${rlde.getConservation().getExSituConservation().isTrigger() ? '' : 'hidden'}"><td>Justification</td><td>
                                <div contenteditable="true" class="contenteditable">${rlde.getConservation().getExSituConservationJustification()}</div>
                                <input type="hidden" name="conservation_ExSituConservationJustification" value="${fn:escapeXml(rlde.getConservation().getExSituConservationJustification())}"/>
                            </td></tr>
                        </table>
                    </c:if>
                    <c:if test="${!user.canEDIT_SECTION7() && !user.canEDIT_7_3()}">
                        <table>
                            <tr><td>Category</td><td>${rlde.getConservation().getExSituConservation().getLabel()}</td></tr>
                            <tr><td>Justification</td><td>${rlde.getConservation().getExSituConservationJustification()}</td></tr>
                        </table>
                    </c:if>
                    </td></tr>
                    <tr class="section7"><td class="title">7.4</td><td><fmt:message key="DataSheet.label.7.4"/></td><td>
                        <c:if test="${occurrences.size() > 0}">
                            <p><fmt:formatNumber value="${(locationsInPA / nclusters) * 100}" maxFractionDigits="1"/>% sites inside protected areas (${locationsInPA}/${nclusters})</p>
                            <table class="sortable smalltext">
                                <tr><th>Protected Area</th><th>Type</th><th>Number of sites</th></tr>
                                <c:forEach var="tmp" items="${occurrenceInProtectedAreas}">
                                    <tr>
                                        <td>${tmp.getKey().getProperties().get("SITE_NAME")}</td>
                                        <td>${tmp.getKey().getProperties().get("TIPO")}</td>
                                        <td>${tmp.getValue()}</td>
                                    </tr>
                                </c:forEach>
                            </table>
                        </c:if>
                        <c:if test="${occurrences.size() == 0}">
                            <p>No occurrence records</p>
                        </c:if>
                    </td></tr>
                    <tr class="section7"><td class="title">7.4.1</td><td><fmt:message key="DataSheet.label.7.4.1"/></td><td>
                        <ul>
                            <c:forEach var="tmp" items="${legalProtection}">
                            <li>${tmp}</li>
                            </c:forEach>
                        </ul>
                    </td></tr>
                    <tr class="section7"><td class="title">7.5</td><td><fmt:message key="DataSheet.label.7.5" /></td><td>
                        <t:multiplechooser
                            privilege="${user.canEDIT_SECTION7()}"
                            values="${proposedConservationActions}"
                            allvalues="${conservation_ProposedConservationActions}"
                            name="conservation_ProposedConservationActions"
                            layout="list"
                            idprefix="pca" />
                    </td></tr>
                    <tr class="section7"><td class="title">7.6</td><td><fmt:message key="DataSheet.label.7.6" /></td><td>
                        <t:multiplechooser
                            privilege="${user.canEDIT_SECTION7()}"
                            values="${proposedStudyMeasures}"
                            allvalues="${conservation_ProposedStudyMeasures}"
                            name="conservation_ProposedStudyMeasures"
                            layout="list"
                            idprefix="psm" />
                    </td></tr>

                    <tr class="section8"><td class="title" colspan="3"><fmt:message key="DataSheet.label.section"/> 8 - <fmt:message key="DataSheet.label.8" /></td></tr>
                    <tr class="section8"><td class="title">8.1</td><td><fmt:message key="DataSheet.label.8.1" /></td><td>
                    (a fazer)
                    </td></tr>

                    <tr class="section9"><td class="title" colspan="3"><a name="assessment"></a><fmt:message key="DataSheet.label.section"/> 9 - <fmt:message key="DataSheet.label.9" /></td></tr>
                    <tr class="section9"><td class="title">9.1</td><td><fmt:message key="DataSheet.label.9.1" /></td><td class="triggergroup">
                        <div id="redlistcategories">
                            <c:if test="${user.canEDIT_9_1_2_3_4()}">
                                <c:forEach var="tmp" items="${assessment_Category}">
                                    <c:if test="${rlde.getAssessment().getAdjustedCategory().getEffectiveCategory().equals(tmp)}">
                                        <input type="radio" name="assessment_Category" value="${rlde.getAssessment().getAdjustedCategory().toString()}" id="assess_${tmp.toString()}" checked="checked" class="trigger" data-trigger="${tmp.isTrigger() ? 1 : 0}">
                                    </c:if>
                                    <c:if test="${!rlde.getAssessment().getAdjustedCategory().getEffectiveCategory().equals(tmp)}">
                                        <input type="radio" name="assessment_Category" value="${tmp.toString()}" id="assess_${tmp.toString()}" class="trigger" data-trigger="${tmp.isTrigger() ? 1 : 0}">
                                    </c:if>
                                    <label for="assess_${tmp.toString()}">
                                        <h1>
                                            ${tmp.toString()}<c:if test="${rlde.getAssessment().getAdjustedCategory().getEffectiveCategory().equals(tmp) && rlde.getAssessment().getAdjustedCategory().isUpDownListed()}">º</c:if>
                                            <c:if test="${tmp == 'CR' && rlde.getAssessment().getCategory().toString().equals(tmp.toString()) && !rlde.getAssessment().getSubCategory().toString().equals('NO_TAG')}"><sup>${rlde.getAssessment().getSubCategory().toString()}</sup></c:if>
                                        </h1>
                                        <p>${tmp.getLabel()}</p>
                                    </label>
                                    <c:if test="${tmp == 'VU'}"><br/></c:if>
                                </c:forEach>
                            </c:if>
                            <c:if test="${!user.canEDIT_9_1_2_3_4()}">
                                <div class="redlistcategory assess_${rlde.getAssessment().getCategory().toString()}"><h1>${rlde.getAssessment().getCategory().toString()}</h1><p>${rlde.getAssessment().getCategory().getLabel()}</p></div>
                            </c:if>
                        </div>
                        <div class="triggered ${rlde.getAssessment().getCategory().isTrigger() ? '' : 'hidden'}">
                        <c:if test="${user.canEDIT_9_1_2_3_4()}">
                            <select name="assessment_SubCategory">
                                <c:forEach var="tmp" items="${assessment_SubCategory}">
                                    <c:if test="${rlde.getAssessment().getSubCategory().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}" selected="selected">${tmp.getLabel()}</option>
                                    </c:if>
                                    <c:if test="${!rlde.getAssessment().getSubCategory().toString().equals(tmp.toString())}">
                                        <option value="${tmp.toString()}">${tmp.getLabel()}</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </c:if>
                        <c:if test="${!user.canEDIT_9_1_2_3_4()}">
                            ${rlde.getAssessment().getSubCategory().getLabel()}
                        </c:if>
                        </div>
                    </td></tr>
                    <tr class="section9"><td class="title">9.2</td><td><fmt:message key="DataSheet.label.9.2" /></td><td>
                        <c:if test="${user.canEDIT_9_1_2_3_4()}">
                        <input type="hidden" name="assessment_Criteria" value=""/>
                        <table class="subtable">
                            <thead><tr><th>Criteria</th><th>Subcriteria</th></th></thead>
                            <tbody>
                                <c:forEach var="cri" items="${assessment_Criteria.entrySet()}">
                                    <tr><td class="title">${cri.getKey()}</td>
                                    <td>
                                    <div class="multiplechooser left compact">
                                    <c:forEach var="sub" items="${cri.getValue()}">
                                        <c:if test="${selcriteria.contains(sub)}">
                                            <input type="checkbox" name="assessment_Criteria" id="acri_${sub}" value="${sub}" checked="checked"/>
                                        </c:if>
                                        <c:if test="${!selcriteria.contains(sub)}">
                                            <input type="checkbox" name="assessment_Criteria" id="acri_${sub}" value="${sub}"/>
                                        </c:if>
                                        <label for="acri_${sub}" class="wordtag togglebutton notransform">${sub.getLabel()}</label>
                                        <c:if test="${sub.isBreak()}"><label class="line-break"></label></c:if>
                                    </c:forEach>
                                    </div>
                                    </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                            <!--<input name="assessment_Criteria" type="text" class="longbox" value="${rlde.getAssessment().getCriteria()}"/>-->
                        </c:if>
                        <c:if test="${!user.canEDIT_9_1_2_3_4()}">
                            <p><b>${rlde.getAssessment()._getCriteriaAsString()}</b></p>
                        </c:if>
                    </td></tr>
                </c:if>
                <tr class="section9 textual"><td class="title">9.3</td><td><fmt:message key="DataSheet.label.9.3" /></td><td>
                    <t:editabletext
                        privilege="${user.canEDIT_9_1_2_3_4() || user.canEDIT_9_3_9_45()}"
                        value="${rlde.getAssessment().getJustification()}"
                        name="assessment_Justification"/>
                </td></tr>
                <c:if test="${user.canVIEW_FULL_SHEET()}">
                    <tr class="section9"><td class="title">9.4</td><td><fmt:message key="DataSheet.label.9.4" /></td><td>
                        <table class="subtable">
                            <tr>
                                <td class="title">9.4.1</td>
                                <td><fmt:message key="DataSheet.label.9.4.1" /></td>
                                <td>
                                <c:if test="${user.canEDIT_9_1_2_3_4()}">
                                    <select name="assessment_PropaguleImmigration">
                                        <c:forEach var="tmp" items="${assessment_RegionalAssessment}">
                                            <c:if test="${rlde.getAssessment().getPropaguleImmigration().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}" selected="selected">${tmp.getLabel()}</option>
                                            </c:if>
                                            <c:if test="${!rlde.getAssessment().getPropaguleImmigration().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}">${tmp.getLabel()}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </c:if>
                                <c:if test="${!user.canEDIT_9_1_2_3_4()}">
                                    ${rlde.getAssessment().getPropaguleImmigration().getLabel()}
                                </c:if>
                                </td>
                            </tr>
                            <tr>
                                <td class="title">9.4.2</td>
                                <td><fmt:message key="DataSheet.label.9.4.2" /></td>
                                <td>
                                <c:if test="${user.canEDIT_9_1_2_3_4()}">
                                    <select name="assessment_DecreaseImmigration">
                                        <c:forEach var="tmp" items="${assessment_RegionalAssessment}">
                                            <c:if test="${rlde.getAssessment().getDecreaseImmigration().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}" selected="selected">${tmp.getLabel()}</option>
                                            </c:if>
                                            <c:if test="${!rlde.getAssessment().getDecreaseImmigration().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}">${tmp.getLabel()}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </c:if>
                                <c:if test="${!user.canEDIT_9_1_2_3_4()}">
                                    ${rlde.getAssessment().getDecreaseImmigration().getLabel()}
                                </c:if>
                                </td>
                            </tr>
                            <tr>
                                <td class="title">9.4.3</td>
                                <td><fmt:message key="DataSheet.label.9.4.3" /></td>
                                <td>
                                <c:if test="${user.canEDIT_9_1_2_3_4()}">
                                    <select name="assessment_IsSink">
                                        <c:forEach var="tmp" items="${assessment_RegionalAssessment}">
                                            <c:if test="${rlde.getAssessment().getIsSink().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}" selected="selected">${tmp.getLabel()}</option>
                                            </c:if>
                                            <c:if test="${!rlde.getAssessment().getIsSink().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}">${tmp.getLabel()}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </c:if>
                                <c:if test="${!user.canEDIT_9_1_2_3_4()}">
                                    ${rlde.getAssessment().getIsSink().getLabel()}
                                </c:if>
                                </td>
                            </tr>
                            <tr>
                                <td class="title" rowspan="2">9.4.4</td>
                                <td><fmt:message key="DataSheet.label.9.4.4" /></td>
                                <td>
                                <c:if test="${user.canEDIT_9_1_2_3_4()}">
                                    <select name="assessment_UpDownListing">
                                        <c:forEach var="tmp" items="${assessment_UpDownListing}">
                                            <c:if test="${rlde.getAssessment().getUpDownListing().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}" selected="selected">${tmp.getLabel()}</option>
                                            </c:if>
                                            <c:if test="${!rlde.getAssessment().getUpDownListing().toString().equals(tmp.toString())}">
                                                <option value="${tmp.toString()}">${tmp.getLabel()}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </c:if>
                                <c:if test="${!user.canEDIT_9_1_2_3_4()}">
                                    ${rlde.getAssessment().getUpDownListing().getLabel()}
                                </c:if>
                                </td>
                            </tr>
                            <tr><td style="width:auto">Suggested action</td><td>${assessment_UpDownList}</td></tr>
                            <tr>
                                <td class="title">9.4.5</td>
                                <td><fmt:message key="DataSheet.label.9.4.5" /></td>
                                <td>
                                    <t:editabletext
                                        privilege="${user.canEDIT_9_1_2_3_4() || user.canEDIT_9_3_9_45()}"
                                        value="${rlde.getAssessment().getUpDownListingJustification()}"
                                        name="assessment_UpDownListingJustification"/>
                                </td>
                            </tr>
                            <tr>
                                <td class="title">9.4.6</td>
                                <td><fmt:message key="DataSheet.label.9.4.6" /></td>
                                <td>
                                    ${rlde.getAssessment().getFinalJustification()}
<!--                                    <t:editabletext
                                        privilege="${user.canEDIT_9_1_2_3_4() || user.canEDIT_9_3_9_45()}"
                                        value="${rlde.getAssessment().getFinalJustification()}"
                                        name="assessment_FinalJustification"/> -->
                                </td>
                            </tr>
                        </table>
                    </td></tr>

                    <tr class="section9"><td class="title">9.5</td><td><fmt:message key="DataSheet.label.9.5" /></td><td>
                        <table><tr><th>Year published</th><th>Category</th></tr>
                        <c:if test="${user.canEDIT_9_5_9_6_9_61_9_91()}">
                        <c:forEach var="tmp" items="${previousAssessments}">
                            <tr>
                                <td><input name="assessment_PreviousAssessmentListYear" type="number" min="1900" max="2020" value="${tmp.getYear()}"/></td>
                                <td><select name="assessment_PreviousAssessmentListCategory">
                                    <option value="">(not assigned)</option>
                                    <c:forEach var="tmp1" items="${assessment_Category}">
                                        <c:if test="${tmp.getCategory().toString().equals(tmp1.toString())}">
                                            <option value="${tmp1.toString()}" selected="selected">${tmp1.getLabel()}</option>
                                        </c:if>
                                        <c:if test="${!tmp.getCategory().toString().equals(tmp1.toString())}">
                                            <option value="${tmp1.toString()}">${tmp1.getLabel()}</option>
                                        </c:if>
                                    </c:forEach>
                                </select></td>
                            </tr>
                        </c:forEach>
                        </c:if>
                        <c:if test="${!user.canEDIT_9_5_9_6_9_61_9_91()}">
                        <c:forEach var="tmp" items="${previousAssessments}">
                            <tr><td>${tmp.getYear()}</td><td>${tmp.getCategory().getLabel()}</td></tr>
                        </c:forEach>
                        </c:if>
                        </table>
                    </td></tr>
                    <tr class="section9"><td class="title">9.6</td><td><fmt:message key="DataSheet.label.9.6" /></td>
                    <c:if test="${user.canEDIT_9_5_9_6_9_61_9_91()}">
                        <td>
                            <div class="multiplechooser left" id="textauthors">
                                <input type="hidden" name="assessment_Authors" value=""/>
                            <c:forEach var="tmp" items="${authors}">
                                <input type="checkbox" name="assessment_Authors" id="aa_${tmp}" value="${tmp}" checked="checked"/>
                                <label for="aa_${tmp}" class="wordtag togglebutton">${userMap.get(tmp)}</label>
                            </c:forEach>
                            </div>
                            <div class="withsuggestions">
                                <input type="text" class="nochangeevent" name="query" placeholder="type first letters" autocomplete="off" id="authorbox"/>
                                <div id="authorsuggestions"></div>
                            </div>
                            <input type="button" value="Create new..." class="button" id="newauthor"/>
                        </td>
                    </c:if>
                    <c:if test="${!user.canEDIT_9_5_9_6_9_61_9_91()}">
                        <td>
                            <c:forEach var="tmp" items="${rlde.getAssessment().getAuthors()}">
                            <c:if test="${tmp != null}">
                                <div class="wordtag">${userMap.get(tmp)}</div>
                            </c:if>
                            </c:forEach>
                        </td>
                    </c:if>
                    </tr>
                    <tr class="section9"><td class="title">9.6.1</td><td><fmt:message key="DataSheet.label.9.6.1" /></td><td>
                    <c:if test="${user.canEDIT_9_5_9_6_9_61_9_91()}">
                        <input name="assessment_Collaborators" type="text" class="longbox" value="${rlde.getAssessment().getCollaborators()}"/>
                    </c:if>
                    <c:if test="${!user.canEDIT_9_5_9_6_9_61_9_91()}">
                        ${rlde.getAssessment().getCollaborators()}
                    </c:if>
                    </td></tr>
                    <tr class="section9"><td class="title">9.7</td><td><fmt:message key="DataSheet.label.9.7" /></td>
                    <c:if test="${user.canEDIT_9_7_9_92()}">
                        <td>
                            <div class="multiplechooser left" id="assessors">
                            <input type="hidden" name="assessment_Evaluator" value=""/>
                            <c:forEach var="tmp" items="${evaluator}">
                                <input type="checkbox" name="assessment_Evaluator" id="aas_${tmp}" value="${tmp}" checked="checked"/>
                                <label for="aas_${tmp}" class="wordtag togglebutton">${userMap.get(tmp)}</label>
                            </c:forEach>
                            </div>
                            <div class="withsuggestions">
                                <input type="text" class="nochangeevent" name="query" placeholder="type first letters" autocomplete="off" id="assessorbox"/>
                                <div id="assessorsuggestions"></div>
                            </div>
                            <input type="button" value="Create new..." class="button" id="newevaluator"/>
                        </td>
                    </c:if>
                    <c:if test="${!user.canEDIT_9_7_9_92()}">
                        <td>
                            <c:forEach var="tmp" items="${rlde.getAssessment().getEvaluator()}">
                            <c:if test="${tmp != null}">
                                <div class="wordtag">${userMap.get(tmp)}</div>
                            </c:if>
                            </c:forEach>
                        </td>
                    </c:if>
                    </tr>
                    <tr class="section9"><td class="title">9.8</td><td><fmt:message key="DataSheet.label.9.8" /></td>
                    <c:if test="${user.canEDIT_9_8_9_93()}">
                        <td>
                            <div class="multiplechooser left" id="reviewers">
                            <input type="hidden" name="assessment_Reviewer" value=""/>
                            <c:forEach var="tmp" items="${reviewer}">
                                <input type="checkbox" name="assessment_Reviewer" id="are_${tmp}" value="${tmp}" checked="checked"/>
                                <label for="are_${tmp}" class="wordtag togglebutton">${userMap.get(tmp)}</label>
                            </c:forEach>
                            </div>
                            <div class="withsuggestions">
                                <input type="text" class="nochangeevent" name="query" placeholder="type first letters" autocomplete="off" id="reviewerbox"/>
                                <div id="reviewersuggestions"></div>
                            </div>
                            <input type="button" value="Create new..." class="button" id="newreviewer"/>
                        </td>
                    </c:if>
                    <c:if test="${!user.canEDIT_9_8_9_93()}">
                        <td>
                            <c:forEach var="tmp" items="${rlde.getAssessment().getReviewer()}">
                            <c:if test="${tmp != null}">
                                <div class="wordtag">${userMap.get(tmp)}</div>
                            </c:if>
                            </c:forEach>
                        </td>
                    </c:if>
                    </tr>
                    <tr class="section9"><td class="title">9.9</td><td><fmt:message key="DataSheet.label.9.9" /></td><td>
                        <table class="subtable">
                            <tr><td class="title">9.9.1</td><td><fmt:message key="DataSheet.label.9.9.1" /></td><td>
                            <c:if test="${user.canEDIT_9_5_9_6_9_61_9_91()}">
                                <select name="assessment_TextStatus">
                                    <c:forEach var="tmp" items="${assessment_TextStatus}">
                                        <c:if test="${rlde.getAssessment().getTextStatus().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected"><fmt:message key="${tmp.getLabel()}"/></option>
                                        </c:if>
                                        <c:if test="${!rlde.getAssessment().getTextStatus().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}"><fmt:message key="${tmp.getLabel()}"/></option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </c:if>
                            <c:if test="${!user.canEDIT_9_5_9_6_9_61_9_91()}">
                                <fmt:message key="${rlde.getAssessment().getTextStatus().getLabel()}"/>
                            </c:if>
                            </td></tr>
                            <tr><td class="title">9.9.2</td><td><fmt:message key="DataSheet.label.9.9.2" /></td><td>
                            <c:if test="${user.canEDIT_9_7_9_92()}">
                                <select name="assessment_AssessmentStatus">
                                    <c:forEach var="tmp" items="${assessment_AssessmentStatus}">
                                        <c:if test="${rlde.getAssessment().getAssessmentStatus().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected"><fmt:message key="${tmp.getLabel()}"/></option>
                                        </c:if>
                                        <c:if test="${!rlde.getAssessment().getAssessmentStatus().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}"><fmt:message key="${tmp.getLabel()}"/></option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </c:if>
                            <c:if test="${!user.canEDIT_9_7_9_92()}">
                                <fmt:message key="${rlde.getAssessment().getAssessmentStatus().getLabel()}"/>
                            </c:if>
                            </td></tr>
                            <tr><td class="title">9.9.3</td><td><fmt:message key="DataSheet.label.9.9.3" /></td><td>
                            <c:if test="${user.canEDIT_9_8_9_93()}">
                                <select name="assessment_ReviewStatus">
                                    <c:forEach var="tmp" items="${assessment_ReviewStatus}">
                                        <c:if test="${rlde.getAssessment().getReviewStatus().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected"><fmt:message key="${tmp.getLabel()}"/></option>
                                        </c:if>
                                        <c:if test="${!rlde.getAssessment().getReviewStatus().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}"><fmt:message key="${tmp.getLabel()}"/></option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </c:if>
                            <c:if test="${!user.canEDIT_9_8_9_93()}">
                                <fmt:message key="${rlde.getAssessment().getReviewStatus().getLabel()}"/>
                            </c:if>
                            </td></tr>
                            <tr><td class="title">9.9.4</td><td><fmt:message key="DataSheet.label.9.9.4" /></td><td>
                            <c:if test="${user.canEDIT_9_9_4()}">
                                <select name="assessment_PublicationStatus">
                                    <c:forEach var="tmp" items="${assessment_PublicationStatus}">
                                        <c:if test="${rlde.getAssessment().getPublicationStatus().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}" selected="selected"><fmt:message key="${tmp.getLabel()}"/></option>
                                        </c:if>
                                        <c:if test="${!rlde.getAssessment().getPublicationStatus().toString().equals(tmp.toString())}">
                                            <option value="${tmp.toString()}"><fmt:message key="${tmp.getLabel()}"/></option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </c:if>
                            <c:if test="${!user.canEDIT_9_9_4()}">
                                <fmt:message key="${rlde.getAssessment().getPublicationStatus().getLabel()}"/>
                            </c:if>
                            </td></tr>
                        </table>
                    </td></tr>
                    <tr class="section9"><td class="title">9.10</td><td><fmt:message key="DataSheet.label.9.10" /></td><td>
                        ${rlde.getDateAssessed()}
                    </td></tr>
                    <tr class="section9"><td class="title">9.11</td><td><fmt:message key="DataSheet.label.9.11" /></td><td>
                        ${rlde.getDatePublished()}
                    </td></tr>
                </c:if>
                <tr class="section9"><td class="title">9.12</td><td><fmt:message key="DataSheet.label.9.12" /></td><td>${citation}</td></tr>
                <c:if test="${!multipletaxa}">
                <tr class="section9"><td class="title">9.13</td><td><fmt:message key="DataSheet.label.9.13" /></td><td>
                <table class="subtable">
                    <tr><th>Date saved</th><th>User</th><th>Number of edits</th></tr>
                <c:forEach var="rev" items="${revisions}">
                    <tr><td>${rev.getKey().getFormattedDateSaved()}</td><td>${userMap.get(rev.getKey().getUser())}</td><td>${rev.getValue()}</td></tr>
                </c:forEach>
                </table>
                </td></tr>
                </c:if>
            </table>
        </form>
        <c:if test="${!multipletaxa}">
        <c:if test="${user.canCREATE_REDLIST_DATASETS()}">
        <h1><fmt:message key="TaxonIndex.admin.1"/></h1>
        <form class="poster" data-path="/floraon/redlist/api/removetaxent" data-refresh="false" data-callback="?w=main">
            <input type="hidden" name="id" value="${rlde.getTaxEntID()}"/>
            <input type="hidden" name="territory" value="${territory}"/>
            <input type="submit" value="Delete this data sheet and remove taxon from red list" class="textbutton"/>
        </form>
        </c:if>
        </c:if>
    </c:when>

    <c:when test="${what=='taxonrecords'}">
        <c:if test="${!user.canVIEW_OCCURRENCES()}">
            <div class="warning"><b>You&#8217;re not authorized to enter this page</b></div>
        </c:if>

        <c:if test="${user.canVIEW_OCCURRENCES()}">
            <a href="?w=taxon&id=${taxon._getIDURLEncoded()}">&lt;&lt; voltar à ficha</a>
            <h1>${taxon.getFullName(true)}</h1>
            <c:if test="${occurrences == null}">
                <div class="warning"><p><fmt:message key="DataSheet.msg.warning"/></p>This taxon has no correspondence in Flora-On, please contact the checklist administrator</div>
            </c:if>
            <h2>${occurrences.size()} occurrences</h2>

            <c:if test="${user.canDOWNLOAD_OCCURRENCES()}">
                <div class="button anchorbutton"><a href="?w=downloadtaxonrecords&id=${taxon._getIDURLEncoded()}"><fmt:message key="button.1" /></a></div>
            </c:if>

            <c:set var="pgroup" value="${param.group==null ? '' : (param.group==500 ? '&group=500' : '&group=2500')}" />
            <c:set var="pview" value="${param.view==null ? '' : '&view=all'}" />

            <c:if test="${param.view == 'all'}"><div class="button anchorbutton selected"><a href="?w=taxonrecords&id=${taxon._getIDURLEncoded()}${pgroup}"><fmt:message key="button.4" /></a></div></c:if>
            <c:if test="${param.view == null}"><div class="button anchorbutton"><a href="?w=taxonrecords&id=${taxon._getIDURLEncoded()}${pgroup}&view=all"><fmt:message key="button.4" /></a></div></c:if>
            <div class="button-section">
                <fmt:message key="button.2" /><br/>
                <div class="button anchorbutton ${param.group==null ? 'selected' : ''}"><a href="?w=taxonrecords&id=${taxon._getIDURLEncoded()}${pview}"><fmt:message key="button.3" /></a></div>
                <div class="button anchorbutton ${param.group==500 ? 'selected' : ''}"><a href="?w=taxonrecords&id=${taxon._getIDURLEncoded()}&group=500${pview}">&lt; 500m</a></div>
                <div class="button anchorbutton ${param.group==2500 ? 'selected' : ''}"><a href="?w=taxonrecords&id=${taxon._getIDURLEncoded()}&group=2500${pview}">&lt; 2500m</a></div>
            </div>
            <c:if test="${param.view == 'all'}"><p><fmt:message key="button.4a" /></p></c:if>
            <c:if test="${param.view == null}"><p><fmt:message key="button.4b" /></p></c:if>
            <c:if test="${param.group == 500}"><p><fmt:message key="button.2a" /></p></c:if>
            <c:if test="${param.group == 2500}"><p><fmt:message key="button.2b" /></p></c:if>
            <c:if test="${param.group > 0}"><p>${clustoccurrences.size()} grupos.</p></c:if>
            <table id="taxonrecordtable" class="smalltext ${param.group==null ? 'sortable' : ''}" id="recordtable">
                <thead>
                    <tr><th>Taxon</th><c:if test="${user.canDOWNLOAD_OCCURRENCES()}"><th>Latitude</th><th>Longitude</th></c:if><th>Date</th>
                    <th>Author</th><th style="width:180px">Notes</th><th>Locality</th><th>Precision</th><th>Confid</th><th>Pheno</th>
                    <th>Ameaças</th><th>Nº ind</th><th>Met</th><th>Fot</th><th>Colh</th><th>Excl</th><th>CodHerb</th>
                    </tr>
                </thead>
                <c:if test="${param.group > 0}">
                <c:forEach var="entr" items="${clustoccurrences.iterator()}">
                    <tr><td class="separator" colspan="17">&nbsp;</td></tr>
                    <c:forEach var="occ" items="${entr.getValue()}">
                    <tr data-mgrs="${occ._getMGRSString(5000)}">
                        <!--<td>${occ.getDataSource()}</td>-->
                        <td><i>${occ.getOccurrence().getVerbTaxon()}</i></td>
                        <c:if test="${user.canDOWNLOAD_OCCURRENCES()}">
                        <td><fmt:formatNumber value="${occ.getLatitude()}" maxFractionDigits="4"/></td>
                        <td><fmt:formatNumber value="${occ.getLongitude()}" maxFractionDigits="4"/></td>
                        </c:if>
                        <td sorttable_customkey="${occ._getDateYMD()}">${occ._getDate()}</td>
                        <td>${occ._getObserverNames()[0]}</td>
                        <td style="width:180px">${occ.getOccurrence().getComment()}</td>
                        <td>${occ.getLocality()} ${occ.getVerbLocality()}</td>
                        <td>${occ.getPrecision()}</td>
                        <td>${occ.getOccurrence().getConfidence()}</td>
                        <td>${occ.getOccurrence().getPhenoState()}</td>
                        <td>${occ.getThreats()} ${occ.getOccurrence().getSpecificThreats()}</td>
                        <td>${occ.getOccurrence().getAbundance()}</td>
                        <td>${occ.getOccurrence().getTypeOfEstimate()}</td>
                        <td>${occ.getOccurrence().getHasPhoto().getLabel()}</td>
                        <td>${occ.getOccurrence().getHasSpecimen()}</td>
                        <td>${occ.getOccurrence()._getPresenceStatusLabel()}</td>
                        <td>${occ.getOccurrence().getAccession()}</td>
                    </tr>
                    </c:forEach>
                </c:forEach>
                </c:if>
                <c:if test="${param.group == null}">
                <c:forEach var="occ" items="${occurrences.iterator()}">
                    <tr data-mgrs="${occ._getMGRSString(5000)}">
                        <!--<td>${occ.getDataSource()}</td>-->
                        <td><i>${occ.getOccurrence().getVerbTaxon()}</i></td>
                        <c:if test="${user.canDOWNLOAD_OCCURRENCES()}">
                        <td><fmt:formatNumber value="${occ.getLatitude()}" maxFractionDigits="4"/></td>
                        <td><fmt:formatNumber value="${occ.getLongitude()}" maxFractionDigits="4"/></td>
                        </c:if>
                        <td sorttable_customkey="${occ._getDateYMD()}">${occ._getDate()}</td>
                        <td>${occ._getObserverNames()[0]}</td>
                        <td style="width:180px">${occ.getOccurrence().getComment()}</td>
                        <td>${occ.getLocality()} ${occ.getVerbLocality()}</td>
                        <td>${occ.getPrecision()}</td>
                        <td>${occ.getOccurrence().getConfidence()}</td>
                        <td>${occ.getOccurrence().getPhenoState()}</td>
                        <td>${occ.getThreats()} ${occ.getOccurrence().getSpecificThreats()}</td>
                        <td>${occ.getOccurrence().getAbundance()}</td>
                        <td>${occ.getOccurrence().getTypeOfEstimate()}</td>
                        <td>${occ.getOccurrence().getHasPhoto().getLabel()}</td>
                        <td>${occ.getOccurrence().getHasSpecimen()}</td>
                        <td>${occ.getOccurrence()._getPresenceStatusLabel()}</td>
                        <td>${occ.getOccurrence().getAccession()}</td>
                    </tr>
                </c:forEach>
                </c:if>
            </table>
            <!--<t:ajaxloadhtml url="https://cloud161.ncg.ingrid.pt:8443/floraon/redlist/lu?w=svgmap&taxon=${taxon._getIDURLEncoded()}&basemap=1" width="100px" height="100px" classes="taxonrecordmap" text="carregando mapa"/>-->
            <!--<t:ajaxloadhtml url="http://localhost:8080/floraon/api/svgmap?basemap=1&size=5000&border=0&taxon=${taxon._getIDURLEncoded()}" width="100px" height="100px" text="carregando mapa" id="taxonrecords-map"/>-->
            <t:ajaxloadhtml url="https://cloud161.ncg.ingrid.pt:8443/floraon/api/svgmap?basemap=1&size=5000&border=0&taxon=${taxon._getIDURLEncoded()}" width="100px" height="100px" text="carregando mapa" id="taxonrecords-map"/>
        </c:if>
    </c:when>

    <c:when test="${what=='users'}">
        <c:if test="${!user.canMANAGE_REDLIST_USERS()}">
            <div class="warning"><b>You&#8217;re not authorized to enter this page</b></div>
        </c:if>
        <c:if test="${user.canMANAGE_REDLIST_USERS()}">
            <h1>User management</h1>
            <h2>Existing users</h2>
            <table class="sortable smalltext">
                <tr><th>Name</th><th>Global privileges</th><th>Taxon-specific privileges</th><th>Responsible for texts</th><th>Responsible for assessment</th><th>Responsible for revision</th><th></th></tr>
                <c:forEach var="tmp" items="${users}">
                    <c:if test="${user.getUserType() == 'ADMINISTRATOR' || (user.getUserType() != 'ADMINISTRATOR' && tmp.getUserType() != 'ADMINISTRATOR')}">
                    <tr><td>${tmp.getName()}</td>
                        <td>
                        <c:forEach var="tmp1" items="${tmp.getPrivileges()}">
                            <div class="wordtag">${tmp1.getLabel()}</div>
                        </c:forEach>
                        </td>
                        <td><ul>
                        <c:forEach var="tmp2" items="${tmp.getTaxonPrivileges()}">
                            <li>
                            <c:if test="${fn:length(tmp2.getApplicableTaxa()) > 1}">
                            <c:forEach var="tmp3" begin="0" end="${fn:length(tmp2.getApplicableTaxa()) - 2}">
                                <i>${taxonMap.get(tmp2.getApplicableTaxa()[tmp3])}</i>,&nbsp;
                            </c:forEach>
                            </c:if>
                                <i>${taxonMap.get(tmp2.getApplicableTaxa()[fn:length(tmp2.getApplicableTaxa()) - 1])}</i>
                            </li>
                        </c:forEach>
                        </ul></td>
                        <td class="bignumber">${responsibleTextCounter.get(tmp.getID())}</td>
                        <td class="bignumber">${responsibleAssessmentCounter.get(tmp.getID())}</td>
                        <td class="bignumber">${responsibleRevisionCounter.get(tmp.getID())}</td>
                        <td><div class="button anchorbutton"><a href="?w=edituser&amp;user=${tmp._getIDURLEncoded()}">edit user</a></div></td>
                    </tr>
                    </c:if>
                </c:forEach>
            </table>
            <h2>Create new user</h2>
            <form class="poster" data-path="/floraon/admin/createuser">
                <table>
                    <tr><td class="title">Username</td><td><input type="text" name="userName"/></td></tr>
                    <tr><td class="title">Person name</td><td><input type="text" name="name"/></td></tr>
                    <tr>
                        <td class="title">Global privileges</td>
                        <td class="multiplechooser">
                            <c:forEach var="tmp" items="${redlistprivileges}">
                                <input type="checkbox" name="${tmp}" id="priv_${tmp}"/><label for="priv_${tmp}" class="wordtag togglebutton">${tmp.getLabel()}</label>
                            </c:forEach>
                        </td>
                    </tr>
                </table>
                <input type="submit" value="Create" class="textbutton"/>
            </form>
        </c:if>
    </c:when>
    <c:when test="${what=='edituser'}">
        <c:if test="${!user.canMANAGE_REDLIST_USERS()}">
            <div class="warning"><b>You&#8217;re not authorized to enter this page</b></div>
        </c:if>
        <c:if test="${user.canMANAGE_REDLIST_USERS()}">
            <c:if test="${requesteduser == null}">
                <h1>User not found</h1>
                <h2><a href="?w=users">go back</a></h2>
            </c:if>
            <c:if test="${requesteduser != null}">
                <h1>${requesteduser.getFullName()} <span class="info">${requesteduser.getUserType()} ${requesteduser.getID()}</span></h1>
                <form class="poster" data-path="/floraon/admin/deleteuser" style="float:right" data-callback="?w=users">
                    <input type="hidden" name="databaseId" value="${requesteduser.getID()}"/>
                    <input type="submit" value="Delete user" class="textbutton"/>
                </form>
                <form class="poster" data-path="/floraon/admin/newpassword" style="float:right" data-callback="?w=users">
                    <input type="hidden" name="databaseId" value="${requesteduser.getID()}"/>
                    <input type="hidden" name="userName" value="${requesteduser.getUserName()}"/>
                    <input type="hidden" name="userType" value="${requesteduser.getUserType()}"/>
                    <input type="submit" value="Generate new password" class="textbutton"/>
                </form>
                <h2>Edit user</h2>
                <form class="poster" data-path="/floraon/admin/updateuser" data-callback="?w=users">
                    <input type="hidden" name="databaseId" value="${requesteduser.getID()}"/>
                    <input type="hidden" name="userType" value="${requesteduser.getUserType()}"/>
                    <table>
                        <tr><td class="title">Username</td><td><input type="text" name="userName" value="${requesteduser.getUserName()}"/></td></tr>
                        <tr><td class="title">Person name</td><td><input type="text" name="name" value="${requesteduser.getFullName()}"/></td></tr>
                        <tr>
                            <td class="title">Global privileges (apply to all taxa)</td>
                            <td class="multiplechooser">
                                <c:forEach var="tmp" items="${redlistprivileges}">
                                    <c:if test="${requesteduser.hasAssignedPrivilege(tmp)}">
                                        <input type="checkbox" name="${tmp}" id="priv_${tmp}" checked="checked"/><label for="priv_${tmp}" class="wordtag togglebutton">${tmp.getLabel()}</label>
                                    </c:if>
                                    <c:if test="${!requesteduser.hasAssignedPrivilege(tmp)}">
                                        <input type="checkbox" name="${tmp}" id="priv_${tmp}"/><label for="priv_${tmp}" class="wordtag togglebutton">${tmp.getLabel()}</label>
                                    </c:if>
                                </c:forEach>
                            </td>
                        </tr>
                        <tr><td colspan="2"><input type="submit" value="Update user" class="textbutton"/></td></tr>
                    </table>
                </form>
                <h2>User polygons</h2>
                <table>
                    <tr><th>Attributes</th><th>Nr. vertices</th></tr>
                    <c:forEach var="pol" items="${userPolygon}" >
                        <tr><td>${pol.getValue().getProperties().values().toString()}</td><td>${pol.getValue().size()}</td></tr>
                    </c:forEach>
                </table>
                <form class="poster" data-path="/floraon/admin/setuserpolygon" data-callback="?w=users">
                    <input type="hidden" name="databaseId" value="${requesteduser.getID()}"/>
                    <table>
                        <tr><td class="title">Set/replace user area with a polygon file (GeoJSON)</td>
                        <td><input type="file" name="userarea"/><input type="submit" value="Set area" class="textbutton"/></td>
                    </table>
                </form>
                <form class="poster" data-path="/floraon/admin/setuserpolygon" data-callback="?w=users">
                    <input type="hidden" name="databaseId" value="${requesteduser.getID()}"/>
                    <input type="hidden" name="userarea" value=""/>
                    <input type="submit" value="Delete all areas" class="textbutton"/>
                </form>
                <h2>Taxon-specific privileges</h2>
                <c:if test="${tsprivileges.size() > 0}">
                <h3>Existing privilege sets</h3>
                <table>
                    <thead><tr><th>Taxa</th><th>Privileges</th><th></th></tr></thead>
                    <tbody>
                    <c:forEach var="tsp" items="${tsprivileges}" varStatus="loop">
                        <tr>
                            <td style="width:20%; vertical-align:top;">
                                <ul>
                                <c:forEach var="tax" items="${tsp.getApplicableTaxa()}">
                                    <li>
                                        ${taxonMap.get(tax)}
                                        <form class="poster inlineblock" data-path="/floraon/admin/removetaxonfromset" data-refresh="true">
                                            <input type="submit" value="Remove" class="textbutton"/>
                                            <input type="hidden" name="userId" value="${requesteduser.getID()}"/>
                                            <input type="hidden" name="taxEntId" value="${tax}"/>
                                            <input type="hidden" name="index" value="${loop.index}"/>
                                        </form>
                                    </li>
                                </c:forEach>
                                </ul>
                                <form class="poster" data-path="/floraon/admin/updatetaxonprivileges" data-refresh="true">
                                    <input type="hidden" name="userId" value="${requesteduser.getID()}"/>
                                    <input type="hidden" name="privilegeSet" value="${loop.index}"/>
                                    <div class="withsuggestions">
                                        <input type="text" name="query" class="nochangeevent" placeholder="<fmt:message key="DataSheet.msg.typeletters"/>" autocomplete="off" id="taxonbox_group_${loop.index}"/>
                                        <div id="suggestions_group_${loop.index}"></div>
                                    </div>
                                    <div class="multiplechooser" id="taxa_group_${loop.index}"></div>
                                    <input type="submit" value="Add taxa to this group" class="textbutton"/>
                                </form>
                            </td><td>
                            <c:forEach var="pri" items="${tsp.getPrivileges()}">
                                <div class="wordtag">${pri.toString()}</div>
                            </c:forEach>
                            </td>
                            <td style="width:0;">
                                <form class="poster" data-path="/floraon/admin/removetaxonprivileges" data-refresh="true">
                                    <input type="hidden" name="userId" value="${requesteduser.getID()}"/>
                                    <input type="hidden" name="index" value="${loop.index}"/>
                                    <input type="submit" value="Remove this privilege set" class="textbutton"/>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
                </table>
                </c:if>
                <h3>Add a new set of privileges to specific taxa</h3>
                <form class="poster" data-path="/floraon/admin/addtaxonprivileges" data-refresh="true">
                    <input type="hidden" name="userId" value="${requesteduser.getID()}"/>
                    <table>
                        <thead><tr><th>Taxa</th><th>Privileges</th></tr></thead>
                        <tbody>
                            <tr>
                                <td style="width:20%; vertical-align:top;">
                                    <div class="multiplechooser" id="taxonprivileges"></div>
                                    <div class="withsuggestions">
                                        <input type="text" name="query" class="nochangeevent" placeholder="<fmt:message key="DataSheet.msg.typeletters"/>" autocomplete="off" id="taxonbox"/>
                                        <div id="suggestions"></div>
                                    </div>
                                </td>
                                <td class="multiplechooser">
                                    <c:forEach var="tmp" items="${redlisttaxonprivileges}">
                                        <input type="checkbox" name="taxonPrivileges" value="${tmp}" id="tspriv_${tmp}"/><label for="tspriv_${tmp}" class="wordtag togglebutton">${tmp.getLabel()}</label>
                                    </c:forEach>
                                </td>
                            </tr>
                        <tr><td colspan="2"><input type="submit" value="Add privileges for these taxa" class="textbutton"/></td></tr>
                        </tbody>
                    </table>
                </form>
            </c:if>
        </c:if>
    </c:when>

    <c:when test="${what=='report'}">
        <jsp:include page="technicalreport.jsp"></jsp:include>
    </c:when>
    </c:choose>
    </div>
</div>

</body>
</html>
