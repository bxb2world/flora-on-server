<%@ tag description="Occurrence table row" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ attribute name="flavour" required="false" %>
<%@ attribute name="occ" required="false" type="pt.floraon.occurrences.entities.Inventory"%>
<%@ attribute name="userMap" required="false" type="java.util.Map" %>
<%@ attribute name="locked" required="false" type="java.lang.Boolean" %>
<%@ attribute name="symbol" required="false" %>

<c:if test="${occ == null}">
<tr class="geoelement dummy id1holder">
    <td class="selectcol clickable"><div class="selectbutton"></div></td>
    <c:choose>
    <c:when test="${param.flavour == null || param.flavour == '' || param.flavour == 'simple'}">
    <td class="taxon editable" data-name="taxa"></td>
    <td class="editable" data-name="confidence"></td>
    <td class="editable coordinates" data-name="coordinates"></td>
    <td class="editable" data-name="precision"></td>
    <td class="editable" data-name="comment"></td>
    <td class="editable" data-name="privateNote"></td>
    <td class="editable" data-name="date"></td>
    <td class="editable" data-name="phenoState"></td>
    <td class="editable authors" data-name="observers"></td>
    </c:when>

    <c:when test="${param.flavour == 'redlist'}">
    <td class="editable" data-name="date"></td>
    <td class="editable authors hideincompactview" data-name="observers"></td>
    <td class="editable coordinates hideincompactview" data-name="coordinates"></td>
    <td class="editable" data-name="locality"></td>
    <td class="editable" data-name="precision"></td>
    <td class="editable" data-name="gpsCode"></td>
    <td class="taxon editable" data-name="taxa"></td>
    <td class="editable hideincompactview" data-name="presenceStatus"></td>
    <td class="editable hideincompactview" data-name="confidence"></td>
    <td class="editable hideincompactview" data-name="phenoState"></td>
    <td class="editable hideincompactview" data-name="abundance"></td>
    <td class="editable hideincompactview" data-name="typeOfEstimate"></td>
    <td class="editable hideincompactview" data-name="hasPhoto"></td>
    <td class="editable hideincompactview" data-name="hasSpecimen"></td>
    <td class="threats editable" data-name="specificThreats"></td>
    <td class="editable" data-name="comment"></td>
    <td class="editable" data-name="privateNote"></td>
    </c:when>

    <c:when test="${param.flavour == 'herbarium'}">
    <td class="editable" data-name="accession"></td>
    <td class="taxon editable" data-name="taxa"></td>
    <td class="editable" data-name="presenceStatus"></td>
    <td class="editable coordinates" data-name="coordinates"></td>
    <td class="editable" data-name="precision"></td>
    <td class="editable" data-name="verbLocality"></td>
    <td class="editable" data-name="date"></td>
    <td class="editable authors" data-name="collectors"></td>
    <td class="editable" data-name="labelData"></td>
    <td class="editable" data-name="privateNote"></td>
    <!--<td class="editable authors" data-name="determiners"></td>-->
    </c:when>

    <c:when test="${flavour == 'management'}">
    <td class=""></td>
    <td class="editable coordinates" data-name="coordinates"></td>
    <td class="editable" data-name="precision"></td>
    <td class="taxon editable" data-name="taxa"></td>
    <td class="editable hideincompactview" data-name="confidence"></td>
    <td class="editable" data-name="date"></td>
    <td class=""></th>
    <td class="editable hideincompactview" data-name="presenceStatus"></td>
    <td class=""></th>
    <td class=""></th>
    <td class="editable" data-name="privateNote"></td>
    <td class="editable hideincompactview" data-name="abundance"></td>
    <td class="editable hideincompactview" data-name="typeOfEstimate"></td>
    <td class="editable hideincompactview" data-name="hasPhoto"></td>
    <td class="editable hideincompactview" data-name="hasSpecimen"></td>
    <td class="threats editable" data-name="specificThreats"></td>
    <td class="editable hideincompactview" data-name="phenoState"></td>
    </c:when>

    </c:choose>
</tr>
</c:if>

<c:if test="${occ != null}">
<c:set var="unmatched" value="${occ._getTaxa()[0].getTaxEnt() == null ? 'unmatched' : ''}"/>
<c:set var="editable" value="${locked ? '' : 'editable'}"/>
<c:set var="symbol" value="${symbol == null ? (occ.getYear() != null && occ.getYear() >= historicalYear ? 0 : 1) : symbol}"/>
<tr class="${unmatched} geoelement id1holder">
<c:set var="coordchanged" value="${occ._getTaxa()[0].getCoordinatesChanged() ? 'textemphasis' : ''}" />
    <td class="selectcol clickable">
        <input type="hidden" name="occurrenceUuid" value="${occ._getTaxa()[0].getUuid()}"/>
        <input type="hidden" name="inventoryId" value="${occ.getID()}"/>
        <div class="selectbutton"></div>
    </td>
    <c:choose>
    <c:when test="${param.flavour == null || param.flavour == '' || param.flavour == 'simple'}">
    <c:set var="taxa" value="${occ._getTaxa()[0].getTaxEnt() == null ? occ._getTaxa()[0].getVerbTaxon() : occ._getTaxa()[0].getTaxEnt().getNameWithAnnotationOnly(false)}" />
    <td class="taxon ${editable}" data-name="taxa">${taxa}</td>
    <td class="${editable}" data-name="confidence">${occ._getTaxa()[0]._getConfidenceLabel()}</td>
    <td class="${editable} coordinates" data-name="observationCoordinates" data-lat="${occ._getLatitude()}" data-lng="${occ._getLongitude()}" data-symbol="${symbol}">${occ._getCoordinates()}</td>
    <td class="${editable}" data-name="precision">${occ.getPrecision().toString()}</td>
    <td class="${editable}" data-name="comment">${occ._getTaxa()[0].getComment()}</td>
    <td class="${editable}" data-name="privateNote">${occ._getTaxa()[0].getPrivateComment()}</td>
    <td class="${editable}" data-name="date" sorttable_customkey="${occ._getDateYMD()}">${occ._getDate()}</td>
    <td class="${editable}" data-name="phenoState">${occ._getTaxa()[0]._getPhenoStateLabel()}</td>
    <td class="${editable} authors" data-name="observers"><t:usernames idarray="${occ.getObservers()}" usermap="${userMap}"/></td>
    </c:when>

    <c:when test="${param.flavour == 'redlist'}">
    <td class="${editable}" data-name="date" sorttable_customkey="${occ._getDateYMD()}">${occ._getDate()}</td>
    <td class="${editable} authors hideincompactview" data-name="observers"><t:usernames idarray="${occ.getObservers()}" usermap="${userMap}"/></td>
    <td class="${editable} coordinates hideincompactview" data-name="observationCoordinates" data-lat="${occ._getLatitude()}" data-lng="${occ._getLongitude()}" data-symbol="${symbol}">${occ._getCoordinates()}</td>
    <td class="${editable}" data-name="locality">${occ.getLocality()}</td>
    <td class="${editable}" data-name="precision">${occ.getPrecision().toString()}</td>
    <td class="${editable}" data-name="gpsCode">${occ.getCode()}</td>
    <c:set var="taxa" value="${occ._getTaxa()[0].getTaxEnt() == null ? occ._getTaxa()[0].getVerbTaxon() : occ._getTaxa()[0].getTaxEnt().getNameWithAnnotationOnly(false)}" />
    <td class="taxon ${editable}" data-name="taxa">${taxa}</td>
    <td class="${editable} hideincompactview" data-name="presenceStatus">${occ._getTaxa()[0]._getPresenceStatusLabel()}</td>
    <td class="${editable} hideincompactview" data-name="confidence">${occ._getTaxa()[0]._getConfidenceLabel()}</td>
    <td class="${editable} hideincompactview" data-name="phenoState">${occ._getTaxa()[0]._getPhenoStateLabel()}</td>
    <td class="${editable} hideincompactview" data-name="abundance"><c:if test="${occ._getTaxa()[0].getAbundance().getError() != null}"><span class="error"></c:if>${occ._getTaxa()[0].getAbundance()}<c:if test="${occ._getTaxa()[0].getAbundance().getError() != null}"></span></c:if></td>
    <td class="${editable} hideincompactview" data-name="typeOfEstimate">${occ._getTaxa()[0]._getTypeOfEstimateLabel()}</td>
    <td class="${editable} hideincompactview" data-name="hasPhoto">${occ._getTaxa()[0]._getHasPhotoLabel()}</td>
    <td class="${editable} hideincompactview" data-name="hasSpecimen">${occ._getTaxa()[0].getHasSpecimen()}</td>
    <td class="threats ${editable}" data-name="specificThreats">${occ._getTaxa()[0].getSpecificThreats()}</td>
    <td class="${editable}" data-name="comment">${occ._getTaxa()[0].getComment()}</td>
    <td class="${editable}" data-name="privateNote">${occ._getTaxa()[0].getPrivateComment()}</td>
    </c:when>

    <c:when test="${param.flavour == 'herbarium'}">
    <td class="${editable}" data-name="accession">${occ._getTaxa()[0].getAccession()}</td>
    <c:set var="taxa" value="${occ._getTaxa()[0].getTaxEnt() == null ? occ._getTaxa()[0].getVerbTaxon() : occ._getTaxa()[0].getTaxEnt().getNameWithAnnotationOnly(false)}" />
    <td class="taxon ${editable}" data-name="taxa">${taxa}</td>
    <td class="${editable}" data-name="presenceStatus">${occ._getTaxa()[0]._getPresenceStatusLabel()}</td>
    <td class="${editable} coordinates ${coordchanged}" data-name="observationCoordinates" data-lat="${occ._getLatitude()}" data-lng="${occ._getLongitude()}" data-symbol="${symbol}">${occ._getCoordinates()}</td>
    <td class="${editable}" data-name="precision">${occ.getPrecision().toString()}</td>
    <td class="${editable}" data-name="verbLocality">${occ.getVerbLocality()}</td>
    <td class="${editable}" data-name="date" sorttable_customkey="${occ._getDateYMD()}">${occ._getDate()}</td>
    <td class="${editable} authors" data-name="collectors"><t:usernames idarray="${occ.getCollectors()}" usermap="${userMap}"/></td>
    <td class="${editable}" data-name="labelData">${occ._getTaxa()[0].getLabelData()}</td>
    <td class="${editable}" data-name="privateNote">${occ._getTaxa()[0].getPrivateComment()}</td>
    <!--<td class="${editable} authors" data-name="determiners"><t:usernames idarray="${occ.getDets()}" usermap="${userMap}"/></td>-->
    </c:when>

    <c:when test="${flavour == 'management'}">
    <td class="">${occ.getCode()} ${occ._getTaxa()[0].getAccession()}</td>
    <td class="${editable} coordinates ${coordchanged}" data-name="observationCoordinates" data-lat="${occ._getLatitude()}" data-lng="${occ._getLongitude()}" data-symbol="${symbol}">${occ._getCoordinates()}</td>
    <c:set var="taxa" value="${occ._getTaxa()[0].getTaxEnt() == null ? occ._getTaxa()[0].getVerbTaxon() : occ._getTaxa()[0].getTaxEnt().getNameWithAnnotationOnly(false)}" />
    <td class="${editable}" data-name="precision">${occ.getPrecision().toString()}</td>
    <td class="taxon ${editable}" data-name="taxa">${taxa}</td>
    <td class="${editable} hideincompactview" data-name="confidence">${occ._getTaxa()[0]._getConfidenceLabel()}</td>
    <td class="${editable}" data-name="date" sorttable_customkey="${occ._getDateYMD()}">${occ._getDate()}</td>
    <td class="">${occ.getVerbLocality()} ${occ.getLocality()}</td>
    <td class="${editable}" data-name="presenceStatus">${occ._getTaxa()[0]._getPresenceStatusLabel()}</td>
    <td class=""><t:usernames idarray="${occ.getObservers()}" usermap="${userMap}"/> <t:usernames idarray="${occ.getCollectors()}" usermap="${userMap}"/></td>
    <td class="">${occ._getTaxa()[0].getComment()} ${occ._getTaxa()[0].getLabelData()}</td>
    <td class="${editable}" data-name="privateNote">${occ._getTaxa()[0].getPrivateComment()}</td>
    <td class="${editable} hideincompactview" data-name="abundance"><c:if test="${occ._getTaxa()[0].getAbundance().getError() != null}"><span class="error"></c:if>${occ._getTaxa()[0].getAbundance()}<c:if test="${occ._getTaxa()[0].getAbundance().getError() != null}"></span></c:if></td>
    <td class="${editable} hideincompactview" data-name="typeOfEstimate">${occ._getTaxa()[0]._getTypeOfEstimateLabel()}</td>
    <td class="${editable} hideincompactview" data-name="hasPhoto">${occ._getTaxa()[0]._getHasPhotoLabel()}</td>
    <td class="${editable} hideincompactview" data-name="hasSpecimen">${occ._getTaxa()[0].getHasSpecimen()}</td>
    <td class="threats ${editable}" data-name="specificThreats">${occ._getTaxa()[0].getSpecificThreats()}</td>
    <td class="${editable} hideincompactview" data-name="phenoState">${occ._getTaxa()[0]._getPhenoStateLabel()}</td>
    </c:when>

    </c:choose>
</tr>
</c:if>