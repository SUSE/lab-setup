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


def smlm_add_customvalues(key, client, sid, customkey, value):
  """
  Set custom values for the specified server.
  """
  results = client.system.setCustomValues(key, sid, { customkey: value } )
  return results

def smlm_get_systemid(key, client, name):
  """
  Get system IDs and last check in information for the given system name.
  """
  system = client.system.getId(key, name)
  return system


def smlm_list_systems(key, client):
  """
  Returns a list of all servers visible to the user.
  """
  systems = client.system.listSystems(key)
  return systems


def smlm_delete_system(key, client, sid):
  """
  Delete a system given its server id synchronously without cleanup
  """
  systems = client.system.deleteSystem(key, sid, cleanupType='FORCE_DELETE')
  return systems



def main():
  """
  Main function that parses the command-line arguments and initiate the API calls.
  """
  # Define how we want to process command line arguments
  parser = argparse.ArgumentParser(prog='smlm_user',description='Manages SMLM system groups')
  group = parser.add_mutually_exclusive_group(required=True)
  group.add_argument('--addcustomvalue', action='store_true', help='Add custom value to a system')
  group.add_argument('-d','--delete', action='store_true', help='Delete system')
  group.add_argument('-l','--list', action='store_true', help='List all system groups')
  parser.add_argument('-u', '--user', type=str, required=True, help='User name with privileges to create other users')
  parser.add_argument('-p', '--pwd', type=str, required=True, help='Password for user')
  parser.add_argument('-s', '--server', type=str, required=True, help='Server FQDN')
  parser.add_argument('--customkey', type=str, help='Custom key name.')
  parser.add_argument('--system', type=str, help='System name.')
  parser.add_argument('--keyvalue', type=str, help="Custom key value.")
  parser.add_argument('--debug', action='store_true', help="Use it to enable debug messages.")
  inputparam=parser.parse_args()

  context = ssl._create_unverified_context()
  client = ServerProxy('https://' + inputparam.server + '/rpc/api', context=context)

  key, client = smlm_login(inputparam.server, inputparam.user, inputparam.pwd)

  if(inputparam.addcustomvalue):
    if( not inputparam.customkey or not inputparam.keyvalue or not inputparam.system):
      sys.exit("Missing parameters, --customkey, --system, --keyvalue are required")
    print("Adding custom key \"" + str(inputparam.customkey) + "\" with value: \"" + str(inputparam.keyvalue) + "\" to system "+ str(inputparam.system))
    results=smlm_get_systemid(key, client, inputparam.system)
    smlm_add_customvalues(key, client, results[0]['id'], inputparam.customkey, inputparam.keyvalue)
  elif(inputparam.delete):
    print("Deleting system " + str(inputparam.system))
    results=smlm_get_systemid(key, client, inputparam.system)
    sid=results[0]['id']
    smlm_delete_system(key, client, sid)
  elif(inputparam.list):
    print("Retrieving the list of systems")
    print(yaml.dump(smlm_list_systems(key, client)))
  else:
    print("Invalid or missing parameters")
    if(inputparam.debug):
      print(yaml.dump(inputparam))

  smlm_logout(key, client)



if __name__ == '__main__':
  main()

