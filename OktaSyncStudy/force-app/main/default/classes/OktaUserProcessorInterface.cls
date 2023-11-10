/*************************************************************************************************************
 * @name			OktaUserProcessorInterface
 * @author			Konstantin Murin <konstantin.murin@synebo.io>
 * @date			10 / 11 / 2023
 * @description		Interface for user processors
**************************************************************************************************************/
public interface OktaUserProcessorInterface {
    
    /*********************************************************************************************************
     * @name			processOktaUser
     * @author			Kostiantyn Murin <konstantin.murin@synebo.io>
     * @date			10 / 11 / 2023
     * @description		processOktaUser
     * @param           event OktaRequestWrapper.Events
    **********************************************************************************************************/
    void processOktaUser(OktaRequestWrapper.Events event);

}