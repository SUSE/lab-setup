#!/usr/bin/python3
#
# Author/s: Raul Mahiques
# License: GPLv3
# 
# $Id$
#

from xmlrpc.client import ServerProxy
import ssl, argparse, yaml, sys, datetime


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


def smlm_schedule_applyHighstate(key, client, sid, when, test=False):
  """
  Schedule highstate application for a given system.
  """
  if not when:
    earliest_occurrence = datetime.datetime.now(datetime.timezone.utc)
  else:
    earliest_occurrence = when
  results = client.system.scheduleApplyHighstate(key, sid, earliest_occurrence, test )
  return results

def smlm_schedule_packageRefresh(key, client, sid, when ):
  """
  Schedule a package list refresh for a system.
  """
  if not when:
    earliest_occurrence = datetime.datetime.now(datetime.timezone.utc)
  else:
    earliest_occurrence = when
  results = client.system.schedulePackageRefresh(key, sid, earliest_occurrence )
  return results

def smam_system_getDetails(key, client, sid):
  """
  Get system details.
  """
  results = client.system.getDetails(key, sid)
  return results


def smlm_schedule_HardwareRefresh(key, client, sid, when):
  """
  Schedule a hardware refresh for a system.
  """
  if not when:
    earliest_occurrence = datetime.datetime.now(datetime.timezone.utc)
  else:
    earliest_occurrence = when
  results = client.system.scheduleHardwareRefresh(key, sid, earliest_occurrence )
  return results


def smlm_schedule_state(key, client, sid, state, when, test=False):
  """
  Schedule a state/s for a system.
  """
  if not when:
    earliest_occurrence = datetime.datetime.now(datetime.timezone.utc)
  else:
    earliest_occurrence = when
  states=[]
  if not state:
    states=['certs','channels','packages','services.salt-minion']
  else:
    for i in state.split(','):
      states.append(i)

  results = client.system.scheduleApplyStates(key, sid, states, earliest_occurrence, test )
  return results



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
  group.add_argument('--scheduleapplyhighstate', action='store_true', help='Schedule highstate application for a given system.')
  group.add_argument('--schedulepackagerefresh', action='store_true', help='Schedule a package list refresh for a system.')
  group.add_argument('--schedulehardwarerefresh', action='store_true', help='Schedule a hardware refresh for a system.')
  group.add_argument('--schedulestate', action='store_true', help='Schedule a state refresh for a system.')
  group.add_argument('-g','--getinfo', action='store_true', help='Get system info')
  parser.add_argument('-u', '--user', type=str, required=True, help='User name with privileges to create other users')
  parser.add_argument('-p', '--pwd', type=str, required=True, help='Password for user')
  parser.add_argument('-s', '--server', type=str, required=True, help='Server FQDN')
  parser.add_argument('--customkey', type=str, help='Custom key name.')
  parser.add_argument('--system', type=str, help='System name.')
  parser.add_argument('--keyvalue', type=str, help="Custom key value.")
  parser.add_argument('--executiondate', type=str, help="Date for the action to be executed, default is now, format: " + str(datetime.datetime.now(datetime.timezone.utc)) +".")
  parser.add_argument('--state', type=str, help='state/s serparated by , .')
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
    if( not inputparam.system):
      sys.exit("Missing parameters, --system is required")
    print("Deleting system " + str(inputparam.system))
    results=smlm_get_systemid(key, client, inputparam.system)
    sid=results[0]['id']
    smlm_delete_system(key, client, sid)
  elif(inputparam.list):
    print("Retrieving the list of systems")
    print(yaml.dump(smlm_list_systems(key, client)))
  elif(inputparam.scheduleapplyhighstate):
    if( not inputparam.system):
      sys.exit("Missing parameters, --system is required")
    print("Scheduling apply highstate for system " + str(inputparam.system))
    systemid=smlm_get_systemid(key, client, inputparam.system)
    results=smlm_schedule_applyHighstate(key, client, systemid[0]['id'], inputparam.executiondate, test=False)
  elif(inputparam.schedulepackagerefresh):
    if( not inputparam.system):
      sys.exit("Missing parameters, --system is required")
    print("Scheduleing a package refresh for system " + str(inputparam.system))
    systemid=smlm_get_systemid(key, client, inputparam.system)
    results=smlm_schedule_packageRefresh(key, client, systemid[0]['id'], inputparam.executiondate)

  elif(inputparam.schedulehardwarerefresh):
    if( not inputparam.system):
      sys.exit("Missing parameters, --system is required")
    print("Scheduleing a hardware refresh for system " + str(inputparam.system))
    systemid=smlm_get_systemid(key, client, inputparam.system)
    results=smlm_schedule_HardwareRefresh(key, client, systemid[0]['id'], inputparam.executiondate)

  elif(inputparam.schedulestate):
    if( not inputparam.system):
      sys.exit("Missing parameters, --system is required")
    print("Scheduleing a state " + str(inputparam.state) + " refresh for system " + str(inputparam.system))
    systemid=smlm_get_systemid(key, client, inputparam.system)

    results=smlm_schedule_state(key, client, systemid[0]['id'], inputparam.state, inputparam.executiondate, test=False)

  elif(inputparam.getinfo):
    if( not inputparam.system):
      sys.exit("Missing parameters, --system is required")
    print("Get information about system " + str(inputparam.system))
    systemid=smlm_get_systemid(key, client, inputparam.system)
    print(yaml.dump(smam_system_getDetails(key, client, systemid[0]['id'])))
  else:
    print("Invalid or missing parameters")
    if(inputparam.debug):
      print(yaml.dump(inputparam))

  smlm_logout(key, client)



if __name__ == '__main__':
  main()

