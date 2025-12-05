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


def smlm_create_systemgroup(key, client, name, description=None):
  """
  Create a new system group
  """
  if(description == None):
    description="Group "+name

  group = client.systemgroup.create(key, name, description)
  return group

def smlm_get_systemid(key, client, name):
  """
  Get system IDs and last check in information for the given system name.
  """
  system = client.system.getId(key, name)
  return system


def smlm_addOrRemoveSystems(key, client, systemGroupName, servers, present):
  """
  Add/remove the given servers to a system group.
  """
  serverIds=[]
  for server in servers.split(','):
    results=smlm_get_systemid(key, client, server)
#    print(yaml.dump(results))
#    print(results[0])
    serverIds.append(results[0]['id'])
  client.systemgroup.addOrRemoveSystems(key, systemGroupName, serverIds, present)


def smlm_delete_systemgroup(key, client, systemGroupName):
  """
  Delete a system group.
  """
  group = client.systemgroup.delete(key, systemGroupName)
  return group


def smlm_list_systemgroups(key, client):
  """
  Retrieve a list of system groups that are accessible by the logged in user.
  """
  groups = client.systemgroup.listAllGroups(key)
  return groups


def smlm_list_systems(key, client):
  """
  Returns a list of all servers visible to the user.
  """
  systems = client.system.listSystems(key)
  return systems


def smlm_listsystems_systemgroup(key, client, systemGroupName):
  """
  Return a list of systems associated with this system group. User must have access to this system group.
  """
  systems = client.systemgroup.listSystems(key, systemGroupName)
  return systems


def smlm_is_system_in_group(key, client, system, group):
  """
  Returns true or false depending if the system is in the group or not.
  """
  systems = smlm_listsystems_systemgroup(key, client, group)
  for i in systems:
    if i['profile_name'] == system:
      print("System "+system+" is present in group "+group)
      break


def main():
  """
  Main function that parses the command-line arguments and initiate the API calls.
  """
  # Define how we want to process command line arguments
  parser = argparse.ArgumentParser(prog='smlm_user',description='Manages SMLM system groups')
  group = parser.add_mutually_exclusive_group(required=True)
  group.add_argument('-a','--add', action='store_true', help='Add system group')
  group.add_argument('-d','--delete', action='store_true', help='Delete system group')
  group.add_argument('-g','--getsystems', action='store_true', help='List systems in system group')
  group.add_argument('-l','--list', action='store_true', help='List all system groups')
  group.add_argument('-x','--listsystems', action='store_true', help='List all system')
  group.add_argument('-b','--addsystem', action='store_true', help='Add a system/s to a group')
  group.add_argument('-r','--delsystem', action='store_true', help='Remove a system/s from a group')
  group.add_argument('-c','--check', action='store_true', help='Check if the system is in a group')
  parser.add_argument('-u', '--user', type=str, required=True, help='User name with privileges to create other users')
  parser.add_argument('-p', '--pwd', type=str, required=True, help='Password for user')
  parser.add_argument('-s', '--server', type=str, required=True, help='Server FQDN')
  parser.add_argument('--group', type=str, help='System group name.')
  parser.add_argument('--system', type=str, help='System/s separated by ,.')
  parser.add_argument('--description', type=str, help="Group description (optional).")
  parser.add_argument('--debug', action='store_true', help="Use it to enable debug messages.")
  inputparam=parser.parse_args()

  context = ssl._create_unverified_context()
  client = ServerProxy('https://' + inputparam.server + '/rpc/api', context=context)

  key, client = smlm_login(inputparam.server, inputparam.user, inputparam.pwd)

  if(inputparam.add):
    if( not inputparam.group):
      sys.exit("Missing parameters, --group is required")
    print("Adding group " + str(inputparam.group))
    smlm_create_systemgroup(key, client, inputparam.group, inputparam.description)
  elif(inputparam.delete):
    print("Deleting group " + str(inputparam.group))
    smlm_delete_systemgroup(key, client, inputparam.group)
  elif(inputparam.getsystems):
    print("Listing systems in group " + str(inputparam.group))
    print(yaml.dump(smlm_listsystems_systemgroup(key, client, inputparam.group)))
  elif(inputparam.list):
    print("Retrieving the list of system groups")
    print(yaml.dump(smlm_list_systemgroups(key, client)))
  elif(inputparam.listsystems):
    print("Retrieving the list of systems")
    print(yaml.dump(smlm_list_systems(key, client)))
  elif(inputparam.addsystem):
    print("Add system/s " + str(inputparam.system) + " to group " +str(inputparam.group) )
    smlm_addOrRemoveSystems(key, client, inputparam.group, inputparam.system, True)
  elif(inputparam.delsystem):
    print("Remove system/s " + str(inputparam.system) + " from group " +str(inputparam.group) )
    smlm_addOrRemoveSystems(key, client, inputparam.group, inputparam.system, False)
  elif(inputparam.check):
    print("Check if system "+ str(inputparam.system) + " is in group " +str(inputparam.group))
    smlm_is_system_in_group(key, client, inputparam.system, inputparam.group)
  elif(inputparam.rm-system-to-group):
    print("Deleting user " + str(inputparam.nusr))
    smlm_delete_user(key, client, inputparam.nusr)
  else:
    print("Invalid or missing parameters")
    if(inputparam.debug):
      print(yaml.dump(inputparam))

  smlm_logout(key, client)



if __name__ == '__main__':
  main()

