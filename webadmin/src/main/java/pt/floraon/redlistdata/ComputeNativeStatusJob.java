package pt.floraon.redlistdata;

import pt.floraon.driver.FloraOnException;
import pt.floraon.driver.IFloraOn;
import pt.floraon.entities.TaxEnt;
import pt.floraon.jobs.JobTask;
import pt.floraon.redlistdata.entities.RedListDataEntity;

import java.io.IOException;
import java.util.List;

/**
 * Computes the native status of all taxa existing in given territory and stores in the collection redlist_(territory)
 * Created by miguel on 10-11-2016.
 */
public class ComputeNativeStatusJob implements JobTask {
    private int n = 0, total;
    @Override
    public void run(IFloraOn driver, Object options) throws FloraOnException, IOException {
        String territory = (String) options;
        List<TaxEnt> taxEntList = driver.getListDriver().getAllSpeciesOrInferiorTaxEnt(true, true, territory, null, null);
        total = taxEntList.size();
        RedListDataEntity rlde;

        for(TaxEnt te1 : taxEntList) {
            rlde = new RedListDataEntity(te1.getID(), driver.wrapTaxEnt(driver.asNodeKey(te1.getID())).getInferredNativeStatus(territory));
            driver.getRedListData().createRedListDataEntity(territory, rlde);
            System.out.println(te1.getFullName()+": "+ rlde.getInferredStatus().getNativeStatus().toString());
            n++;
        }

    }

    @Override
    public String getState() {
        return String.format("%d / %d done.", n, total);
    }
}