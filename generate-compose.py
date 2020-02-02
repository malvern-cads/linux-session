INSTANCES = 30
INSTANCE_RAM = 512
INSTANCE_CPU = 0.5

output = ["version: '2.4'", "services:"]
volumes = []

for i in range(1, INSTANCES + 1):
    pretty_number = str(i).zfill(2)
    output.append("    linux{}:".format(pretty_number))
    output.append("        image: cadscheme/cads-linux")
    output.append("        container_name: linux{}".format(pretty_number))
    output.append("        cpus: {}".format(INSTANCE_CPU))
    output.append("        mem_limit: {}m".format(INSTANCE_RAM))
    output.append("        volumes:")
    output.append("            - linux{}_home:/home".format(pretty_number))
    output.append("            - linux{}_root:/root".format(pretty_number))
    output.append("        networks:")
    output.append("            - default")
    output.append("        hostname: linux{}".format(pretty_number))

    volumes.append("linux{}_home".format(pretty_number))
    volumes.append("linux{}_root".format(pretty_number))

output.append("networks:")
output.append("    default:")
output.append("        external:")
output.append("            name: cads")
output.append("volumes:")

for volume in volumes:
    output.append("    {}:".format(volume))

output = [line + "\n" for line in output]

with open("docker-compose.yml", "w") as f:
    f.writelines(output)
    f.close()