#!/usr/bin/env python

import os
import re
from ansible.module_utils.basic import AnsibleModule
from ansible.errors import AnsibleError

prefix = 'CIENV_'
env_regex = re.compile('('+ prefix + '([^_]+)_([^_]+)_(.+))', re.IGNORECASE)

def config_dir_path(module_name):
  return "../modules/{}/config".format(module_name)

def env_file_path(module_name, container_name):
  return "{}/{}.env".format(config_dir_path(module_name), container_name)

env_variables_matches = [env_regex.search(env) for env in os.environ]
matching_env_variables = [match.groups() for match in env_variables_matches if match]
for (env_variable, module_name, container_name, variable_name) in matching_env_variables:
  module_name = module_name.lower()
  container_name = container_name.lower()
  env_variable_value = os.getenv(env_variable)

  if not os.path.isdir(config_dir_path(module_name)):
    raise AnsibleError('Module `{}` not found. Make sure that the directory `{}` exists.'.format(module_name, config_dir_path(module_name)))

  with open(env_file_path(module_name, container_name), "a") as f:
    # print("updating {} with {} = {}".format(f.name, variable_name, env_variable_value))
    f.write("{}={}\n".format(variable_name, env_variable_value))

AnsibleModule({}).exit_json()
