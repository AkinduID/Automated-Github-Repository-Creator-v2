
# Description.
#
# + name - field description  
# + color - field description  
# + description - field description
public type LabelData record {
    // int? id;
    // string? node_id;
    // string? url;
    string name;
    string color;
    string? description;
    // boolean?default;
};

// Predefined labels
public LabelData[] labelsList = [
    { name: "Type/Bug", color: "1d76db", description: "Identifies a bug in the project" },
    { name: "Type/New Feature", color: "1d76db", description: "Represents a request or task for a new feature" },
    { name: "Type/Epic", color: "1d76db", description: "Denotes an epic, which is a large body of work that encompasses multiple tasks" },
    { name: "Type/Improvement", color: "1d76db", description: "Marks enhancements or improvements to existing features" },
    { name: "Type/Task", color: "1d76db", description: "General task that does not fit into other categories" },
    { name: "Type/UX", color: "1d76db", description: "Refers to user experience-related tasks or issues" },
    { name: "Type/Question", color: "1d76db", description: "Highlights queries or clarifications needed" },
    { name: "Type/Docs", color: "1d76db", description: "Indicates documentation-related tasks or updates" },
    { name: "Severity/Blocker", color: "b60205", description: "Represents a blocking issue that prevents progress" },
    { name: "Severity/Critical", color: "b60205", description: "Indicates a critical problem requiring immediate attention" },
    { name: "Severity/Major", color: "b60205", description: "Highlights major issues but not blockers" },
    { name: "Severity/Minor", color: "b60205", description: "Marks minor issues or inconveniences" },
    { name: "Severity/Trivial", color: "b60205", description: "Denotes very low-impact issues" },
    { name: "Priority/Highest", color: "ff9900", description: "Urgent tasks requiring immediate action" },
    { name: "Priority/High", color: "ff9900", description: "High-priority tasks to be completed soon" },
    { name: "Priority/Normal", color: "ff9900", description: "Tasks with a normal priority level" },
    { name: "Priority/Low", color: "ff9900", description: "Low-priority tasks that can be deferred" },
    { name: "Resolution/Fixed", color: "93c47d", description: "Indicates issues that have been resolved" },
    { name: "Resolution/Won’t Fix", color: "93c47d", description: "Marks issues that will not be addressed" },
    { name: "Resolution/Duplicate", color: "93c47d", description: "Denotes duplicate issues" },
    { name: "Resolution/Cannot Reproduce", color: "93c47d", description: "Issues that could not be replicated" },
    { name: "Resolution/Not a bug", color: "93c47d", description: "Specifies that the reported issue is not a bug" },
    { name: "Resolution/Invalid", color: "93c47d", description: "Marks invalid issues or requests" },
    { name: "Resolution/Postponed", color: "93c47d", description: "Indicates deferred tasks or issues" }
];
