/**
 * @ Author: Fabrício Makino
 * @ CreatedDate: 2022-07-16
 * @ Description: Callout Example
 */
public with sharing class CalloutAccount {

    /* 
    @Description: Callout Account and Contact with specific Account Id
    @Parameter: accountId
    */
    public static void postAccount(Id accountId) {

        Account account = [SELECT Id, Name, AccountNumber FROM Account WHERE Id =: accountId];
        List<Contact> lstContact = [SELECT Id, LastName FROM Contact WHERE AccountId =: accountId];

        AccountResponseVO accountResponseVO = new AccountResponseVO();

        try {

            String jsonResponse = null;
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            String body = JSON.serialize(new AccountRequestVO(account, lstContact), false);
            
            IntegrationConfiguration__mdt integrationConfiguration = IntegrationConfiguration__mdt.getAll().get('OAuth2AccountSF');
            String authorizationHeader = buildOAuth2Header();

            httpRequest.setEndpoint(integrationConfiguration.Endpoint__c);
            httpRequest.setHeader('Content-type', 'application/json');
            httpRequest.setHeader('Authorization', authorizationHeader);
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);

            if(String.isNotBlank(body)){
                httpRequest.setBody(body);
            }

            HttpResponse httpResponse = http.send(httpRequest);
            jsonResponse = httpResponse.getBody();
            System.debug('jsonResponse ==> ' + jsonResponse);
            if(httpResponse.getStatusCode() == 200) {
            }

            accountResponseVO = (AccountResponseVO) JSON.deserialize(jsonResponse, AccountResponseVO.class);    
        } catch (Exception e) {
            System.debug('e.getMessage() ==> ' + e.getMessage());
        }

        System.debug('accountResponseVO ==> ' + accountResponseVO);
        /* Create your business rule
        */

        /* Create your integration log method
        insertIntegrationLog();
        */
                
    }

    // Request Token Auxiliar Class
    private class TokenInfo{
		public String access_token = '';
		public String token_type = '';
		public String expires_in = '';
		public Datetime expirateDatetime = null;
	}
    
    // Build Header Authorization OAuth2 
	private static String buildOAuth2Header(){
        IntegrationConfiguration__mdt integrationConfiguration = IntegrationConfiguration__mdt.getAll().get('OAuth2TokenSF');
		
		HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        // Timeout reduced in 10000 miliseconds in order to avoid timeouts in invoke actions through javascript.
        request.setTimeout(110000);
        request.setEndpoint(integrationConfiguration.Endpoint__c);
		request.setBody(
			'grant_type=password' + 
			'&client_id=' + integrationConfiguration.ClientId__c + 
			'&client_secret=' + integrationConfiguration.ClientSecret__c + 
			'&username=' + integrationConfiguration.Username__c + 
			'&password=' + integrationConfiguration.Password__c
	    );
		HttpResponse responseToken = new HttpResponse();
		responseToken = (new Http()).send(request);
		TokenInfo tokenInfo = (TokenInfo) JSON.deserialize(responseToken.getBody(), TokenInfo.class);

		return 'Bearer ' + tokenInfo.access_token;
	}    

    // Build Header Authorization Basic 
    private static String buildBasicHeader(IntegrationConfiguration__mdt integrationConfiguration) {
        String authKey = integrationConfiguration.Username__c + ':' + integrationConfiguration.Password__c;
        Blob header = Blob.valueOf(authKey);

        return 'Basic ' + EncodingUtil.base64Encode(header);
    }

}