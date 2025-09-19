// Vertafore API Configuration
configurable string BASE_URL = "http://localhost:9090";
configurable string API_KEY = "mock-api-key";
configurable string PRODUCT = "test-product";

// Export Configuration
configurable int BATCH_SIZE = 100;
configurable string OUTPUT_DIRECTORY = "./exports";

// Tables to export - using constants for now, can be made configurable if needed
public final string[] TABLES = ["policies", "claims", "customers"];

// Mock Service Configuration
configurable boolean MOCK_SERVICE_ENABLED = true;
configurable int MOCK_SERVICE_PORT = 9090;

// Integration Test Configuration
configurable boolean INTEGRATION_TEST_ENABLED = true;
public final string[] TEST_TABLES = ["policies", "claims", "customers"];
configurable int TEST_PAGE_SIZE = 10;