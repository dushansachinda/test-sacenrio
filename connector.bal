import ballerina/http;
import ballerina/log;

// Fetch data from a specific table - creates fresh client each time to avoid action invocation issues
public function fetchTableData(string baseUrl, string apiKey, string product, string tableName, int pageSize = 100, string? startingToken = ()) returns VertafoteResponse|error {
    // Create a fresh HTTP client for each call
    http:Client httpClient = check new(baseUrl);

    string endpoint = string `/consumer/v1/${product}/tables/${tableName}`;

    // Build query parameters
    string queryParams = string `?page_size=${pageSize}`;
    if (startingToken is string) {
        queryParams += string `&starting_token=${startingToken}`;
    }

    map<string> headers = {
        "Authorization": string `Bearer ${apiKey}`,
        "Accept": "application/json"
    };

    log:printInfo(string `Calling API: ${baseUrl}${endpoint}${queryParams}`);

    http:Response|error response = httpClient->get(endpoint + queryParams, headers);

    if (response is http:Response) {
        if (response.statusCode == 200) {
            json|error jsonPayload = response.getJsonPayload();
            if (jsonPayload is json) {
                // Parse Vertafore API response
                json[] content = <json[]>check jsonPayload.content;
                int recordCount = <int>check jsonPayload.recordCount;
                json startingTokenJson = check jsonPayload.starting_token;
                string? nextToken = startingTokenJson is () ? () : startingTokenJson.toString();

                return {
                    content: content,
                    recordCount: recordCount,
                    startingToken: nextToken
                };
            } else {
                return error("Failed to parse JSON response");
            }
        } else {
            return error(string `API call failed with status: ${response.statusCode}`);
        }
    } else {
        return error(string `HTTP request failed: ${response.message()}`);
    }
}

// Test the connection to Vertafore API
public function testConnection(string baseUrl, string apiKey, string product) returns boolean {
    log:printInfo("Testing connection to Vertafore API...");

    VertafoteResponse|error result = fetchTableData(baseUrl, apiKey, product, "policies", 1);

    if (result is error) {
        log:printError(string `Connection test failed: ${result.message()}`);
        return false;
    } else {
        log:printInfo("✅ Connection test successful");
        return true;
    }
}