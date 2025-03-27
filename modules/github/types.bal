# Recordd to represent github label data
#
# + name - name of the label  
# + color - label color
# + description - label description
public type LabelData record {
    string name;
    string color;
    string? description;
};