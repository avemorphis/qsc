//=================================================================================================================
//  Object: parseResponse.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: parseResponse JSON Deserializer class for handling response after initial authorization callout
//=================================================================================================================
//          Date            Purpose
// Changes: 06/23/2018      Initial Version
//=================================================================================================================

public class parseResponse {

	public String access_token;
	public String token_type;
	public Integer expires_in;
	public String refresh_token;
	public String scope;
	public Integer created_at;
	public String owner_id;
	public String owner_type;

	
	public static parseResponse parse(String json) {
		return (parseResponse) System.JSON.deserialize(json, parseResponse.class);
	}
}

/*
	Sample Payload
	QSCID Callback
		
	{  
		"access_token":"a54a0ab498cbd96658bbe6748ba6789d9ea08e71b8f04ff7e59fc62afe3e69e8",
		"token_type":"bearer",
		"expires_in":15533126,
		"refresh_token":"5f2d273a108055d96c705e382ba0c35d716d3dcba584d80e553fc7365a86c30a",
		"scope":"user",
		"created_at":1530161423,
		"owner_id":"f0000d0d-0000-0000-9fb1-9d021221370d",
		"owner_type":"users"
	}

*/