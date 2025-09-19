import ballerina/log;
import ballerina/lang.runtime;

// Main function that handles both mock service and data export/testing
public function main() returns error? {
    log:printInfo("🚀 Starting Vertafore Integration System...");

    if (INTEGRATION_TEST_ENABLED) {
        // Run integration test (like the previous working version)
        log:printInfo("Running integration test with mock service...");

        // Start client in a separate worker to test the service
        future<error?> clientFuture = start runIntegrationTestAsync();

        // Keep the main thread alive for the service and worker
        runtime:sleep(20.0);

        // Wait for the integration test to complete
        error? result = wait clientFuture;
        if (result is error) {
            log:printError(string `Integration test error: ${result.message()}`);
        }

        log:printInfo("🎉 Integration test completed!");
    } else {
        // Run data export mode
        log:printInfo("Running data export mode...");
        check runDataExport();
        log:printInfo("🎉 Data export completed!");
    }
}

// Async integration test function
function runIntegrationTestAsync() returns error? {
    // Wait for service to start
    log:printInfo("Waiting for mock service to start...");
    runtime:sleep(3.0);

    return runIntegrationTest();
}

// Integration test function (similar to previous working version)
function runIntegrationTest() returns error? {
    foreach string tableName in TEST_TABLES {
        log:printInfo(string `Testing ${tableName} endpoint...`);

        // Fetch data from API
        VertafoteResponse response = check fetchTableData(BASE_URL, API_KEY, PRODUCT, tableName, TEST_PAGE_SIZE);

        log:printInfo("✅ API call successful");
        log:printInfo(string `   Record count: ${response.recordCount}`);
        log:printInfo(string `   Content items: ${response.content.length()}`);
        log:printInfo(string `   Starting token: ${response.startingToken ?: "None"}`);

        // Export to CSV
        string csvFilename = string `${OUTPUT_DIRECTORY}/${tableName}_test.csv`;
        check exportToCSV(response.content, csvFilename);
        log:printInfo(string `   CSV exported to: ${csvFilename}`);
    }

    return ();
}

// Data export function for production use
function runDataExport() returns error? {
    // Test connection first
    boolean connected = testConnection(BASE_URL, API_KEY, PRODUCT);
    if (!connected) {
        return error("Failed to connect to Vertafore API");
    }

    // Export each configured table
    foreach string tableName in TABLES {
        log:printInfo(string `Exporting table: ${tableName}`);

        // Fetch data from API
        VertafoteResponse response = check fetchTableData(BASE_URL, API_KEY, PRODUCT, tableName, BATCH_SIZE);

        // Export to CSV
        string filename = string `${OUTPUT_DIRECTORY}/${tableName}.csv`;
        check exportToCSV(response.content, filename);

        log:printInfo(string `✅ Exported ${response.recordCount} records from ${tableName} to ${filename}`);

        // Handle pagination if there are more records
        string? nextToken = response.startingToken;
        while (nextToken is string) {
            log:printInfo(string `Fetching next page with token: ${nextToken}`);

            VertafoteResponse nextResponse = check fetchTableData(BASE_URL, API_KEY, PRODUCT, tableName, BATCH_SIZE, nextToken);

            // Append to existing CSV (this is simplified - in production you'd handle this better)
            string appendFilename = string `${OUTPUT_DIRECTORY}/${tableName}_page_${nextToken}.csv`;
            check exportToCSV(nextResponse.content, appendFilename);

            log:printInfo(string `✅ Exported additional ${nextResponse.recordCount} records`);

            nextToken = nextResponse.startingToken;
        }
    }

    return ();
}