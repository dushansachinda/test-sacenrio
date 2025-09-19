# Vertafore Data Lake API Integration

A complete Ballerina-based solution for integrating with the Vertafore Data Lake API, featuring both mock service capabilities and data export functionality. This project demonstrates modern Ballerina patterns with configurable backends, concurrent execution, and comprehensive CSV export capabilities.

## Project Structure

```
├── Config.toml            # Configuration settings (API URLs, credentials, etc.)
├── Ballerina.toml         # Project configuration
├── Dependencies.toml      # Auto-generated dependencies
├── config.bal             # Configurable variables and constants
├── connector.bal          # HTTP client and API connection logic
├── functions.bal          # Utility functions, types, and CSV export logic
├── main.bal               # Main application with integration modes
├── mock_service.bal       # Vertafore API mock service (port 9090)
├── exports/               # Directory for exported CSV files
└── README.md              # This documentation
```

## Features

- **🚀 Single Command Execution**: `bal run` starts everything - mock service, client, and CSV export
- **⚙️ Configurable Backends**: Switch between mock and real APIs via `Config.toml`
- **🔧 Mock Vertafore API**: Complete mock service with realistic data generation
- **📊 CSV Export**: Automatic JSON-to-CSV conversion with proper escaping and headers
- **📤 Dual Output Modes**: Export to local filesystem or SFTP server via configuration
- **🔄 Pagination Support**: Handle large datasets with `starting_token` and `page_size`
- **📋 Multiple Table Types**: Support for policies, claims, customers, agents, and transactions
- **⚡ Concurrent Execution**: Service and client run simultaneously using Ballerina futures
- **🛡️ Error Handling**: Comprehensive error handling and detailed logging
- **🔄 Dual Modes**: Integration test mode or production data export mode
- **🎯 Modern Architecture**: Clean separation of concerns with connector, functions, and main logic
- **🔐 SFTP Support**: Secure file transfer with configurable SFTP credentials

## Quick Start

### 1. Prerequisites

- Ballerina Swan Lake (latest version)
- No external dependencies required!

### 2. Run the Integration Test (Default Mode)

```bash
bal run
```

This single command will:
1. ✅ Start the mock Vertafore API service on port 9090
2. ✅ Wait for the service to initialize (3 seconds)
3. ✅ Test all configured API endpoints
4. ✅ Export test data to CSV files in `./exports/`
5. ✅ Display detailed logs and completion status

**Expected Output:**
```
🚀 Starting Vertafore Integration System...
Running integration test with mock service...
Waiting for mock service to start...
Testing policies endpoint...
✅ API call successful
   Record count: 10
   CSV exported to: ./exports/policies_test.csv
Testing claims endpoint...
...
🎉 Integration test completed!
```

### 3. Check the Generated Files

```bash
# View exported CSV files
ls -la exports/

# Preview a policies CSV file
head -5 exports/policies_test.csv
```

### 4. Switch to Production Mode

To run against a real Vertafore API, update `Config.toml`:

```toml
# Switch to production mode
INTEGRATION_TEST_ENABLED = false
BASE_URL = "https://your-vertafore-api.com"
API_KEY = "your-actual-api-key"
BATCH_SIZE = 1000
```

### 5. Enable SFTP Export (Optional)

To export CSV files directly to an SFTP server instead of local filesystem:

```toml
# Enable SFTP output
USE_FTP_OUTPUT = true

# Configure SFTP settings
sftpHost = "your-sftp-server.com"
sftpPort = 22
sftpUsername = "your-username"
sftpPassword = "your-password"
sftpOutputPath = "/remote/csv/directory"
```

Then run:
```bash
bal run
```

## Configuration

### Config.toml Settings

All application behavior is controlled through `Config.toml`:

```toml
# API Configuration
BASE_URL = "http://localhost:9090"
API_KEY = "mock-api-key"
PRODUCT = "test-product"

# Export Settings
BATCH_SIZE = 100
OUTPUT_DIRECTORY = "./exports"

# Mock Service Settings
MOCK_SERVICE_ENABLED = true
MOCK_SERVICE_PORT = 9090

# Mode Selection
INTEGRATION_TEST_ENABLED = true
TEST_PAGE_SIZE = 10

# File Output Configuration
USE_FTP_OUTPUT = false

# SFTP Configuration
sftpHost = "ftp.support.wso2.com"
sftpPort = 22
sftpUsername = "rosbanksub"
sftpPassword = "pAa.U!Nb02jds*z6$0i-"
sftpPath = "/rosbanksub/in"
sftpOutputPath = "/rosbanksub/csv"
```

### Configuration Options

| Setting | Description | Default | Example |
|---------|-------------|---------|---------|
| `BASE_URL` | API endpoint URL | `http://localhost:9090` | `https://api.vertafore.com` |
| `API_KEY` | Authentication key | `mock-api-key` | `your-actual-key` |
| `PRODUCT` | Vertafore product name | `test-product` | `production-product` |
| `BATCH_SIZE` | Records per API call | `100` | `1000` |
| `OUTPUT_DIRECTORY` | CSV export location | `./exports` | `./data/exports` |
| `INTEGRATION_TEST_ENABLED` | Test mode vs production | `true` | `false` |
| `TEST_PAGE_SIZE` | Records per test call | `10` | `5` |
| `USE_FTP_OUTPUT` | Export destination (FTP vs local) | `false` | `true` |
| `sftpHost` | SFTP server hostname | - | `ftp.support.wso2.com` |
| `sftpPort` | SFTP server port | `22` | `22` |
| `sftpUsername` | SFTP username | - | `rosbanksub` |
| `sftpPassword` | SFTP password | - | `your-password` |
| `sftpPath` | SFTP input directory | - | `/rosbanksub/in` |
| `sftpOutputPath` | SFTP output directory for CSV | - | `/rosbanksub/csv` |

## Architecture

### Application Modes

**Integration Test Mode** (`INTEGRATION_TEST_ENABLED = true`):
- Starts mock service on port 9090
- Runs client tests against mock endpoints
- Exports small test datasets to CSV
- Ideal for development and CI/CD

**Production Mode** (`INTEGRATION_TEST_ENABLED = false`):
- Connects to real Vertafore API
- Exports full datasets with pagination
- Handles large-scale data processing
- Production-ready error handling

### Component Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   main.bal      │    │  connector.bal  │    │  functions.bal  │
│                 │    │                 │    │                 │
│ • Mode logic    │───▶│ • HTTP client   │───▶│ • CSV export    │
│ • Futures       │    │ • API calls     │    │ • Utilities     │
│ • Coordination  │    │ • Error handling│    │ • Types         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐
│ mock_service.bal│    │   config.bal    │
│                 │    │                 │
│ • Mock API      │    │ • Settings      │
│ • Data generation│   │ • Defaults      │
│ • Port 9090     │    │ • Constants     │
└─────────────────┘    └─────────────────┘
```

### Execution Flow

1. **Startup**: `main.bal` reads configuration and determines mode
2. **Mock Service**: Automatically starts HTTP listener on port 9090
3. **Client Logic**: Runs in separate future/worker thread
4. **API Calls**: `connector.bal` handles HTTP requests with retries
5. **Data Processing**: `functions.bal` converts JSON to CSV format
6. **Export**: CSV files written to configured output directory

## API Reference

### Mock Service Endpoints

The mock service simulates the Vertafore Data Lake API:

**Base URL**: `http://localhost:9090`

### GET `/consumer/v1/{product}/tables/{table}`

**Supported Tables:**

| Table | Description | Record Count | Fields |
|-------|-------------|--------------|--------|
| `policies` | Insurance policies | 5,000 | PolicyID, PolicyNumber, CustomerID, AgentID, ProductType, etc. |
| `claims` | Insurance claims | 12,000 | ClaimID, ClaimNumber, PolicyID, ClaimType, ClaimStatus, etc. |
| `customers` | Customer records | 8,000 | CustomerID, FirstName, LastName, EmailAddress, etc. |
| `agents` | Agent information | 200 | AgentID, FirstName, LastName, LicenseNumber, etc. |
| `transactions` | Transaction records | 25,000 | TransactionID, PolicyID, TransactionType, Amount, etc. |

**Query Parameters:**
- `page_size` (optional): Records per page (default: 100, max: 1000)
- `starting_token` (optional): Pagination token for next page

**Example Request:**
```bash
curl "http://localhost:9090/consumer/v1/test-product/tables/policies?page_size=5"
```

**Response Format:**
```json
{
  "content": [
    {
      "PolicyID": "POL00000001",
      "PolicyNumber": "P-000001",
      "CustomerID": "CUST000002",
      "AgentID": "AGT0002",
      "ProductType": "Auto",
      "PolicyStatus": "Active",
      "PremiumAmount": 625.75,
      "DeductibleAmount": 250,
      "EffectiveDate": "2024-01-01T00:00:00.000Z",
      "ExpirationDate": "2024-12-31T23:59:59.000Z",
      "CreatedDate": "2025-09-19T00:23:19.791Z",
      "LastModifiedDate": "2025-09-19T00:23:19.791Z",
      "TotalCoverage": 125000,
      "PaymentFrequency": "Annual"
    }
  ],
  "starting_token": "10",
  "recordCount": 1
}
```

### Manual Testing

```bash
# Test different endpoints
curl "http://localhost:9090/consumer/v1/test-product/tables/policies?page_size=3"
curl "http://localhost:9090/consumer/v1/test-product/tables/claims?page_size=3"
curl "http://localhost:9090/consumer/v1/test-product/tables/customers?page_size=3"

# Test pagination
curl "http://localhost:9090/consumer/v1/test-product/tables/policies?page_size=5&starting_token=10"
```

## CSV Export Details

### Output Files

**Integration Test Mode** creates test files:
- `policies_test.csv` - Sample policy records (10 records)
- `claims_test.csv` - Sample claim records (10 records)
- `customers_test.csv` - Sample customer records (10 records)

**Production Mode** creates full exports:
- `policies.csv` - Complete policy dataset with pagination
- `claims.csv` - Complete claims dataset with pagination
- `customers.csv` - Complete customer dataset with pagination
- Additional files: `{table}_page_{token}.csv` for paginated data

### Output Destinations

**Local Filesystem** (`USE_FTP_OUTPUT = false`):
- Files saved to `OUTPUT_DIRECTORY` (default: `./exports/`)
- Direct file system access for immediate processing

**SFTP Server** (`USE_FTP_OUTPUT = true`):
- Files uploaded directly to configured SFTP server
- Automatic cleanup of temporary local files
- Secure transfer with username/password authentication
- Files saved to `sftpOutputPath` directory on remote server

### CSV Features

| Feature | Description | Example |
|---------|-------------|---------|
| **Headers** | JSON field names as CSV headers | `PolicyID,PolicyNumber,CustomerID...` |
| **Escaping** | Proper quote/comma escaping | `"Text with, comma"` |
| **Encoding** | UTF-8 support | International characters |
| **Null Handling** | Empty strings for null values | `POL001,,CUST002` |
| **Type Preservation** | Numbers and dates as strings | `625.75`, `2024-01-01T00:00:00.000Z` |

### Sample Output

**policies_test.csv:**
```csv
PolicyID,PolicyNumber,CustomerID,AgentID,ProductType,PolicyStatus,PremiumAmount
POL00000001,P-000001,CUST000002,AGT0002,Auto,Active,625.75
POL00000002,P-000002,CUST000003,AGT0003,Home,Pending,751.5
POL00000003,P-000003,CUST000004,AGT0004,Life,Active,877.25
```

### Data Quality

**Realistic Relationships:**
- Policies → Customers (via CustomerID)
- Claims → Policies (via PolicyID)
- Transactions → Policies (via PolicyID)
- Agents → Territories (logical grouping)

**Consistent Formatting:**
- IDs: `POL00000001`, `CUST000002`, `AGT0004`
- Dates: ISO 8601 format (`2024-01-01T00:00:00.000Z`)
- Amounts: Decimal precision (`625.75`, `1000.00`)

## Development Guide

### Project Evolution

This project demonstrates a complete migration from Python to Ballerina:

**Original Python Implementation:**
- Separate `test_integration.py` script
- External `requests` library for HTTP
- Manual CSV writing with Python's `csv` module
- Required separate service startup

**Current Ballerina Implementation:**
- Single-command execution (`bal run`)
- Native HTTP client and service capabilities
- Built-in JSON processing and CSV generation
- Concurrent execution with futures
- Configurable backends via Config.toml

### Key Ballerina Features Demonstrated

| Feature | Usage | Benefit |
|---------|-------|---------|
| **Configurable Variables** | `configurable string BASE_URL` | External configuration |
| **HTTP Service** | `service /consumer/v1 on new http:Listener(9090)` | Native REST API |
| **HTTP Client** | `http:Client httpClient = check new(baseUrl)` | Built-in HTTP support |
| **Futures** | `future<error?> clientFuture = start runTest()` | Concurrent execution |
| **JSON Processing** | `json[] content = <json[]>check jsonPayload.content` | Type-safe JSON |
| **Error Handling** | `check`, `?`, union types | Comprehensive error management |
| **String Templates** | `string \`Calling API: ${baseUrl}\`` | Clean interpolation |

### Code Organization

**Separation of Concerns:**
- `config.bal` - Configuration and constants
- `connector.bal` - HTTP client logic and API calls
- `functions.bal` - Utility functions and CSV export
- `main.bal` - Application orchestration and mode selection
- `mock_service.bal` - Mock API service implementation

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| **Port 9090 in use** | Another service using port | `lsof -i :9090` and kill process |
| **Connection timeout** | Service startup delay | Wait 3-5 seconds after `bal run` |
| **Compilation errors** | Syntax or import issues | Check `bal version`, verify syntax |
| **Empty CSV files** | API response errors | Check logs for JSON parsing errors |
| **Config errors** | Wrong Config.toml format | Verify variable names match config.bal |

### Debugging Steps

1. **Check Service Status:**
   ```bash
   # Test if mock service is responding
   curl "http://localhost:9090/consumer/v1/test-product/tables/policies?page_size=2"
   ```

2. **Verify Configuration:**
   ```bash
   # Check current config values
   bal run --config-file=Config.toml
   ```

3. **Monitor Logs:**
   ```bash
   # Run with verbose logging
   bal run 2>&1 | grep -E "(INFO|ERROR)"
   ```

### Expected Output

**Successful Integration Test:**
```
🚀 Starting Vertafore Integration System...
Running integration test with mock service...
Waiting for mock service to start...
Testing policies endpoint...
✅ API call successful
   Record count: 10
   CSV exported to: ./exports/policies_test.csv
🎉 Integration test completed!
```

## Production Deployment

### Configuration Checklist

- [ ] Update `BASE_URL` to production Vertafore API
- [ ] Set real `API_KEY` credentials
- [ ] Configure production `PRODUCT` name
- [ ] Set `INTEGRATION_TEST_ENABLED = false`
- [ ] Adjust `BATCH_SIZE` for performance
- [ ] Configure appropriate `OUTPUT_DIRECTORY`

### Security Considerations

- Store API keys securely (environment variables, secrets management)
- Use HTTPS for production API endpoints
- Implement proper authentication token refresh
- Add rate limiting and retry logic
- Monitor API usage and costs

### Performance Tuning

- Adjust `BATCH_SIZE` based on API limits
- Implement parallel processing for multiple tables
- Add progress monitoring for large datasets
- Configure appropriate timeouts and retries

## Contributing

This project demonstrates Ballerina best practices for:
- Configurable applications
- HTTP service and client development
- Concurrent programming with futures
- JSON processing and CSV export
- Error handling and logging

## License

This project is part of a WSO2 Solutions Architecture POC.