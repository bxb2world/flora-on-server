package pt.floraon.driver;

import pt.floraon.redlistdata.entities.AtomicTaxonPrivilege;
import pt.floraon.taxonomy.entities.Territory;
import pt.floraon.redlistdata.ExternalDataProvider;
import pt.floraon.redlistdata.entities.RedListDataEntity;

import java.util.*;

/**
 * Created by miguel on 05-11-2016.
 */
public interface IRedListData {
    /**
     * Prepares database for holding red list data and checks for which territories there is data
     */
    void initializeRedListData(Properties properties) throws FloraOnException;

    /**
     * Gets the territories for which there is red list data
     * @return
     */
    List<String> getRedListTerritories();
    /**
     * Initializes a new dataset to hold the data for the given territory. This must include all taxa existing in it,
     * along with the native status of each one in the territory
     * @param territory The short name of the {@link Territory}
     */
    void initializeRedListDataForTerritory(String territory) throws FloraOnException;

    List<ExternalDataProvider> getExternalDataProviders();

    /**
     * Stores in the DB a new red list data entity.
     * @param territory The territory shortName
     * @param rlde The {@link RedListDataEntity} object to store
     * @return
     * @throws DatabaseException
     */
    RedListDataEntity createRedListDataEntity(String territory, RedListDataEntity rlde) throws DatabaseException;

    /**
     * Updates an array of red list data entities with the specified values. Note that this function replaces the values
     * of all the fields present in the passed Map.
     * @param territory
     * @param taxEntIds
     * @param values
     * @throws FloraOnException
     */
    int updateRedListDataEntities(String territory, String[] taxEntIds, Map<String, Object> values) throws FloraOnException;

    /**
     * Deletes a data sheet and removes the taxon from the red list
     * @param territory
     * @param taxonId
     * @throws DatabaseException
     */
    void deleteRedListDataEntity(String territory, INodeKey taxonId) throws DatabaseException;

    /**
     * For all users, gets all taxon-specific privileges, disaggregated to species or inferior rank.
     * Note that in the database they may be assigned to higher taxa. This function must return species or inferior.
     * @param territory
     * @return
     * @throws DatabaseException
     */
    Iterator<AtomicTaxonPrivilege> getTaxonPrivilegesForAllUsers(String territory) throws DatabaseException;

    /**
     * Fetches all red list data for the given territory
     * @param territory The territory shortName
     * @return
     * @throws FloraOnException
     */
    List<RedListDataEntity> getAllRedListTaxa(String territory, boolean withTaxonSpecificPrivileges) throws FloraOnException;

    /**
     * Gets the {@link RedListDataEntity} for the given TaxEnt and territory
     * @param territory Territory short name
     * @param id TaxEnt ID
     * @return
     */
    RedListDataEntity getRedListDataEntity(String territory, INodeKey taxonId) throws DatabaseException;

    /**
     * Gets all tags in use in the red list dataset.
     * @return
     */
    Set<String> getRedListTags(String territory) throws DatabaseException;
}
