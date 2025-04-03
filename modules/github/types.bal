// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

# Record to represent github label data
public type LabelData record {
    # Label ID
    string name;
    # Label color
    string color;
    # Label description
    string description;
};

# Record to represent the result of a GitHub operation.
public type gitHubOperationResult record {
    # Name of the operation (e.g., "Add Topics", "Add Labels").
    string operation;
    # Status of the operation (e.g., "success", "failure").
    string status;
    # Optional error message if the operation failed.
    string|null errorMessage;
};
