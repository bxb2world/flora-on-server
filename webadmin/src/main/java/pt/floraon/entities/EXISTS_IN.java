package pt.floraon.entities;

import pt.floraon.driver.Constants.NativeStatus;
import pt.floraon.driver.Constants.RelTypes;

/**
 * Describes the association of one taxon to one {@link Territory}.
 * It is not meant to describe the observation of a taxon in an inventory, for that we use {@link OBSERVED_IN}
 * @author miguel
 *
 */
public class EXISTS_IN extends GeneralDBEdge {
	public NativeStatus nativeStatus;
	
	public EXISTS_IN(NativeStatus nativeStatus) {
		this.nativeStatus=nativeStatus;
	}

	public EXISTS_IN(NativeStatus nativeStatus,String from,String to) {
		this.nativeStatus=nativeStatus;
		this._from=from;
		this._to=to;
	}
	
	@Override
	public RelTypes getType() {
		return RelTypes.EXISTS_IN;
	}

}
