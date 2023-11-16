from st2common.runners.base_action import Action
import subprocess
import os
class ExecuteShellScriptAction(Action):
    def run( self, json_parameter):
        try:
            os.chdir("/opt/stackstorm/packs/panoiq_stackstorm/prometheus");
            script_path = "/opt/stackstorm/packs/panoiq_stackstorm/prometheus/init.sh"
            command = [script_path, json_parameter]

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
