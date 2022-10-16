#!/usr/bin/python3

import json
import glob
import subprocess
from os import environ

recon = environ.get("recon")
results = environ.get("results")

for file in glob.glob(f"{results}/nmap/processed/*.json"):
    file =  open(file).read()
    json_file = json.loads(file)
    
    try:
        for host in json_file["Host"]:
            address = host["HostAddress"]["Address"]
            ports = [{
                "port": port["PortID"],
                "protocol": port["Protocol"],
                "service": port["Service"]["Name"],
                "status": port["State"]["State"],
            } for port in host["Port"]]
            for port in ports:
                fstring = "{}:{port}:{protocol} -t status:{status} -t service:{service}".format(address, **port)
                subprocess.run(f"{recon}/nmap/handler/_nmap_add.sh {fstring}".split(" "))
    except:
        continue
