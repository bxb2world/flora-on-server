package pt.floraon.redlistdata.jobs;

import jline.internal.Log;
import pt.floraon.authentication.entities.User;
import pt.floraon.driver.FloraOnException;
import pt.floraon.driver.interfaces.IFloraOn;
import pt.floraon.driver.jobs.JobTask;
import pt.floraon.driver.results.InferredStatus;
import pt.floraon.redlistdata.entities.RedListDataEntity;

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * Updates the native status of all taxa in the red list of the given territory.
 * Created by miguel on 14-12-2016.
 */
public class UpdateNativeStatusJob implements JobTask {
    private int n = 0, total;
    private String territory;

    public UpdateNativeStatusJob(String territory) {
        this.territory = territory;
    }

    @Override
    public void run(IFloraOn driver) throws FloraOnException, IOException {
        Log.info("Updating red list dataset for " + territory);
        Iterator<RedListDataEntity> rldel = driver.getRedListData().getAllRedListData(territory, false, null);
        Map<String, Object> v = new HashMap<>();

        while(rldel.hasNext()) {
            RedListDataEntity rlde = rldel.next();
            InferredStatus is = driver.wrapTaxEnt(driver.asNodeKey(rlde.getTaxEntID())).getInferredNativeStatus(territory);
//            rlde.setInferredStatus(is);
//            INodeKey nk = driver.asNodeKey(rlde.getID());
//            driver.getRedListData().updateRedListDataEntity(territory, nk, rlde, false);
            v.clear();
            v.put("inferredStatus", is);
            driver.getRedListData().updateRedListDataEntities(territory, new String[] {rlde.getTaxEntID()}, v);
            n++;
        }

    }

    @Override
    public String getState() {
        return String.format("%d done.", n);
    }

    @Override
    public String getDescription() {
        return "Update native status";
    }

    @Override
    public User getOwner() {
        return null;
    }
}
