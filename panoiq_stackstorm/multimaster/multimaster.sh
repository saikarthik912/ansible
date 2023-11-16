#!/bin/bash

# Parse the JSON object from the script command-line argument
json_object="$1"

# create vars.yaml file
yaml=$(python -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout)" <<< "$json_object")

echo "$yaml" > vars.yaml

# create all.yaml file inside group_vars folder 

json_string="$2"
echo "$json_string"

# Convert JSON to YAML using jq
yaml_output="/opt/stackstorm/packs/panoiq_stackstorm/multimaster/group_vars/all.yml"

echo "---" > "$yaml_output"  # Add the --- separator at the beginning

echo -n "$json_string" | jq -r '. | to_entries[] | "\(.key): \(.value)"' >> "$yaml_output"

#echo "Conversion complete: JSON -> YAML"


# Call the Ansible playbook and pass the variables using --extra-vars
ansible-playbook -i /opt/stackstorm/packs/panoiq_stackstorm/tool_installation/hosts playbook.yaml
