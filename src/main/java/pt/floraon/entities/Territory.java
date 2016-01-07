package pt.floraon.entities;


import com.arangodb.ArangoException;
import com.arangodb.entity.marker.VertexEntity;

import pt.floraon.driver.ArangoKey;
import pt.floraon.driver.Constants;
import pt.floraon.driver.FloraOnDriver;
import pt.floraon.driver.FloraOnException;
import pt.floraon.driver.Constants.NativeStatus;
import pt.floraon.driver.Constants.NodeTypes;

public class Territory extends GeneralNodeWrapper {
	public TerritoryVertex baseNode;
	
	public Territory(TerritoryVertex tv) {
		this.baseNode=tv;
		super.baseNode=this.baseNode;
	}
	
	public Territory(FloraOnDriver graph,TerritoryVertex tv) throws FloraOnException {
		if(tv==null) throw new FloraOnException("Null territory given");
		this.baseNode=tv;
		super.baseNode=this.baseNode;
		this.graph=graph;
	}

	private Territory(String name,String shortName) {
		this.baseNode=new TerritoryVertex(name, shortName);
		super.baseNode=this.baseNode;
	}
	
	public static Territory newFromName(FloraOnDriver driver,String name,String shortName, TerritoryVertex parent) throws ArangoException, FloraOnException {
		Territory out=new Territory(name, shortName);
		out.graph=driver;
		VertexEntity<TerritoryVertex> tmp=driver.driver.graphCreateVertex(Constants.TAXONOMICGRAPHNAME, NodeTypes.territory.toString(), out.baseNode, false);
		out.baseNode._id=tmp.getDocumentHandle();
		out.baseNode._key=tmp.getDocumentKey();
		
		if(parent!=null) {
			out.setPART_OF(parent);
			//driver.driver.createEdge(RelTypes.PART_OF.toString(), new PART_OF(), out.baseNode._id, parent._id, false, false);
		}
		return out;
	}

	public static Territory newFromName(FloraOnDriver driver,String name,String shortName, ArangoKey parent) throws ArangoException, FloraOnException {
		// NOTE: parent is not checked for the node type. It must be a territory, but is not checked. This is done in the validation.
		Territory out=new Territory(name, shortName);
		out.graph=driver;
		VertexEntity<TerritoryVertex> tmp=driver.driver.graphCreateVertex(Constants.TAXONOMICGRAPHNAME, NodeTypes.territory.toString(), out.baseNode, false);
		out.baseNode._id=tmp.getDocumentHandle();
		out.baseNode._key=tmp.getDocumentKey();
		
		if(parent!=null) out.setPART_OF(parent);
		return out;
	}

	public int setTaxEntNativeStatus(ArangoKey taxent, NativeStatus status) throws FloraOnException, ArangoException {
		if(baseNode._id==null) throw new FloraOnException("Node "+baseNode.name+" not attached to DB");
		String query;
		if(status == null) {	// remove the EXISTS_IN link, if it exists
			query=String.format(
				"FOR e IN EXISTS_IN FILTER e._from=='%1$s' && e._to=='%2$s' REMOVE e IN EXISTS_IN RETURN OLD ? 0 : 1"
				,taxent.toString()
				,baseNode._id);
		} else {				// create or update the EXISTS_IN link
			EXISTS_IN a=new EXISTS_IN(status, taxent.toString(), baseNode._id);
			query=String.format(
				"UPSERT {_from:'%1$s',_to:'%2$s'} INSERT %3$s UPDATE %3$s IN EXISTS_IN RETURN OLD ? 0 : 1"
				,taxent.toString()
				,baseNode._id
				,a.toJSONString());
		}
		//System.out.println(query);
		return this.graph.driver.executeAqlQuery(query,null,null,Integer.class).getUniqueResult();
	}
	
	@Override
	void commit() throws FloraOnException, ArangoException {
		// TODO Auto-generated method stub
		
	}

}