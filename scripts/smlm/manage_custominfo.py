#!/usr/bin/python3
#
# Author/s: Raul Mahiques
# License: GPLv3
# 
# $Id$
#

from xmlrpc.client import ServerProxy
import ssl, argparse, yaml, sys



def smlm_login(server, user, pwd):
  """
  Performs an authentication login and returns the session key
  """
  context = ssl._create_unverified_context()
  client = ServerProxy('https://' + server + '/rpc/api', context=context)
  key = client.auth.login(user, pwd)
  return key, client


def smlm_logout(key, client):
  """
  Performs a logout
  """
  client.auth.logout(key)


def smlm_create_key(key, client, keyLabel, keyDescription=None):
  """
  Create a new custom key
  """
  if(keyDescription == None):
    keyDescription="Key "+name

  customkey = client.system.custominfo.createKey(key, keyLabel, keyDescription)
  return customkey


def smlm_delete_key(key, client, keyLabel):
  """
  Delete an existing custom key and all systems' values for the key.
  """
  customkey = client.system.custominfo.deleteKey(keyLabel)
  return customkey


def smlm_list_keys(key, client):
  """
  List the custom information keys defined for the user’s organization.
  """
  customkeys = client.system.custominfo.listAllKeys(key)
  return customkeys


def smlm_update_key(key, client, keyLabel, keyDescription):
  """
  Update description of a custom key
  """
  customkey = client.system.custominfo.updateKey(key, keyLabel, keyDescription)
  return customkey


def main():
  """
  Main function that parses the command-line arguments and initiate the API calls.
  """
  # Define how we want to process command line arguments
  parser = argparse.ArgumentParser(prog='smlm_user',description='Manages SMLM custom keys')
  group = parser.add_mutually_exclusive_group(required=True)
  group.add_argument('-a','--add', action='store_true', help='Add custom key')
  group.add_argument('-d','--delete', action='store_true', help='Delete custom key')
  group.add_argument('-l','--list', action='store_true', help='List all custom keys')
  group.add_argument('-t','--update', action='store_true', help='Update a custom key')
  parser.add_argument('-u', '--user', type=str, required=True, help='User name with privileges to create other users')
  parser.add_argument('-p', '--pwd', type=str, required=True, help='Password for user')
  parser.add_argument('-s', '--server', type=str, required=True, help='Server FQDN')
  parser.add_argument('--key', type=str, help='Custome key label.')
  parser.add_argument('--description', type=str, help="Custom key description (optional).")
  parser.add_argument('--debug', action='store_true', help="Use it to enable debug messages.")
  inputparam=parser.parse_args()

  context = ssl._create_unverified_context()
  client = ServerProxy('https://' + inputparam.server + '/rpc/api', context=context)

  key, client = smlm_login(inputparam.server, inputparam.user, inputparam.pwd)

  if(inputparam.add):
    if( not inputparam.key):
      sys.exit("Missing parameters, --key is required")
    print("Adding key " + str(inputparam.key))
    smlm_create_key(key, client, inputparam.key, inputparam.description)
  elif(inputparam.delete):
    print("Deleting key " + str(inputparam.key))
    smlm_delete_key(key, client, inputparam.key)
  elif(inputparam.list):
    print("Retrieving the list of custom keys")
    print(yaml.dump(smlm_list_keys(key, client)))
  elif(inputparam.update):
    print("Update custom key " + str(inputparam.key))
    smlm_update_key(key, client, inputparam.key, inputparam.description)
  else:
    print("Invalid or missing parameters")
    if(inputparam.debug):
      print(yaml.dump(inputparam))

  smlm_logout(key, client)



if __name__ == '__main__':
  main()

