/*************************************************************************************************************
 * @name			OktaRequestWrapper
 * @author			Konstantin Murin <konstantin.murin@synebo.io>
 * @date			10 / 11 / 2023
 * @description		Parse JSON request from OktaUsersSyncAPI
**************************************************************************************************************/
public with sharing class OktaRequestWrapper {

	public String eventType {get;set;} 
	public String eventTypeVersion {get;set;} 
	public String cloudEventsVersion {get;set;} 
	public String source {get;set;} 
	public String eventId {get;set;} 
	public Data data {get;set;} 
	public String eventTime {get;set;} 
	public String contentType {get;set;} 

	/*********************************************************************************************************
	 * @name			OktaRequestWrapper
	 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Constructor
	 * @param           parser System.JSONParser
	**********************************************************************************************************/
	public OktaRequestWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'eventType') {
						eventType = parser.getText();
					} else if (text == 'eventTypeVersion') {
						eventTypeVersion = parser.getText();
					} else if (text == 'cloudEventsVersion') {
						cloudEventsVersion = parser.getText();
					} else if (text == 'source') {
						source = parser.getText();
					} else if (text == 'eventId') {
						eventId = parser.getText();
					} else if (text == 'data') {
						data = new Data(parser);
					} else if (text == 'eventTime') {
						eventTime = parser.getText();
					} else if (text == 'contentType') {
						contentType = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'OktaRequestWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}

	/*********************************************************************************************************
     * @name			parse
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		parse JSON
     * @param           jsonStr request body in JSON format
	 * @return			OktaRequestWrapper
    **********************************************************************************************************/
    public static OktaRequestWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new OktaRequestWrapper(parser);
	}

	/*********************************************************************************************************
     * @name			consumeObject
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		consumeObject
     * @param           parser System.JSONParser
    **********************************************************************************************************/
    public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<Actor> arrayOfActor(System.JSONParser p) {
        List<Actor> res = new List<Actor>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Actor(p));
        }
        return res;
    }

    private static List<IpChain> arrayOfIpChain(System.JSONParser p) {
        List<IpChain> res = new List<IpChain>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new IpChain(p));
        }
        return res;
    }

    private static List<Events> arrayOfEvents(System.JSONParser p) {
        List<Events> res = new List<Events>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Events(p));
        }
        return res;
    }

	/*************************************************************************************************************
	 * @name			AuthenticationContext
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		AuthenticationContext
	**************************************************************************************************************/
	public class AuthenticationContext {
		public Object authenticationProvider {get;set;} 
		public Object credentialProvider {get;set;} 
		public Object credentialType {get;set;} 
		public Object issuer {get;set;} 
		public Integer authenticationStep {get;set;} 
		public String externalSessionId {get;set;} 
		public Object interface_Z {get;set;} // in json: interface

		/*********************************************************************************************************
		 * @name			AuthenticationContext
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public AuthenticationContext(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'authenticationProvider') {
							authenticationProvider = parser.readValueAs(Object.class);
						} else if (text == 'credentialProvider') {
							credentialProvider = parser.readValueAs(Object.class);
						} else if (text == 'credentialType') {
							credentialType = parser.readValueAs(Object.class);
						} else if (text == 'issuer') {
							issuer = parser.readValueAs(Object.class);
						} else if (text == 'authenticationStep') {
							authenticationStep = parser.getIntegerValue();
						} else if (text == 'externalSessionId') {
							externalSessionId = parser.getText();
						} else if (text == 'interface') {
							interface_Z = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'AuthenticationContext consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			Geolocation
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Geolocation
	**************************************************************************************************************/
	public class Geolocation {
		public Double lat {get;set;} 
		public Double lon {get;set;} 

		/*********************************************************************************************************
		 * @name			Geolocation
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public Geolocation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'lat') {
							lat = parser.getDoubleValue();
						} else if (text == 'lon') {
							lon = parser.getDoubleValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Geolocation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			DebugData
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		DebugData
	**************************************************************************************************************/
	public class DebugData {
		public String requestId {get;set;} 
		public String requestUri {get;set;} 
		public String targetEventHookIds {get;set;} 
		public String url {get;set;} 

		/*********************************************************************************************************
		 * @name			DebugData
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public DebugData(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'requestId') {
							requestId = parser.getText();
						} else if (text == 'requestUri') {
							requestUri = parser.getText();
						} else if (text == 'targetEventHookIds') {
							targetEventHookIds = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'DebugData consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			Data
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Data
	**************************************************************************************************************/
	public class Data {
		public List<Events> events {get;set;} 

		/*********************************************************************************************************
		 * @name			Data
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'events') {
							events = arrayOfEvents(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			DebugContext
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		DebugContext
	**************************************************************************************************************/
	public class DebugContext {
		public DebugData debugData {get;set;} 

		/*********************************************************************************************************
		 * @name			DebugContext
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public DebugContext(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'debugData') {
							debugData = new DebugData(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'DebugContext consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			Transaction_Z
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Transaction_Z
	**************************************************************************************************************/
	public class Transaction_Z {
		public String type {get;set;} 
		public String id {get;set;} 
		public Detail detail {get;set;} 

		/*********************************************************************************************************
		 * @name			Transaction_Z
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public Transaction_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'detail') {
							detail = new Detail(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Transaction_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			Events
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Events
	**************************************************************************************************************/
	public class Events {
		public String uuid {get;set;} 
		public String published {get;set;} 
		public String eventType {get;set;} 
		public String version {get;set;} 
		public String displayMessage {get;set;} 
		public String severity {get;set;} 
		public Client client {get;set;} 
		public Object device {get;set;} 
		public Actor actor {get;set;} 
		public Outcome outcome {get;set;} 
		public List<Actor> target {get;set;} 
		public Transaction_Z transaction_Z {get;set;} // in json: transaction
		public DebugContext debugContext {get;set;} 
		public String legacyEventType {get;set;} 
		public AuthenticationContext authenticationContext {get;set;} 
		public SecurityContext securityContext {get;set;} 
		public Object insertionTimestamp {get;set;} 

		/*********************************************************************************************************
		 * @name			Events
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public Events(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'uuid') {
							uuid = parser.getText();
						} else if (text == 'published') {
							published = parser.getText();
						} else if (text == 'eventType') {
							eventType = parser.getText();
						} else if (text == 'version') {
							version = parser.getText();
						} else if (text == 'displayMessage') {
							displayMessage = parser.getText();
						} else if (text == 'severity') {
							severity = parser.getText();
						} else if (text == 'client') {
							client = new Client(parser);
						} else if (text == 'device') {
							device = parser.readValueAs(Object.class);
						} else if (text == 'actor') {
							actor = new Actor(parser);
						} else if (text == 'outcome') {
							outcome = new Outcome(parser);
						} else if (text == 'target') {
							target = arrayOfActor(parser);
						} else if (text == 'transaction') {
							transaction_Z = new Transaction_Z(parser);
						} else if (text == 'debugContext') {
							debugContext = new DebugContext(parser);
						} else if (text == 'legacyEventType') {
							legacyEventType = parser.getText();
						} else if (text == 'authenticationContext') {
							authenticationContext = new AuthenticationContext(parser);
						} else if (text == 'securityContext') {
							securityContext = new SecurityContext(parser);
						} else if (text == 'insertionTimestamp') {
							insertionTimestamp = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Events consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			Outcome
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Outcome
	**************************************************************************************************************/
	public class Outcome {
		public String result {get;set;} 
		public Object reason {get;set;} 

		/*********************************************************************************************************
		 * @name			Outcome
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public Outcome(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'result') {
							result = parser.getText();
						} else if (text == 'reason') {
							reason = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Outcome consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			Actor
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Actor
	**************************************************************************************************************/
	public class Actor {
		public String id {get;set;} 
		public String type {get;set;} 
		public String alternateId {get;set;} 
		public String displayName {get;set;} 
		public Object detailEntry {get;set;} 

		/*********************************************************************************************************
		 * @name			Actor
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public Actor(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'alternateId') {
							alternateId = parser.getText();
						} else if (text == 'displayName') {
							displayName = parser.getText();
						} else if (text == 'detailEntry') {
							detailEntry = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'Actor consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			UserAgent
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		UserAgent
	**************************************************************************************************************/
	public class UserAgent {
		public String rawUserAgent {get;set;} 
		public String os {get;set;} 
		public String browser {get;set;} 

		/*********************************************************************************************************
		 * @name			UserAgent
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public UserAgent(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'rawUserAgent') {
							rawUserAgent = parser.getText();
						} else if (text == 'os') {
							os = parser.getText();
						} else if (text == 'browser') {
							browser = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'UserAgent consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			SecurityContext
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		SecurityContext
	**************************************************************************************************************/
	public class SecurityContext {
		public Integer asNumber {get;set;} 
		public String asOrg {get;set;} 
		public String isp {get;set;} 
		public String domain {get;set;} 
		public Boolean isProxy {get;set;} 

		/*********************************************************************************************************
		 * @name			SecurityContext
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public SecurityContext(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'asNumber') {
							asNumber = parser.getIntegerValue();
						} else if (text == 'asOrg') {
							asOrg = parser.getText();
						} else if (text == 'isp') {
							isp = parser.getText();
						} else if (text == 'domain') {
							domain = parser.getText();
						} else if (text == 'isProxy') {
							isProxy = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'SecurityContext consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			GeographicalContext
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		GeographicalContext
	**************************************************************************************************************/
	public class GeographicalContext {
		public String city {get;set;} 
		public String state {get;set;} 
		public String country {get;set;} 
		public String postalCode {get;set;} 
		public Geolocation geolocation {get;set;} 

		/*********************************************************************************************************
		 * @name			GeographicalContext
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public GeographicalContext(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'postalCode') {
							postalCode = parser.getText();
						} else if (text == 'geolocation') {
							geolocation = new Geolocation(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'GeographicalContext consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			IpChain
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		IpChain
	**************************************************************************************************************/
	public class IpChain {
		public String ip {get;set;} 
		public GeographicalContext geographicalContext {get;set;} 
		public String version {get;set;} 
		public Object source {get;set;} 

		/*********************************************************************************************************
		 * @name			IpChain
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public IpChain(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'ip') {
							ip = parser.getText();
						} else if (text == 'geographicalContext') {
							geographicalContext = new GeographicalContext(parser);
						} else if (text == 'version') {
							version = parser.getText();
						} else if (text == 'source') {
							source = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'IpChain consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			Client
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Client
	**************************************************************************************************************/
	public class Client {
		public UserAgent userAgent {get;set;} 
		public String zone {get;set;} 
		public String device {get;set;} 
		public Object id {get;set;} 
		public String ipAddress {get;set;} 
		public GeographicalContext geographicalContext {get;set;} 
		public List<IpChain> ipChain {get;set;} 

		/*********************************************************************************************************
		 * @name			Client
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public Client(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'userAgent') {
							userAgent = new UserAgent(parser);
						} else if (text == 'zone') {
							zone = parser.getText();
						} else if (text == 'device') {
							device = parser.getText();
						} else if (text == 'id') {
							id = parser.readValueAs(Object.class);
						} else if (text == 'ipAddress') {
							ipAddress = parser.getText();
						} else if (text == 'geographicalContext') {
							geographicalContext = new GeographicalContext(parser);
						} else if (text == 'ipChain') {
							ipChain = arrayOfIpChain(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Client consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*************************************************************************************************************
	 * @name			Detail
	 * @author			Konstantin Murin <konstantin.murin@synebo.io>
	 * @date			10 / 11 / 2023
	 * @description		Detail
	**************************************************************************************************************/
	public class Detail {

		/*********************************************************************************************************
		 * @name			Detail
		 * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
		 * @date			10 / 11 / 2023
		 * @description		Constructor
		 * @param           parser System.JSONParser
		**********************************************************************************************************/
		public Detail(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Detail consuming unrecognized property: '+text);
						    consumeObject(parser);
						}
					}
				}
			}
		}
	}
}