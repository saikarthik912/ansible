from st2common.runners.base_action import Action
import subprocess
import os
class ExecuteShellScriptAction(Action):
    def run(self, master_ips, worker_ips):
        try:
            os.chdir("/opt/stackstorm/packs/panoiq_stackstorm/multimaster");
            create_hosts_file(master_ips, worker_ips)
            script_path = "/opt/stackstorm/packs/panoiq_stackstorm/multimaster/multimaster.sh"
            command = [script_path]
            print(command);

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

    def create_hosts_file(master_ips, worker_ips):
        all_servers = sorted(master_ips + worker_ips)
        master1 = [master_ips[0]]
        masters = sorted(master_ips)
        workers = sorted(worker_ips)
        worker_join = sorted(worker_ips)
        master_join = sorted(master_ips[1:])
        all_except_master1 = sorted(master_ips[1:] + worker_ips)

 
        with open('hosts_file.txt', 'w') as f:
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

 

 

