package pt.floraon.taxonomy.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;

import com.google.gson.JsonObject;

import pt.floraon.driver.FloraOnException;
import pt.floraon.queryparser.YlemParser;
import pt.floraon.driver.results.ResultProcessor;
import pt.floraon.driver.results.SimpleTaxonResult;
import pt.floraon.server.FloraOnServlet;

/**
 * The Ylem query (all-in-one search)
 * @author miguel
 *
 */
public class Query extends FloraOnServlet {
	private static final long serialVersionUID = 1L;

	@Override
	public void doFloraOnGet(ThisRequest thisRequest) throws ServletException, IOException, FloraOnException {
		String query;
		String format=thisRequest.getParameterAsString("fmt");

		errorIfAnyNull(query = thisRequest.getParameterAsString("q"));

		if(format==null) format="json";
		Iterator<SimpleTaxonResult> it;
		ResultProcessor<SimpleTaxonResult> rp;

		YlemParser ylem=new YlemParser(driver,query);
		long start = System.nanoTime();
		List<SimpleTaxonResult> res=ylem.execute();
		long elapsedTime = System.nanoTime() - start;

		if(res==null) res=new ArrayList<SimpleTaxonResult>();

		JsonObject header=new JsonObject();
		header.addProperty("time", (double)elapsedTime/1000000000);
		header.addProperty("nresults", res.size());
		it=res.iterator();
		rp=new ResultProcessor<SimpleTaxonResult>(it);
		switch(format) {
		case "html":
			thisRequest.response.setContentType("text/html");
			PrintWriter pw;
			rp.toHTMLTable(pw = thisRequest.response.getWriter(), "taxonlist", null);
			pw.flush();
			break;

		case "json":
		default:
			thisRequest.success(rp.toJSONElement(),header);
			return;
		}
	}
}
