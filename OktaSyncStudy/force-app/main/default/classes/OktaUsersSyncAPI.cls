/*************************************************************************************************************
 * @name			OktaUsersSyncAPI
 * @author			Konstantin Murin <konstantin.murin@synebo.io>
 * @date			10 / 11 / 2023
 * @description		Class contains HttpGet webservice to verify Okta request and HttpPost webservice to sync Okta user with community contact
**************************************************************************************************************/
@RestResource(urlMapping='/syncUser/*')
global with sharing class OktaUsersSyncAPI {
    
    /*********************************************************************************************************
     * @name			verifyOktaRequest
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		Read the request header X-Okta-Verification-Challenge and pass its value in the body of the response
    **********************************************************************************************************/
    @HttpGet
    global static void verifyOktaRequest() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        Map<String, String> returnMap = new Map<String, String>{
            'verification' => RestContext.request.headers.get('X-Okta-Verification-Challenge')
        };
        response.statusCode = 200;
        response.responseBody = Blob.valueOf(JSON.serialize(returnMap));
    }
    
    /*********************************************************************************************************
     * @name			processUser
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		Gets request body from RestContext and runs ProcessUserExecutor
    **********************************************************************************************************/
    @HttpPost
    global static void processUser() {
        ProcessUserExecutor executor = new ProcessUserExecutor(RestContext.request.requestBody.toString());    
        executor.run();
    }

}