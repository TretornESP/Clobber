from flask import Flask, request, render_template, make_response
import zipfile
import os, shutil
import json
from dbmanager import DBManager
from command import Command
import tester
import psutil

app = Flask(__name__)
app.jinja_env.auto_reload = True
app.config['TEMPLATES_AUTO_RELOAD'] = True
app.config['UPLOAD_FOLDER'] = "/home/clobber/cdata/uploads"
app.config['MAX_CONTENT_PATH'] = 1024*1024

manager = DBManager("/home/clobber/cdata/commands.sqlite")

def get_fs_type(mypath):
    root_type = ""
    for part in psutil.disk_partitions():
        if part.mountpoint == '/':
            root_type = part.fstype
            continue

        if mypath.startswith(part.mountpoint):
            return part.fstype

    return root_type

@app.route("/", methods=["GET"])
def starting_url():
    json_data = request.json
    a_value = json_data["a_key"]
    return "JSON value sent: " + a_value
@app.route("/test")
def test():
    return get_fs_type("/home/clobber/cdata")
@app.route("/management/emptyRules")
def cleanup():
    manager.empty()
    shutil.rmtree("/scripts")
    os.makedirs("/scripts")
    return "ok"
@app.route("/apps/<template>")
def apps(template):
    return make_response(render_template(
        template
    ))
@app.route("/commands/")
def show_commands():
    commands = manager.get_all_commands()
    if len(commands) > 0:
        return json.dumps(commands)
    else:
        return "No commands installed"
@app.route("/commands/<cmd>")
@app.route("/commands/<cmd>/<params>")
def commands(cmd, params=""):
    command = manager.get_command(cmd)
    if command==None:
        return 'Error, command doesnt exist'
    return command.execute(params)

@app.route("/management/addRuleFile", methods=['GET', 'POST'])
def addRuleFile():
    if request.method == 'POST':
        f = request.files['file']
        if f.filename != '':
            try:
                zip_handle = zipfile.ZipFile(f._file)
                zip_handle.extractall(app.config['UPLOAD_FOLDER'])
                zip_handle.close()
                command = Command(os.path.join(app.config['UPLOAD_FOLDER'], os.path.splitext(f.filename)[0]))
                if manager.add(command):
                    out = 'url /commands/'+command.get_name()+' registered successfully'
                else:
                    out = 'Error duplicated key'
                shutil.rmtree(os.path.join(app.config['UPLOAD_FOLDER'], os.path.splitext(f.filename)[0]))
            except zipfile.BadZipFile:
                out = 'corrupted zip file!'
        else:
            out = 'No file specified'
        return out
    elif request.method == 'GET':
        return render_template('uploader.html')
