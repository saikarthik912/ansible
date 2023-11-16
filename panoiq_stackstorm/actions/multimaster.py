from st2common.runners.base_action import Action
import subprocess
import os
import json

class ExecuteShellScriptAction(Action):
    def run(self, json_parameter):
        try:
            # os.chdir("/opt/stackstorm/packs/panoiq_stackstorm/multimaster")
            #create host file entry
             
            data = json.loads(json_parameter)
            print("data", data)
            master_ips = data.get("master_ips", []);
            print("master_ips", master_ips)
            worker_ips = data.get("worker_ips", []);
            print("worker_ips", worker_ips)
            
            self.create_hosts_file(master_ips, worker_ips)

            groups_obj = {
                "kubernetes_version": "1.20.0",
                "pod_network_cidr": "10.244.0.0/16",
                "master1_private_IP": master_ips[0],
                "ansible_user": "ec2-user",
                "master1": master_ips[0],
                "added_nodes": "false"        
            }
            groups_json_object = json.dumps(groups_obj, indent=4)
            os.chdir("/opt/stackstorm/packs/panoiq_stackstorm/multimaster")
            script_path = "/opt/stackstorm/packs/panoiq_stackstorm/multimaster/multimaster.sh"
            command = [script_path, json_parameter, groups_json_object]
        
            # Execute the shell script
            process = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True
            )
            stdout, stderr = process.communicate()

            # Check the exit code to see if the script succeeded
            exit_code = process.returncode
            if exit_code != 0:
                error_message = f"Script failed with exit code {exit_code}\n"
                error_message += f"Standard output:\n{stdout}\n"
                error_message += f"Standard error:\n{stderr}\n"
                raise Exception(error_message)

            # Return the output
            return {
                "stdout": stdout,
                "stderr": stderr,
                "exit_code": exit_code
            }

        except Exception as e:
            # Catch any exceptions that might occur during execution
            return {
                "error": str(e)
            }

    def create_hosts_file(self, master_ips, worker_ips):
        # Your create_hosts_file implementation goes here
        # Make sure to indent the function correctly
        os.chdir("/opt/stackstorm/packs/panoiq_stackstorm/tool_installation")
        all_servers = sorted(master_ips + worker_ips)
        print(master_ips[0])
        master1 = [master_ips[0]]
        print(master1)
        masters = sorted(master_ips)
        workers = sorted(worker_ips)
        worker_join = sorted(worker_ips)
        master_join = sorted(master_ips[1:])
        all_except_master1 = sorted(master_ips[1:] + worker_ips)

 

        with open('hosts', 'w') as f:
            f.write('[allServers]\n')
            for ip in all_servers:
                f.write(ip + '\n')

 

            f.write('\n[master1]\n')
            for ip in master1:
                f.write(ip + '\n')

 

            f.write('\n[masters]\n')
            for ip in masters:
                f.write(ip + '\n')

 

            f.write('\n[workers]\n')
            for ip in workers:
                f.write(ip + '\n')

 

            f.write('\n[workerjoin]\n')
            for ip in worker_join:
                f.write(ip + '\n')

 

            f.write('\n[masterjoin]\n')
            for ip in master_join:
                f.write(ip + '\n')

 

            f.write('\n[allexceptmaster1]\n')
            for ip in all_except_master1:
                f.write(ip + '\n')

 

