import ballerina/regex;

# Function to add Default teams to team list
# 
# + organization - organization name
# + teams - list of teams
# + return - updated list of teams
public isolated function addDefaultTeams(string organization, string[] teams) 
returns string[]{
    teams.push("Infra");
    teams.push("gitopslab-all");
    teams.push("gitopslab-all-interns");
    if organization == "gitopslab-extensions"{
        teams.push("connector-store-rw-bot");
    }
    if organization != "gitopslab_incubator"{
        teams.push("engineering-readonly-bots");
    }
    string[] otherTeams = [];
    foreach string team in teams {
        if string:includes(team, "-internal-commiters") {
            if organization == "wso2-enterprise" {
                otherTeams.push(regex:replace(team, "-internal-commiters", "-readonly"));
            }
            else{
                otherTeams.push(regex:replace(team, "-internal-commiters", "-external-commiters"));
            }
        }
    }
    teams.push(...otherTeams);
    string[] slugs = createSlug(teams);
    return slugs;
}

# Function to create slugs for team names
# 
# + teamList - list of team names
# + return - list of slugs
public isolated function createSlug(string[] teamList) returns string[] {
    string[] slugs = [];
    foreach string name in teamList {
        string normalized = regex:replaceAll(name, "[^a-zA-Z0-9\\s-]", "");
        string lowerCased = string:toLowerAscii(normalized);
        string slug = regex:replaceAll(lowerCased, "\\s+", "-");
        slugs.push(slug);
    }
    return slugs;
}