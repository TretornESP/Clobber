import os, shutil, uuid, subprocess, string
import json
class Command:
    SCRIPTS_PATH = "/scripts"

    def __init__(self, filename):
        self.code = str(uuid.uuid4())[:8]
        self.name = None
        self.command = None
        self.filter = None
        self.errfilter = None
        self.futures = False
        self.parse_json_command(filename)

    def parse_json_command(self, path):
        if self.name != None:
            return
        with open(os.path.join(path, 'rule.json')) as config:
            data = json.load(config)
            self.name = data['name']
            if "errfilter" in data:
                self.errfilter = data['errfilter']
            if "async" in data:
                self.futures = data['async']
            if os.path.isfile(os.path.join(path, 'command.sh')):
                self.command = shutil.copyfile(os.path.join(path, 'command.sh'), os.path.join(self.SCRIPTS_PATH, self.code.join('_command.sh')))
            else:
                self.command = data['command']
            if os.path.isfile(os.path.join(path, 'filter.sh')):
                self.filter = shutil.copyfile(os.path.join(path, 'filter.sh'), os.path.join(self.SCRIPTS_PATH, self.code.join('_filter.sh')))
            else:
                if "filter" in data:
                    self.filter = data['filter']

    def get_name(self):
        return self.name

    def execute(self, params):
        filtered_output = ""
        filtered_error = ""
        print("PARAMS: "+params, flush=True)
        cmd = self.command.replace("%params%", params)
        print(cmd, flush=True)
        sp = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        subprocess_out = sp.stdout.read()
        subprocess_err = sp.stderr.read()

        if self.filter != None:
            outfilter = subprocess.Popen(self.filter, shell=True, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
            filtered_output = outfilter.communicate(subprocess_out)
        if self.errfilter != None:
            errfilter = subprocess.Popen(self.errfilter, shell=True, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
            filtered_error = errfilter.communicate(subprocess_err)

        out = {
            "stdout": str(subprocess_out),
            "stderr": str(subprocess_err),
            "stdout_filtered": str(filtered_output),
            "stderr_filtered": str(filtered_error)
        }

        return json.dumps(out)
