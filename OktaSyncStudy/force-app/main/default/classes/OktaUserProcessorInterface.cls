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
     * @param           eventList List<OktaRequestWrapper.Events>
    **********************************************************************************************************/
    void processOktaUser(List<OktaRequestWrapper.Events> eventList);

}