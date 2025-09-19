import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/lang.runtime;

// Vertafore Data Lake API Mock Server
// Endpoint: GET /consumer/v1/{product}/tables/{table}
service /consumer/v1 on new http:Listener(9090) {

    resource function get [string product]/tables/[string tableName](
        http:Caller caller,
        http:Request req
    ) returns error? {

        // Extract query parameters manually
        string? starting_token = req.getQueryParamValue("starting_token");
        string? page_size_str = req.getQueryParamValue("page_size");
        int page_size = 100;

        if (page_size_str is string) {
            int|error parsed_size = int:fromString(page_size_str);
            if (parsed_size is int) {
                page_size = parsed_size;
            }
        }

        log:printInfo(string `Mock API Request: product=${product}, table=${tableName}, starting_token=${starting_token ?: "null"}, page_size=${page_size}`);

        // Simulate API processing delay
        runtime:sleep(0.1);

        // Generate mock response with exact Vertafore structure
        json response = generateVertaforeResponse(tableName, starting_token, page_size);

        // Set response headers
        http:Response httpResponse = new;
        httpResponse.setJsonPayload(response);
        httpResponse.setHeader("Content-Type", "application/json");
        httpResponse.setHeader("Access-Control-Allow-Origin", "*");

        check caller->respond(httpResponse);
    }

    // Handle OPTIONS for CORS
    resource function options [string product]/tables/[string tableName](http:Caller caller) returns error? {
        http:Response response = new;
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type");
        check caller->respond(response);
    }
}

// Generate response matching Vertafore Data Lake API structure
function generateVertaforeResponse(string tableName, string? starting_token, int page_size) returns json {
    // Parse starting position from token
    int startPosition = 0;
    if (starting_token is string && starting_token.trim() != "") {
        int|error tokenValue = int:fromString(starting_token);
        startPosition = tokenValue is int ? tokenValue : 0;
    }

    // Generate content array based on table type
    json[] content = [];
    int recordsToGenerate = page_size > 1000 ? 50 : (page_size < 10 ? 10 : page_size);

    int i = 0;
    while (i < recordsToGenerate) {
        int recordId = startPosition + i + 1;
        json tableRecord = generateTableRecord(tableName, recordId);
        content.push(tableRecord);
        i += 1;
    }

    // Calculate next starting_token for pagination
    string? nextToken = ();
    int totalRecords = getTotalRecordsForTable(tableName);
    int nextPosition = startPosition + recordsToGenerate;

    if (nextPosition < totalRecords) {
        nextToken = nextPosition.toString();
    }

    // Return exact Vertafore API structure
    return {
        "content": content,
        "starting_token": nextToken,
        "recordCount": content.length()
    };
}

// Generate realistic record data based on table name
function generateTableRecord(string tableName, int id) returns json {
    time:Utc currentTime = time:utcNow();
    string timestamp = time:utcToString(currentTime);

    string tableLower = tableName.toLowerAscii();

    if (tableLower == "policies" || tableLower == "policy") {
        return {
            "PolicyID": string `POL${padNumber(id, 8)}`,
            "PolicyNumber": string `P-${padNumber(id, 6)}`,
            "CustomerID": string `CUST${padNumber(id % 1000 + 1, 6)}`,
            "AgentID": string `AGT${padNumber(id % 50 + 1, 4)}`,
            "ProductType": <string>getRandomValue(["Auto", "Home", "Life", "Commercial", "Umbrella"]),
            "PolicyStatus": <string>getRandomValue(["Active", "Pending", "Cancelled", "Expired", "Suspended"]),
            "PremiumAmount": id * 125.75 + 500.00,
            "DeductibleAmount": <int>getRandomValue([250, 500, 1000, 2500, 5000]),
            "EffectiveDate": "2024-01-01T00:00:00.000Z",
            "ExpirationDate": "2024-12-31T23:59:59.000Z",
            "CreatedDate": timestamp,
            "LastModifiedDate": timestamp,
            "TotalCoverage": id * 25000 + 100000,
            "PaymentFrequency": <string>getRandomValue(["Monthly", "Quarterly", "Semi-Annual", "Annual"])
        };
    } else if (tableLower == "claims" || tableLower == "claim") {
        return {
            "ClaimID": string `CLM${padNumber(id, 10)}`,
            "ClaimNumber": string `C-${padNumber(id, 8)}`,
            "PolicyID": string `POL${padNumber(id % 2000 + 1, 8)}`,
            "ClaimType": <string>getRandomValue(["Collision", "Comprehensive", "Liability", "Property", "Theft", "Fire"]),
            "ClaimStatus": <string>getRandomValue(["Open", "Closed", "Pending", "Under Review", "Approved", "Denied"]),
            "ClaimAmount": id * 875.25 + 1000.00,
            "DeductibleAmount": <int>getRandomValue([250, 500, 1000, 2000]),
            "DateOfLoss": "2024-01-15T00:00:00.000Z",
            "ReportedDate": "2024-01-16T09:30:00.000Z",
            "CloseDate": (),
            "CreatedDate": timestamp,
            "LastModifiedDate": timestamp,
            "AdjusterID": string `ADJ${padNumber(id % 25 + 1, 4)}`,
            "EstimatedAmount": id * 750.00 + 800.00
        };
    } else if (tableLower == "customers" || tableLower == "customer") {
        return {
            "CustomerID": string `CUST${padNumber(id, 6)}`,
            "FirstName": <string>getRandomValue(["John", "Jane", "Michael", "Sarah", "David", "Lisa", "Robert", "Maria", "James", "Jennifer"]),
            "LastName": <string>getRandomValue(["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"]),
            "EmailAddress": string `customer${id}@email.com`,
            "PhoneNumber": string `(555) ${padNumber(id % 900 + 100, 3)}-${padNumber(id % 9000 + 1000, 4)}`,
            "DateOfBirth": "1980-05-15T00:00:00.000Z",
            "Gender": <string>getRandomValue(["Male", "Female", "Other"]),
            "AddressLine1": string `${id} Main Street`,
            "AddressLine2": <string?>getRandomValue([(), "Apt 1", "Suite 100", "Unit B"]),
            "City": <string>getRandomValue(["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego"]),
            "State": <string>getRandomValue(["NY", "CA", "IL", "TX", "AZ", "PA", "FL", "OH"]),
            "PostalCode": padNumber(id % 90000 + 10000, 5),
            "Country": "USA",
            "CustomerSince": "2020-01-01T00:00:00.000Z",
            "CustomerStatus": <string>getRandomValue(["Active", "Inactive", "Suspended"]),
            "CreatedDate": timestamp,
            "LastModifiedDate": timestamp
        };
    } else if (tableLower == "agents" || tableLower == "agent") {
        return {
            "AgentID": string `AGT${padNumber(id, 4)}`,
            "FirstName": <string>getRandomValue(["Robert", "Maria", "James", "Patricia", "Michael", "Jennifer", "William", "Linda"]),
            "LastName": <string>getRandomValue(["Anderson", "Taylor", "Thomas", "Hernandez", "Moore", "Martin", "Jackson", "Thompson"]),
            "EmailAddress": string `agent${id}@company.com`,
            "PhoneNumber": string `(555) ${padNumber(id % 900 + 100, 3)}-${padNumber(id % 9000 + 1000, 4)}`,
            "LicenseNumber": string `LIC${padNumber(id, 8)}`,
            "LicenseState": <string>getRandomValue(["NY", "CA", "TX", "FL", "IL", "PA", "OH", "GA"]),
            "Territory": <string>getRandomValue(["North", "South", "East", "West", "Central", "Northeast", "Southeast", "Northwest"]),
            "CommissionRate": <float>(id % 10 + 5) / 100.0,
            "HireDate": "2020-01-01T00:00:00.000Z",
            "AgentStatus": <string>getRandomValue(["Active", "Inactive", "On Leave", "Terminated"]),
            "SupervisorID": id > 10 ? string `AGT${padNumber(id % 10 + 1, 4)}` : (),
            "CreatedDate": timestamp,
            "LastModifiedDate": timestamp
        };
    } else if (tableLower == "transactions" || tableLower == "transaction") {
        return {
            "TransactionID": string `TXN${padNumber(id, 10)}`,
            "PolicyID": string `POL${padNumber(id % 2000 + 1, 8)}`,
            "TransactionType": <string>getRandomValue(["New Business", "Renewal", "Endorsement", "Cancellation", "Reinstatement"]),
            "TransactionAmount": id * 45.75 + 25.00,
            "TransactionDate": "2024-01-15T14:30:00.000Z",
            "EffectiveDate": "2024-01-15T00:00:00.000Z",
            "TransactionStatus": <string>getRandomValue(["Completed", "Pending", "Failed", "Cancelled"]),
            "PaymentMethod": <string>getRandomValue(["Credit Card", "Bank Transfer", "Check", "Auto Pay"]),
            "CreatedDate": timestamp,
            "LastModifiedDate": timestamp
        };
    } else {
        // Generic table structure
        return {
            "ID": id,
            "TableName": tableName,
            "RecordName": string `${tableName}_record_${id}`,
            "Value": id * 10.5,
            "Status": <string>getRandomValue(["Active", "Inactive"]),
            "CreatedDate": timestamp,
            "LastModifiedDate": timestamp
        };
    }
}

function getTotalRecordsForTable(string tableName) returns int {
    // Simulate different table sizes
    string tableLower = tableName.toLowerAscii();
    if (tableLower == "policies" || tableLower == "policy") {
        return 5000;
    } else if (tableLower == "claims" || tableLower == "claim") {
        return 12000;
    } else if (tableLower == "customers" || tableLower == "customer") {
        return 8000;
    } else if (tableLower == "agents" || tableLower == "agent") {
        return 200;
    } else if (tableLower == "transactions" || tableLower == "transaction") {
        return 25000;
    } else {
        return 1000;
    }
}