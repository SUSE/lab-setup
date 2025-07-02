#!/usr/bin/python3
#
# Authors: Raul Mahiques
# License: GPLv3
# 
# $Id$
#

from xmlrpc.client import ServerProxy
import ssl, argparse, yaml



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


def smlm_create_ak(key, client, name, description, baseChannelLabel, usageLimit, entitlements , universalDefault, appstreams, childchannels, configchannels, packages, servergroups):
  """
  Creates an activation key in SMLM
  """
  akname = client.activationkey.create(key, name, description, baseChannelLabel, usageLimit, entitlements , universalDefault)
  print('Activation Key ID: ' + akname)
  if appstreams != []:
    smlm_add_appstreams_akid(key, client, akname, appstreams.split(','))
  if childchannels != []:
    smlm_add_childchannels_akid(key, client, akname, childchannels.split(','))
  if configchannels != []:
    smlm_add_configchannels_akid(key, client, akname, configchannels.split(','))
  if packages != []:
     smlm_add_packages_akid(key, client, akname, packages.split(','))
  if servergroups != []:
    smlm_add_servergroups_akid(key, client, akname, servergroups.split(','))

def smlm_get_ak(key, client, akname):
  """
  Returns information about an Activation Key in SMLM
  """
  print(yaml.dump(client.activationkey.getDetails(key, akname)))
  

def smlm_list_aks(key, client):
  """
  Returns the list of Activation Key in SMLM
  """
  return client.activationkey.listActivationKeys(key)


def smlm_get_akid(key, client, akname):
  """
  Retrieves information about a SMLM Activation Key and returns the Activation Key ID.
  """
  akDetails = client.activationkey.getDetails(key, akname)
  print(akDetails)


def smlm_del_ak(key, client, akid):
  """
  Deletes an Activation Key from SMLM
  """
  print(akid)
  result = client.activationkey.delete(key, akid)
  print('Results:\n', result)


def smlm_add_appstreams_akid(key, client, akname, appstreams):
  """
  Add to a SMLM Activation Key.
  """
  akDetails = client.activationkey.addAppStreams(key, akname, appstreams)


def smlm_add_childchannels_akid(key, client, akname, childchannels):
  """
  Add Child Channels to a SMLM Activation Key.
  """
  akDetails = client.activationkey.addChildChannels(key, akname, childchannels)




def smlm_add_configchannels_akid(key, client, akname, configchannels):
  """
  Add Config Channels to a SMLM Activation Key.
  """
  akDetails = client.activationkey.addConfigChannels(key, akname, configchannels)


def smlm_add_entitlements_akid(key, client, akname, entitlements):
  """
  Add Entitlements to a SMLM Activation Key.
  """
  akDetails = client.activationkey.addEntitlements(key, akname, entitlements)


def smlm_add_packages_akid(key, client, akname, packages):
  """
  Add Packages to a SMLM Activation Key.
  """
  akDetails = client.activationkey.addPackages(key, akname, packages)


def smlm_add_servergroups_akid(key, client, akname, servergroups):
  """
  Add Server Groups to a SMLM Activation Key.
  """
  akDetails = client.activationkey.addServerGroups(key, akname, servergroups)



#### List methods
def smlm_list_appstreams(key, client, channellabel):
  """
  List Appstreams from SMLM.
  """
  return(client.channel.appstreams.listModuleStreams(key, channelLabel))


def smlm_list_channels(key, client):
  """
  List Main Channels from SMLM.
  """
  return(client.channel.listAllChannels(key))

def smlm_list_childchannels(key, client):
  """
  List Child Channels from SMLM.
  """
  return(client.channel.listSoftwareChannels(key))

def smlm_list_configchannels(key, client):
  """
  List Config Channels from SMLM.
  """
  return(client.configchannel.listGlobals(key))


def smlm_list_packages(key, client, channel):
  """
  List Packages from SMLM channel.
  """
  return client.channel.software.listAllPackages(key, channel)


def smlm_list_servergroups(key, client):
  """
  List Server Groups from SMLM.
  """ 
  return client.systemgroup.listAllGroups(key)





def main():
  """
  Main function that parses the command-line arguments and initiate the API calls.
  """
  # Define how we want to process command line arguments
  parser = argparse.ArgumentParser(prog='smlm_ak',description='Manages SMLM Activation keys')
  group = parser.add_mutually_exclusive_group(required=True)
  group.add_argument('-a','--add', action='store_true', help='Add Activation Key')
  group.add_argument('-d','--delete', action='store_true', help='Delete Activation Keys')
  group.add_argument('-g','--get', action='store_true', help='Retrieve Activation Keys information')
  group.add_argument('--list_appstreams', action='store_true', help='List App Streams')
  group.add_argument('--list_childchannels', action='store_true', help='List Channels')
  group.add_argument('--list_configchannels', action='store_true', help='List Config Channels')
  group.add_argument('--list_packages', action='store_true', help='List Packages')
  group.add_argument('--list_servergroups', action='store_true', help='List Server Groups ')
  group.add_argument('-l','--list', action='store_true', help='List Activation Keys')
  parser.add_argument('-u', '--user', type=str, required=True, help='User name with privileges to create Activation Keys')
  parser.add_argument('-p', '--pwd', type=str, required=True, help='Password for user')
  parser.add_argument('-s', '--server', type=str, required=True, help='Server FQDN')
  parser.add_argument('-k','--akname', type=str, help='Activation Keys name. Must meet same criteria as in the web UI.')
  parser.add_argument('--description', type=str, help='Activation Key description.')
  parser.add_argument('--basechannellabel', type=str, help='Base Channel Label.')
  parser.add_argument('--usagelimit', type=int, help="Number of systems that can use this, leave it empty for unlimited")
  parser.add_argument('--entitlements', type=str, help="Entitlements separated by comma: container_build_host,monitoring_entitled,osimage_build_host,virtualization_host,ansible_control_node,proxy_entitled,")
  parser.add_argument('--universal', action='store_true', help='Makes this activation key the universal default.')
  parser.add_argument('--appstreams', type=str, help='Add app streams to an activation key. Separated by comma: aa,bb,cc')
  parser.add_argument('--childchannels', type=str, help='Child channel/s. Separated by comma: aa,bb,cc')
  parser.add_argument('--configchannels', type=str, help='Configuration channel/s. Separated by comma: aa,bb,cc')
  parser.add_argument('--packages', type=str, help='Package/s. Separated by comma: aa,bb,cc')
  parser.add_argument('--servergroups', type=str, help='Server group/s. Separated by comma: aa,bb,cc')
  parser.add_argument('--debug', action='store_true', help="Use it to enable debug messages.")
  inputparam=parser.parse_args()

  context = ssl._create_unverified_context()
  client = ServerProxy('https://' + inputparam.server + '/rpc/api', context=context)

  key, client = smlm_login(inputparam.server, inputparam.user, inputparam.pwd)

  if(inputparam.add and inputparam.akname and inputparam.description and inputparam.basechannellabel):
    print("Adding activation key " + str(inputparam.akname))
    smlm_create_ak(key, client, inputparam.akname, inputparam.description, inputparam.basechannellabel or '', inputparam.usagelimit or 0, inputparam.entitlements or [], inputparam.universal or False, inputparam.appstreams or [], inputparam.childchannels or [], inputparam.configchannels or [], inputparam.packages or [], inputparam.servergroups or [])
  elif(inputparam.delete):
    print("Deleting activation key " + str(inputparam.akname))
    smlm_del_ak(key, client, inputparam.akname)
  elif(inputparam.get):
    print("Retrieving information about activation key: " + str(inputparam.akname))
    print(str(smlm_get_ak(key, client, inputparam.akname)))
  elif(inputparam.list):
    print("Retrieving the list of Activation Keys")
    print(yaml.dump(smlm_list_aks(key, client)))
  elif(inputparam.list_appstreams):
    print("Retrieving the list of App. Streams ")
    if inputparam.basechannellabel:
      print(yaml.dump(smlm_list_appstreams(key, client, inputparam.basechannellabel)))
    else:
      print("Missing --basechannellabel, use --list_channels to retrieve the list of channels")
  elif(inputparam.list_childchannels):
    print("Retrieving the list of Child channels")
    smlm_channels = smlm_list_channels(key, client)
    smlm_softwarechannels = smlm_list_childchannels(key, client)
    for i in smlm_channels:
      found = False
      for chnl in smlm_softwarechannels:
        if chnl['label'] == i["label"] and chnl['parent_label'] != '':
          found = True
          break
      if found == False:
        print("MAIN CHANNEL " + i["label"])
        for o in smlm_softwarechannels:
          if o["parent_label"] == i["label"]:
            print("\t- " + o["label"])
  elif(inputparam.list_configchannels):
    print("Retrieving the list of Config Channels")
    print(yaml.dump(smlm_list_configchannels(key, client)))
  elif(inputparam.list_packages):
    print("Retrieving the list of Packages")
    if inputparam.basechannellabel:
      print(yaml.dump(smlm_list_packages(key, client, inputparam.basechannellabel)))
    else:
      print("Missing basechannellabel parameter indicating the channel")
  elif(inputparam.list_servergroups):
    print("Retrieving the list of Server Groups")
    print(yaml.dump(smlm_list_servergroups(key, client)))
  else:
    print("Invalid or missing parameters")
    if(inputparam.debug):
      print(yaml.dump(inputparam))

  smlm_logout(key, client)



if __name__ == '__main__':
  main()

