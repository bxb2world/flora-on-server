package pt.floraon.entities;

import java.io.IOException;

import com.arangodb.ArangoException;

import pt.floraon.dbworker.FloraOnGraph;

public class GeneralNodeWrapperImpl extends GeneralNodeWrapper {
	
	public GeneralNodeWrapperImpl(FloraOnGraph graph, GeneralDBNode node) {
		this.baseNode=node;
		this.graph=graph;
	}

	@Override
	void saveToDB() throws IOException, ArangoException {
		// TODO Auto-generated method stub
		
	}

}