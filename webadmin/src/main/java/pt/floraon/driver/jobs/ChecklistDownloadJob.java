package pt.floraon.driver.jobs;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import pt.floraon.authentication.entities.User;
import pt.floraon.driver.FloraOnException;
import pt.floraon.driver.interfaces.IFloraOn;
import pt.floraon.taxonomy.entities.ChecklistEntry;
import pt.floraon.taxonomy.entities.Territory;
import pt.floraon.driver.results.ResultProcessor;

public class ChecklistDownloadJob implements JobFileDownload {
	private boolean finished = false;
	private boolean withParentSpecies;

	/**
	 * @param withParentSpecies True to always download all taxonomic hierarchy up to species, when there are infrataxa.
	 */
	public ChecklistDownloadJob(boolean withParentSpecies) {
		this.withParentSpecies = withParentSpecies;
	}
	@Override
	public Charset getCharset() {
		return StandardCharsets.UTF_8;
	}

	@Override
	public void run(IFloraOn driver, OutputStream outputStream) throws FloraOnException, IOException {
		OutputStreamWriter out = new OutputStreamWriter(outputStream, StandardCharsets.UTF_8);
		//PrintWriter out=new PrintWriter(outputStream);
		List<String> terr=new ArrayList<String>();
		for(Territory tv : driver.getChecklistTerritories())
			terr.add(tv.getShortName());

		ResultProcessor<ChecklistEntry> rpchk1;
		Iterator<ChecklistEntry> chklst = driver.getListDriver().getCheckList(withParentSpecies);
		rpchk1 = new ResultProcessor<>(chklst);
		out.write(rpchk1.toCSVTable(terr));
		out.close();
		finished = true;

/*
		ResultProcessor<TaxEntAndNativeStatusResult> rpchk1;
		Iterator<TaxEntAndNativeStatusResult> chklst = driver.getListDriver().getAllSpeciesOrInferior(true
				, TaxEntAndNativeStatusResult.class, false, null, null, null, null).iterator();
		rpchk1=(ResultProcessor<TaxEntAndNativeStatusResult>) new ResultProcessor<TaxEntAndNativeStatusResult>(chklst);
		out.write(rpchk1.toCSVTable(terr));
		
		//out.print(rpchk1.toCSVTable(terr));
		out.close();
		finished = true;
*/
	}

	@Override
	public String getState() {
		return finished ? "Ok" : "Processing";
	}

	@Override
	public String getDescription() {
		return "Checklist";
	}

	@Override
	public User getOwner() {
		return null;
	}
}
