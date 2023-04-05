//=================================================================================================================
//  Object: parseAuthUserData.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: parseAuthUserData JSON Deserializer class for calling QSC ID user API
//=================================================================================================================
//          Date            Purpose
// Changes: 06/24/2018      Initial Version
//=================================================================================================================

public class parseAuthUserData {
	
	public Data data; //Top Level
	public List<included> included; //For Included Values if needed

	public class Data {
		public String id; 
		public String type; // in json: type
		public Attributes attributes; 
		public Relationships relationships;
	}


	public class Attributes {
		public String first_name;
		public String last_name; 
		public String email;
		public String email_opt_in;
		public String phone; 
		public String salesforce_identifier;
		public String company_name;
		public String company_email; 
		public String account_number;
		public String account_name;
		public List<String> group_slugs;
		public String country_code;	
		public String address_1; 
		public String address_2; 
		public String city; 
		public String state; 
		public String postal_code; 
		public String country; 
	}


	public class Relationships {
		public Primary_address primary_address;
	}
	

	public class Primary_address {
		public Data data; 
	}
	

	public class included {
		public String id;
		public attributes attributes;
		public String type;
	}
	

	public static parseAuthUserData parse(String json){
		return (parseAuthUserData) System.JSON.deserialize(json, parseAuthUserData.class);
	}
	
}

/*
	Sample Payload
	URL:  https:iddev.qsc.com/api/v1/users/me
	{  
		"data":{  
		    "id":"af236db7-be79-4fe0-9083-13dcebaf07df",
		    "type":"users",
		    "attributes":{  
		        "first_name":"JSON",
		        "last_name":"USER",
		        "email":"JSON.USER@emailme.com",
		        "email_opt_in":false,
		        "phone":"4044044434",
		        "salesforce_identifier":"0032100000RZvThAAL",
		        "company_name":"Unspecified",
		        "company_email":null,
		        "account_number":"02011977",
		        "account_name":"Sample Account",
		        "group_slugs":[ ],
		        "country_code":"US"
		    },
		    "relationships":{  
		        "primary_address":{  
		        "data_z":{  
		            "id":"b350e0e3",
		            "type":"addresses"
		        }
		        }
		    }
		},
		"included":[  
		    {  
		        "id":"f9843dfd_4706_4442_9fb1_9d021221370d",
		        "type":"addresses",
		        "attributes":{  
		        "address_1":"PO Box 1",
		        "address_2":"",
		        "city":"Atlanta",
		        "state":"GA",
		        "postal_code":"30305",
		        "country":""
		        }
		    }
		]
	}

*/