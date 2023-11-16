#!/bin/bash

# Parse the JSON object from the script command-line argument
json_object="$1"

yaml=$(python -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout)" <<< "$json_object")

echo "$yaml" > vars.yaml

# Call the Ansible playbook and pass the variables using --extra-vars
ansible-playbook -i /opt/stackstorm/packs/panoiq_stackstorm/tool_installation/hosts playbook.yaml
