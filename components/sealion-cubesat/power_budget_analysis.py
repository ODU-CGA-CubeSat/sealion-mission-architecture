#!/usr/bin/python
from pint import UnitRegistry
import yaml
import traceback
from jinja2.nativetypes import NativeEnvironment


u = UnitRegistry()
env = NativeEnvironment()

with open("operatingScenarios.yaml", "r") as file:
    operating_scenarios = yaml.safe_load(file.read())

print("scenarios:")
for scenario in operating_scenarios:
    print(" ", scenario, ":")
    for scenario_step in operating_scenarios[scenario]:
        print("    -")
        # print("     ", scenario_step)
        # print("     ", scenario_step_key, ":")
        # print operating mode
        print("      operatingMode :", scenario_step["operatingMode"])
        print("      parameters :")
        for parameter_name in scenario_step["parameters"]:
            parameter_value = scenario_step["parameters"][parameter_name]["value"]
            parameter_units = scenario_step["parameters"][parameter_name]["units"]
            if type(parameter_value) == str:
                t = env.from_string(parameter_value)
                try:
                    min_power_generation_value = scenario_step["parameters"][
                        "minPowerGeneration"
                    ]["value"]
                except KeyError:
                    min_power_generation_value = None
                try:
                    power_units = scenario_step["parameters"]["minPowerGeneration"][
                        "units"
                    ]
                except KeyError:
                    pass
                try:
                    max_power_consumption_value = scenario_step["parameters"][
                        "maxPowerConsumption"
                    ]["value"]
                except KeyError:
                    max_power_consumption_value = None
                try:
                    power_units = scenario_step["parameters"]["maxPowerConsumption"][
                        "units"
                    ]
                except KeyError:
                    pass
                duration_value = scenario_step["parameters"]["duration"]["value"]
                duration_units = scenario_step["parameters"]["duration"]["units"]
                parameter_value = t.render(
                    minPowerGeneration=min_power_generation_value,
                    maxPowerConsumption=max_power_consumption_value,
                    duration=duration_value,
                )
                parameter_units = 1 * u(power_units) * u(duration_units)
                parameter_quantity = (parameter_value * parameter_units).to(
                    scenario_step["parameters"][parameter_name]["units"]
                )
                print("       ", parameter_name, ":", parameter_quantity)
            else:
                print(
                    "       ", parameter_name, ":", parameter_value * u(parameter_units)
                )
