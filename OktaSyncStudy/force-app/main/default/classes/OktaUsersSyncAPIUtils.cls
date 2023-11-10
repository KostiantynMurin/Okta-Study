/*************************************************************************************************************
 * @name			OktaUsersSyncAPIUtils
 * @author			Konstantin Murin <konstantin.murin@synebo.io>
 * @date			10 / 11 / 2023
 * @description		Class contains methods that used for OktaUsersSyncAPI
**************************************************************************************************************/
public with sharing class OktaUsersSyncAPIUtils {

    /*********************************************************************************************************
     * @name			handleError
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		Handle Error RestResponse
     * @param           response RestResponse
     * @param           errorMessage errorMessage
     * @param           statusCode statusCode
    **********************************************************************************************************/
    public static void handleError(RestResponse response, String errorMessage, Integer statusCode){
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf('{"message":"' + errorMessage +'"}');
    }

    /*********************************************************************************************************
     * @name			handleSuccess
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		Handle Error RestResponse
     * @param           response RestResponse
     * @param           responseBody responseBody
     * @param           statusCode statusCode
    **********************************************************************************************************/
    public static void handleSuccess(RestResponse response, String responseBody, Integer statusCode){
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(responseBody);
    }
}