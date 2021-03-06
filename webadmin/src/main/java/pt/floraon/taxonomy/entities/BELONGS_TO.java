package pt.floraon.taxonomy.entities;

import com.google.gson.JsonObject;

import pt.floraon.driver.Constants.RelTypes;
import pt.floraon.driver.entities.GeneralDBEdge;

public class BELONGS_TO extends GeneralDBEdge {

	public BELONGS_TO() {
		super();
	}

	public BELONGS_TO(String from, String to) {
		super(from, to);
	}

	@Override
	public RelTypes getType() {
		return RelTypes.BELONGS_TO;
	}

	@Override
	public String getTypeAsString() {
		return this.getType().toString();
	}
}
