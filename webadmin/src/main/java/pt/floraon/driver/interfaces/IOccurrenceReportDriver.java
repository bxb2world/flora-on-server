package pt.floraon.driver.interfaces;

import pt.floraon.driver.DatabaseException;
import pt.floraon.geometry.PolygonTheme;
import pt.floraon.occurrences.StatisticPerTaxon;
import pt.floraon.occurrences.arangodb.OccurrenceReportArangoDriver;
import pt.floraon.taxonomy.entities.TaxEnt;

import java.util.Date;
import java.util.Iterator;
import java.util.Map;

/**
 * Created by miguel on 08-07-2017.
 */
public interface IOccurrenceReportDriver {
    int getNumberOfInventories(INodeKey userId, Date from, Date to) throws DatabaseException;

    Iterator<StatisticPerTaxon> getAllTaxa(INodeKey userId, Date from, Date to) throws DatabaseException;

    Iterator<TaxEnt> getTaxaWithTag(INodeKey userId, Date from, Date to, String territory, String tag, boolean withPhoto) throws DatabaseException;
    Iterator<StatisticPerTaxon> getTaxaWithTagCollected(INodeKey userId, Date from, Date to, String territory, String tag) throws DatabaseException;
    Iterator<StatisticPerTaxon> getTaxaWithTagNrRecords(INodeKey userId, Date from, Date to, String territory, String tag) throws DatabaseException;
    Map<String, Integer> getListOfUTMSquaresWithOccurrences(INodeKey userId, Date from, Date to, long sizeOfSquare) throws DatabaseException;
    Map<String, Integer> getListOfPolygonsWithOccurrences(INodeKey userId, Date from, Date to, PolygonTheme polygonTheme) throws DatabaseException;

    Iterator<StatisticPerTaxon> getTaxaWithTagEstimates(INodeKey userId, Date from, Date to, String territory, String tag) throws DatabaseException;

    Iterator<TaxEnt> getRedListSheetsIsCollaborator(INodeKey userId, String territory, OccurrenceReportArangoDriver.TypeOfCollaboration typeOfCollaboration) throws DatabaseException;
}