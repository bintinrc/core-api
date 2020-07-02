package co.nvqa.core_api.cucumber.glue.support;

import co.nvqa.commons.client.auth.AuthClient;
import co.nvqa.commons.model.auth.AuthResponse;
import co.nvqa.commons.model.auth.ClientCredentialsAuth;

import java.util.HashMap;
import java.util.Map;

/**
 * @author Binti Cahayati on 2020-07-01
 */
public class AuthHelper {

    private static final AuthClient AUTH_CLIENT;
    private static final Map<String, String> TOKEN_CONTAINER = new HashMap<>();

    static {
        AUTH_CLIENT = new AuthClient(TestConstants.API_BASE_URL);
    }

    public static String getOperatorAuthToken() {
        String key = "OPERATOR_TOKEN";

        if (TOKEN_CONTAINER.containsKey(key)) {
            return TOKEN_CONTAINER.get(key);
        }

        ClientCredentialsAuth request = new ClientCredentialsAuth(TestConstants.OPERATOR_CLIENT_ID, TestConstants.OPERATOR_CLIENT_SECRET);
        co.nvqa.commons.model.auth.AuthResponse resp = AUTH_CLIENT.authenticate(request);
        TOKEN_CONTAINER.put(key, resp.getAccessToken());

        return resp.getAccessToken();
    }

    public static String getShipperToken(String clientId, String clientSecret) {
        if (TOKEN_CONTAINER.containsKey(clientId)) {
            return TOKEN_CONTAINER.get(clientId);
        }

        ClientCredentialsAuth request = new ClientCredentialsAuth(clientId, clientSecret);
        AuthResponse resp = AUTH_CLIENT.authenticate(request);
        TOKEN_CONTAINER.put(clientId, resp.getAccessToken());

        return resp.getAccessToken();
    }
}
