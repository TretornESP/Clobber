from flask import Flask, request, redirect
import subprocess
import json


app = Flask(__name__)
app.jinja_env.auto_reload = True


@app.route("/names/<name>", methods=["GET"])
def starting_url(name):
    cmd = "/Clobber/docker_scripts/get_instance.sh " + name
    sp = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    subprocess_out = sp.stdout.read()

    tokens = request.host_url.split(':')
    url = tokens[0]+':'+tokens[1]+':'+str(subprocess_out, "utf-8").strip()
    template = "/apps/desktop.html"
    print("Redirecting to: " + url + template)
    return redirect(url+template, 302)
