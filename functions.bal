import ballerina/io;
import ballerina/file;
import ballerina/regex;
import ballerina/log;
import ballerina/time;

// Response type for Vertafore API
public type VertafoteResponse record {
    json[] content;
    int recordCount;
    string? startingToken;
};

// Export JSON content to CSV file
public function exportToCSV(json[] content, string filename) returns error? {
    if (content.length() == 0) {
        log:printInfo("   No content to export");
        return ();
    }

    // Ensure directory exists
    string dirPath = "./exports";
    boolean dirExists = check file:test(dirPath, file:EXISTS);
    if (!dirExists) {
        check file:createDir(dirPath);
    }

    // Get field names from first record
    json firstRecord = content[0];
    string[] fieldnames = [];

    if (firstRecord is map<json>) {
        fieldnames = firstRecord.keys();
    } else {
        return error("Invalid record format");
    }

    // Create CSV content
    string[] csvLines = [];

    // Add header
    csvLines.push(string:'join(",", ...fieldnames));

    // Add data rows
    foreach json jsonRecord in content {
        if (jsonRecord is map<json>) {
            string[] values = [];
            foreach string fieldname in fieldnames {
                json fieldValue = jsonRecord[fieldname];
                string value = "";
                if (fieldValue != ()) {
                    value = fieldValue.toString();
                    // Escape quotes and wrap in quotes if contains comma
                    if (value.includes(",") || value.includes("\"")) {
                        string escapedValue = regex:replaceAll(value, "\"", "\"\"");
                        value = "\"" + escapedValue + "\"";
                    }
                }
                values.push(value);
            }
            csvLines.push(string:'join(",", ...values));
        }
    }

    // Write to file
    string csvContent = string:'join("\n", ...csvLines);
    check io:fileWriteString(filename, csvContent);

    log:printInfo(string `   Exported ${content.length()} records to CSV`);

    return ();
}

// Utility function to pad numbers with leading zeros
public function padNumber(int number, int totalLength) returns string {
    string numStr = number.toString();
    while (numStr.length() < totalLength) {
        numStr = "0" + numStr;
    }
    return numStr;
}

// Get a random value from an array (pseudo-random based on time)
public function getRandomValue(anydata[] values) returns anydata {
    // Simple pseudo-random selection based on current time
    time:Utc currentTime = time:utcNow();
    int index = <int>(currentTime[0] % values.length());
    return values[index];
}

// Convert JSON array to CSV format
public function convertJsonToCsv(json data) returns string {
    if (data is json[]) {
        if (data.length() == 0) {
            return "";
        }

        string csvContent = "";
        boolean headerWritten = false;

        foreach json item in data {
            if (item is map<json>) {
                // Write headers on first iteration
                if (!headerWritten) {
                    string headerRow = "";
                    foreach [string, json] [key, _] in item.entries() {
                        headerRow += key + ",";
                    }
                    // Remove trailing comma and add newline
                    if (headerRow.length() > 0) {
                        headerRow = headerRow.substring(0, headerRow.length() - 1);
                    }
                    csvContent += headerRow + "\n";
                    headerWritten = true;
                }

                // Write data row
                string row = "";
                foreach [string, json] [_, value] in item.entries() {
                    string valueStr = value is () ? "" : (value is string ? value : value.toString());
                    // Escape commas and quotes in CSV
                    if (valueStr.includes(",") || valueStr.includes("\"")) {
                        valueStr = "\"" + regex:replaceAll(valueStr, "\"", "\"\"") + "\"";
                    }
                    row += valueStr + ",";
                }
                // Remove trailing comma and add newline
                if (row.length() > 0) {
                    row = row.substring(0, row.length() - 1);
                }
                csvContent += row + "\n";
            }
        }
        return csvContent;
    }
    return "";
}