/*************************************************************************************************************
 * @name			ProcessUserExecutor
 * @author			Konstantin Murin <konstantin.murin@synebo.io>
 * @date			10 / 11 / 2023
 * @description		Handle JSON request from OktaUsersSyncAPI
**************************************************************************************************************/
public with sharing class ProcessUserExecutor {

    RestResponse response;
    OktaRequestWrapper requestWrapper;

    private static final Map<String, OktaUserProcessorInterface> EVENT_TYPE_TO_INTERFACE_REALISATION_MAP = new Map<String, OktaUserProcessorInterface>{ 
        'user.lifecycle.create' => new UpsertUserProcessor(),
        'user.lifecycle.update_profile' => new UpsertUserProcessor(),
        'user.lifecycle.deactivate' => new DeactivateUserProcessor()
    };

    /*********************************************************************************************************
     * @name			ProcessUserExecutor
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		Constructor
     * @param           jsonStr request body in JSON format
    **********************************************************************************************************/
    public ProcessUserExecutor(String jsonStr){
        response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        parseJson(jsonStr);
    }

    /*********************************************************************************************************
     * @name			run
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		run user sync proess
    **********************************************************************************************************/
    public void run(){
        if(requestWrapper == null) {
            return;
        }
        try{
            System.debug(' KM ====>  eventType ' + requestWrapper.data.events[0].eventType);
            String eventType = requestWrapper.data.events[0].eventType;
            if (EVENT_TYPE_TO_INTERFACE_REALISATION_MAP.containsKey(eventType)) {
                EVENT_TYPE_TO_INTERFACE_REALISATION_MAP.get(requestWrapper.data.events[0].eventType).processOktaUser(requestWrapper.data.events[0]);
                OktaUsersSyncAPIUtils.handleSucces(response, 'Success', 200);
            } else {
                throw new ProcessUserExecutorException('Event type "' + eventType + '" is not support');
            }
            
        }
        catch (Exception e){
            String message = e.getMessage();
            message += '\n Cause: ' + e.getCause();
            message += '\n on line: ' + e.getStackTraceString();
            System.debug(' KM ====>   ex message' + message);
            OktaUsersSyncAPIUtils.handleError(response, message, 500);
        }
    }

    private void parseJson(String jsonStr){
        try {
            requestWrapper = OktaRequestWrapper.parse(jsonStr);
        } catch (Exception e) {
            System.debug(' KM ====>  exc ' + e.getMessage());
            OktaUsersSyncAPIUtils.handleError(response, e.getMessage(), 400);
        }
    }

    class ProcessUserExecutorException extends Exception {}
}